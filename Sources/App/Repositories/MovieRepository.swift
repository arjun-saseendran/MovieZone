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
