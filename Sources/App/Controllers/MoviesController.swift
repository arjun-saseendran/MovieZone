import Foundation
import Hummingbird

struct MoviesController {
    let repository: MovieRepository
    var endpoints: RouteCollection<AppRequestContext>{
        let routeCollection = RouteCollection(context: AppRequestContext.self)
        routeCollection.get(use: getMovies)
        routeCollection.get(":id", use: getMovie)
        routeCollection.post(use: createMovie)
        return routeCollection
    }

    func createMovie(request: Request, context: some RequestContext) async throws -> Movie {
            let movie = try await request.decode(as: Movie.self, context: context)
            return try await repository.save(movie)
        }
    
    func getMovies(request: Request, context: some RequestContext) async throws -> [Movie] {
       try  await repository.getAll()
    }

    func getMovie(request: Request, context: some RequestContext) async throws -> Movie? {
       
            guard let id = context.parameters.get("id", as: UUID.self) else {
                throw HTTPError(.badRequest)
            }
            guard let movie = try await repository.getById(id) else {
                throw HTTPError(.notFound)
            }
            return movie
        }

    
    }


