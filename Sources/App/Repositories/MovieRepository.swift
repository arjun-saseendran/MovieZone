import Foundation
import PostgresNIO

struct MovieRepository {
    let client: PostgresClient

    func createTable() async throws {
        try await client.query(
            """
                    CREATE TABLE IF NOT EXISTS movies(
                    id UUID PRIMARY KEY,
                    title TEXT NOT NULL,
                    year INTEGER NOT NULL
                    )
            """)
    }

    func getAll() async throws -> [Movie] {
        let stream = try await self.client.query("SELECT id, title, year FROM movies;")
        var movies: [Movie] = []

        for try await (id, title, year) in stream.decode(
            (UUID, String, Int).self, context: .default)
        {
            let movie = Movie(id: id, title: title, year: year)
            movies.append(movie)
        }
        return movies
    }

    func save(_ movie: Movie) async throws -> Movie {
        let id = UUID()
        try await self.client.query(
            """
            INSERT IN TO movies(id, title, year)
            VALUES(\(id),\(movie.title), \(movie.year));
            """)

        return Movie(id: id, title: movie.title, year: movie.year)

    }

}
