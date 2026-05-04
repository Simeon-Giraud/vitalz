import SwiftUI
import SwiftData
import PhotosUI

public struct MilestoneVaultView: View {
    let milestone: Milestone
    let existingEntry: MilestoneVaultEntry?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var locationText: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    public init(milestone: Milestone, existingEntry: MilestoneVaultEntry?) {
        self.milestone = milestone
        self.existingEntry = existingEntry
        self._locationText = State(initialValue: existingEntry?.locationDescription ?? "")
        self._selectedImageData = State(initialValue: existingEntry?.imageData)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vitalzBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Header
                        VStack(spacing: 8) {
                            Text(milestone.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.vitalzText)
                                .multilineTextAlignment(.center)
                            
                            Text("Attach a memory to this milestone.")
                                .font(.system(size: 14))
                                .foregroundColor(.vitalzSecondaryText)
                        }
                        .padding(.top, 32)
                        
                        // Photo Picker
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 240, height: 320)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .vitalzShadow, radius: 20, y: 10)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.vitalzCard)
                                        .frame(width: 240, height: 320)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.vitalzDivider, style: StrokeStyle(lineWidth: 1, dash: [8]))
                                        )
                                    
                                    VStack(spacing: 12) {
                                        Image(systemName: "plus.viewfinder")
                                            .font(.system(size: 32, weight: .light))
                                            .foregroundColor(.vitalzSecondaryText)
                                        Text("Add Photo")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.vitalzSecondaryText)
                                    }
                                }
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    withAnimation {
                                        selectedImageData = data
                                    }
                                }
                            }
                        }
                        
                        // Location Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("LOCATION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.vitalzSecondaryText)
                                .kerning(2)
                            
                            TextField("Where did this happen?", text: $locationText)
                                .font(.system(size: 16, weight: .medium))
                                .padding()
                                .background(Color.vitalzCard)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.vitalzDivider, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Vault Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.vitalzSecondaryText)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(canSave ? .vitalzAccent : .vitalzSecondaryText.opacity(0.5))
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var canSave: Bool {
        return selectedImageData != nil || !locationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveEntry() {
        let finalLocation = locationText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let entry = existingEntry {
            entry.imageData = selectedImageData
            entry.locationDescription = finalLocation.isEmpty ? nil : finalLocation
        } else {
            let newEntry = MilestoneVaultEntry(
                milestoneId: milestone.id,
                imageData: selectedImageData,
                locationDescription: finalLocation.isEmpty ? nil : finalLocation
            )
            modelContext.insert(newEntry)
        }
        
        try? modelContext.save()
        HapticEngine.playSuccess()
        dismiss()
    }
}
