import Foundation
import SwiftData

@Model
public final class MilestoneVaultEntry {
    @Attribute(.unique) public var milestoneId: String
    
    @Attribute(.externalStorage)
    public var imageData: Data?
    
    public var locationDescription: String?
    
    public init(milestoneId: String, imageData: Data? = nil, locationDescription: String? = nil) {
        self.milestoneId = milestoneId
        self.imageData = imageData
        self.locationDescription = locationDescription
    }
}
