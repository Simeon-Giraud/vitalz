import SwiftUI

struct RearrangeCardsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("cardOrder") private var cardOrder: String = ""
    
    @State private var items: [String] = []
    
    private let defaultOrder = [
        "secondsAlive", "heartbeats", "breathsTaken", "timesBlinked", "hairGrowth",
        "adSpace", "lifeLoading", "spaceTraveler", "fullMoons", "jupiterAge", "sleep",
        "phoneVoid", "caffeineRiver", "sunsets", "passionEra", "masteryHours",
        "sharedDays", "sharedHeartbeats", "nailGrowth", "wordsRead"
    ]
    
    private let titleMap: [String: String] = [
        "secondsAlive": "Seconds Alive",
        "heartbeats": "Heartbeats",
        "breathsTaken": "Breaths Taken",
        "timesBlinked": "Times Blinked",
        "hairGrowth": "Hair Growth",
        "adSpace": "Ad Space (Mockup)",
        "lifeLoading": "Life Loading Bar",
        "spaceTraveler": "Space Traveler",
        "fullMoons": "Full Moons",
        "jupiterAge": "Jupiter Age",
        "sleep": "Sleep",
        "phoneVoid": "Phone Void",
        "caffeineRiver": "Caffeine River",
        "sunsets": "Sunsets",
        "passionEra": "Era Share",
        "masteryHours": "Mastery",
        "sharedDays": "Shared Days",
        "sharedHeartbeats": "Shared Beats",
        "nailGrowth": "Nail Growth",
        "wordsRead": "Words Read"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Drag to reorder your dashboard layout")) {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.gray)
                            Text(titleMap[item] ?? item)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.vitalzText)
                        }
                        .listRowBackground(Color.vitalzCard)
                    }
                    .onMove(perform: move)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.vitalzBackground.ignoresSafeArea())
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Rearrange Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        cardOrder = items.joined(separator: ",")
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.vitalzBlue)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        items = defaultOrder
                        cardOrder = defaultOrder.joined(separator: ",")
                    }) {
                        Text("Reset")
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                if cardOrder.isEmpty {
                    items = defaultOrder
                } else {
                    let saved = cardOrder.components(separatedBy: ",")
                    // Ensure all defaults are present (in case new cards were added)
                    let missing = defaultOrder.filter { !saved.contains($0) }
                    items = saved + missing
                }
            }
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}
