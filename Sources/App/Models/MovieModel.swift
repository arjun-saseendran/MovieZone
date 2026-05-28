import Foundation
import Hummingbird

struct Movie {
    var id: UUID?
    let title: String
    let year: Int
}

extension Movie: ResponseEncodable, Decodable, Equatable {}
