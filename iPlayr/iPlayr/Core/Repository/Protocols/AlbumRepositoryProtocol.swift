import MusicKit

@MainActor
protocol AlbumRepositoryProtocol: AnyObject {
    func getAlbumTracks(id: String) async throws -> MusicItemCollection<Track>?
    func getCurrentUserSavedAlbums(sortOrder: SortOrder) async throws -> MusicItemCollection<Album>?
}
