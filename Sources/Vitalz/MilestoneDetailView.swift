import SwiftUI
import SwiftData

public struct MilestoneDetailView: View {
    let milestone: Milestone
    
    @Environment(\.dismiss) private var dismiss
    @Query private var vaultEntries: [MilestoneVaultEntry]
    
    @State private var showingVaultEditor = false
    
    public init(milestone: Milestone) {
        self.milestone = milestone
        let milestoneId = milestone.id
        self._vaultEntries = Query(filter: #Predicate<MilestoneVaultEntry> { $0.milestoneId == milestoneId })
    }
    
    private var vaultEntry: MilestoneVaultEntry? {
        vaultEntries.first
    }
    
    public var body: some View {
        ZStack {
            Color.vitalzBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: milestone.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.vitalzAccent)
                        
                        Text(milestone.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.vitalzText)
                            .multilineTextAlignment(.center)
                        
                        Text(milestone.subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(.vitalzSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 40)
                    
                    if let date = milestone.date {
                        VStack(spacing: 4) {
                            Text("ACHIEVED")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.vitalzSecondaryText)
                                .kerning(2)
                            
                            Text(date, format: .dateTime.month().day().year())
                                .font(.system(size: 18, weight: .medium, design: .monospaced))
                                .foregroundColor(.vitalzText)
                        }
                    }
                    
                    // Vault Section
                    VStack(spacing: 24) {
                        HStack {
                            Text("VAULT")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.vitalzAccent)
                                .kerning(4)
                            Spacer()
                        }
                        .padding(.horizontal, 32)
                        
                        if let entry = vaultEntry, (entry.imageData != nil || entry.locationDescription != nil) {
                            // Vault entry exists
                            VStack(spacing: 24) {
                                if let data = entry.imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 280, height: 380)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .shadow(color: .vitalzShadow, radius: 20, y: 10)
                                }
                                
                                if let location = entry.locationDescription {
                                    HStack(spacing: 8) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundColor(.vitalzAccent)
                                        Text(location)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.vitalzText)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.vitalzCard)
                                    .cornerRadius(16)
                                }
                                
                                Button("Edit Vault") {
                                    showingVaultEditor = true
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.vitalzSecondaryText)
                                .padding(.top, 12)
                            }
                        } else {
                            // No vault entry yet
                            VStack(spacing: 16) {
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 32, weight: .light))
                                    .foregroundColor(.vitalzSecondaryText)
                                
                                Text("This memory is unsealed.")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.vitalzSecondaryText)
                                
                                Button {
                                    showingVaultEditor = true
                                } label: {
                                    Text("Add to Vault")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.vitalzBackground)
                                        .padding(.horizontal, 32)
                                        .padding(.vertical, 14)
                                        .background(Color.vitalzText)
                                        .cornerRadius(24)
                                }
                                .padding(.top, 8)
                            }
                            .padding(40)
                            .frame(maxWidth: .infinity)
                            .background(Color.vitalzCard)
                            .cornerRadius(24)
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 24)
                    
                    Spacer(minLength: 80)
                }
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.vitalzSecondaryText)
                            .background(Circle().fill(Color.vitalzBackground))
                    }
                    .padding(24)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showingVaultEditor) {
            MilestoneVaultView(milestone: milestone, existingEntry: vaultEntry)
        }
    }
}
