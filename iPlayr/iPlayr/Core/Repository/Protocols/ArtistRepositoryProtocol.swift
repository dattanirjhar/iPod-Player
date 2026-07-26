import MusicKit

@MainActor
protocol ArtistRepositoryProtocol: AnyObject {
    func getCurrentUserArtists(sortOrder: SortOrder) async throws -> MusicItemCollection<Artist>?
    func getArtistAlbums(id: String) async throws -> MusicItemCollection<Album>?
}
