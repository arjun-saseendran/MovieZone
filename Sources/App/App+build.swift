import Configuration
import Hummingbird
import Logging
import PostgresNIO
import Foundation

struct Movie {
    var id: UUID?
    let title: String
    let year: Int
}

extension Movie: ResponseEncodable, Decodable, Equatable {}

// Request context used by application
typealias AppRequestContext = BasicRequestContext

///  Build application
/// - Parameter reader: configuration reader
func buildApplication(reader: ConfigReader) async throws -> some ApplicationProtocol {
    let logger = {
        var logger = Logger(label: "MyNewProject")
        logger.logLevel = reader.string(forKey: "log.level", as: Logger.Level.self, default: .info)
        return logger
    }()

    var movieRepositoy: MovieRepository?
    var router: Router<AppRequestContext>

    let client = PostgresClient(
        configuration: .init(
            host: "localhost", port:5432, username: "postgres", password: "postgres", database: "moviesdb",
            tls: .disable))

    let repository = MovieRepository(client: client)
    movieRepositoy = repository

    router = try buildRouter(repository)
    var app = Application(
        router: router,
        configuration: ApplicationConfiguration(reader: reader.scoped(to: "http")),
        logger: logger
    )
    if let movieRepositoy {
        app.addServices(movieRepositoy.client)
        app.beforeServerStarts {
            try await movieRepositoy.createTable()
        }
    }

    return app
}

func buildRouter(_ repository: MovieRepository) throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
    }

    router.addRoutes(MoviesController(repository: repository).endpoints, atPath: "/api/movies")

    return router

}
