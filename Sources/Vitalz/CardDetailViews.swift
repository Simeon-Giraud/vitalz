import SwiftUI

// MARK: - Fun Facts & Descriptions per Card

struct CardDetailContent {
    let funFact: String
    let description: String
    let comparisons: [String]
}

extension CardData.ID {
    var detailContent: CardDetailContent {
        switch self {
        case .secondsAlive:
            return CardDetailContent(
                funFact: "A hummingbird's heart beats about 1,200 times per minute — roughly 20 beats for every second you've been alive.",
                description: "Every second is a tick on the clock of your existence. This counter has been running since the moment you took your first breath.",
                comparisons: ["⚡ Light travels 300,000 km each second", "🧬 Your body makes 3.8M cells per second", "🌍 Earth moves 30 km through space each second"]
            )
        case .heartbeats:
            return CardDetailContent(
                funFact: "A blue whale's heart is so large that a small child could crawl through its arteries. Yours is about the size of your fist.",
                description: "Your heart beats roughly 100,000 times per day, pumping about 7,500 liters of blood. It never takes a break.",
                comparisons: ["🐘 Elephant: ~30 bpm", "🐁 Mouse: ~600 bpm", "🐋 Blue Whale: ~8 bpm"]
            )
        case .breathsTaken:
            return CardDetailContent(
                funFact: "You share the air you breathe with every human who has ever lived. Each breath contains molecules once breathed by Cleopatra and Einstein.",
                description: "The average person breathes 12-20 times per minute. Each breath pulls in about 500ml of air.",
                comparisons: ["🫁 ~500ml of air per breath", "💨 ~11,000 liters of air per day", "🌳 1 tree provides oxygen for 2 people"]
            )
        case .timesBlinked:
            return CardDetailContent(
                funFact: "You blink less when reading or staring at screens — about 3-4 times per minute instead of the usual 15-20. Your eyes are essentially drying out right now.",
                description: "Each blink lasts about 0.3 seconds. Over a lifetime, you spend roughly 5 years with your eyes closed just from blinking.",
                comparisons: ["👁️ ~0.3 seconds per blink", "📱 3-4 blinks/min on screens", "😴 15-20 blinks/min normally"]
            )
        case .hairGrowth:
            return CardDetailContent(
                funFact: "If you never cut your hair, it would grow to about 1 meter before falling out naturally. The longest hair ever recorded was over 5.6 meters.",
                description: "Hair grows about 15cm per year on average. You have roughly 100,000 hairs on your head, each growing independently.",
                comparisons: ["✂️ ~15 cm/year growth", "💇 ~100,000 hairs on your head", "🧬 Hair is as strong as copper wire"]
            )
        case .spaceTraveler:
            return CardDetailContent(
                funFact: "Right now, you're hurtling through space at 107,000 km/h around the Sun. You've never been to the same point in space twice.",
                description: "Earth orbits the Sun at about 30 km/s. On top of that, the solar system orbits the Milky Way at 828,000 km/h.",
                comparisons: ["🚀 107,000 km/h around the Sun", "🌌 828,000 km/h around the galaxy", "🛸 2.1M km/h toward the Great Attractor"]
            )
        case .fullMoons:
            return CardDetailContent(
                funFact: "The Moon is slowly drifting away from Earth at 3.8 cm per year. In about 600 million years, total solar eclipses will no longer be possible.",
                description: "A full lunar cycle takes 29.5 days. The same side of the Moon always faces Earth due to tidal locking.",
                comparisons: ["🌕 29.5 days per cycle", "🌑 Only 12-13 full moons per year", "🔭 Moon drifts 3.8 cm/year away"]
            )
        case .jupiterAge:
            return CardDetailContent(
                funFact: "Jupiter is so massive it doesn't orbit the Sun — they both orbit a shared center of gravity located just outside the Sun's surface.",
                description: "A year on Jupiter is 11.86 Earth years. If you lived there, you'd celebrate far fewer birthdays.",
                comparisons: ["🪐 1 Jupiter year = 11.86 Earth years", "⚖️ Jupiter = 318x Earth's mass", "🌪️ Great Red Spot: 350+ years old"]
            )
        case .sleep:
            return CardDetailContent(
                funFact: "Dolphins sleep with one eye open — literally. One half of their brain stays awake to keep breathing and watch for predators.",
                description: "Humans spend roughly a third of their life asleep. During REM sleep, your brain is almost as active as when you're awake.",
                comparisons: ["😴 ~7-9 hrs recommended", "🧠 5-6 dream cycles per night", "🐨 Koalas sleep 22 hrs/day"]
            )
        case .phoneVoid:
            return CardDetailContent(
                funFact: "The average person touches their phone 2,617 times per day. Power users touch it over 5,400 times.",
                description: "Screen time has become a significant fraction of waking life. The average adult spends 3-4 hours per day on their phone.",
                comparisons: ["📱 ~2,617 touches/day average", "🧠 Attention span: ~8 seconds", "👆 47 minutes/day on social media"]
            )
        case .caffeineRiver:
            return CardDetailContent(
                funFact: "Coffee was discovered when an Ethiopian goat herder noticed his goats dancing after eating coffee berries. The world has never been the same.",
                description: "The average coffee drinker consumes about 3 cups per day. Caffeine has a half-life of about 5 hours in your body.",
                comparisons: ["☕ ~3 cups/day average", "⏱️ 5-hour caffeine half-life", "🌍 2.25B cups consumed daily worldwide"]
            )
        case .sunsets:
            return CardDetailContent(
                funFact: "On Mars, sunsets are blue. The fine dust in the Martian atmosphere scatters red light and lets blue light through — the opposite of Earth.",
                description: "You've witnessed one sunset for every day you've been alive. Each one is unique due to atmospheric conditions.",
                comparisons: ["🌅 1 sunset = 1 day alive", "🎨 No two sunsets are identical", "🏔️ Higher altitude = longer sunsets"]
            )
        case .passionEra:
            return CardDetailContent(
                funFact: "It takes roughly 10,000 hours of deliberate practice to achieve mastery in a complex domain — a concept popularized by Malcolm Gladwell.",
                description: "This measures what fraction of your total lifetime has been spent in this era. Every percentage point is time invested in becoming who you are.",
                comparisons: ["🎯 10,000 hours for mastery", "📈 Consistency beats intensity", "🧠 Neural pathways strengthen with repetition"]
            )
        case .masteryHours:
            return CardDetailContent(
                funFact: "Mozart had already composed over 3,500 hours of music by age 6. But even he needed thousands of hours of practice first.",
                description: "Based on your weekly dedication, this estimates your total investment. The 10,000-hour rule suggests expertise requires deep, sustained effort.",
                comparisons: ["🥇 10,000h = expert level", "📚 5,000h = advanced", "🌱 1,000h = proficient"]
            )
        case .sharedDays:
            return CardDetailContent(
                funFact: "The probability of meeting any specific person is about 1 in 20,000. You've beaten astronomical odds just by knowing them.",
                description: "Every shared day is a day your orbits around the Sun overlapped on purpose. These are the days that give life its texture.",
                comparisons: ["🎲 1 in 20,000 chance of meeting", "🤝 ~150 meaningful relationships (Dunbar's number)", "💫 You've shared sunrises and storms"]
            )
        case .sharedHeartbeats:
            return CardDetailContent(
                funFact: "When two people in love gaze into each other's eyes, their heartbeats synchronize within minutes.",
                description: "This is the combined cardiac output of both you and your person since you first met. Two hearts, beating in parallel across time.",
                comparisons: ["❤️ Two hearts beating together", "🔁 ~200,000 combined beats/day", "🫀 Hearts can sync during conversation"]
            )
        case .nailGrowth:
            return CardDetailContent(
                funFact: "Fingernails grow about 3.5mm per month — roughly 4x faster than toenails. Your dominant hand's nails grow faster than the other.",
                description: "All 20 of your nails grow independently. The total length of nail your body has produced is measured against your own height.",
                comparisons: ["💅 ~3.5mm/month for fingernails", "🦶 ~1.6mm/month for toenails", "✋ Dominant hand grows faster"]
            )
        case .wordsRead:
            return CardDetailContent(
                funFact: "The average person reads about 50 books' worth of social media content per year — without even realizing it.",
                description: "Based on your reading pace, this estimates the total words your eyes have processed since roughly age 6.",
                comparisons: ["📖 Average book: ~70,000 words", "📰 Online article: ~800 words", "🧠 We read 250 words/min on average"]
            )
        }
    }
}

// MARK: - Unique Visualizations per Card

struct CardVisualization: View {
    let cardID: CardData.ID
    let card: CardData
    @State private var animateIn = false
    
    var body: some View {
        Group {
            switch cardID {
            case .secondsAlive:
                tickingCounter
            case .heartbeats:
                pulseRing
            case .breathsTaken:
                breathingWave
            case .timesBlinked:
                blinkMeter
            case .hairGrowth:
                growthRuler
            case .spaceTraveler:
                orbitRing
            case .fullMoons:
                moonPhases
            case .jupiterAge:
                planetScale
            case .sleep:
                sleepDonut
            case .phoneVoid:
                screenTimeBars
            case .caffeineRiver:
                coffeeStack
            case .sunsets:
                sunsetGradient
            case .passionEra, .masteryHours:
                progressToMastery
            case .sharedDays, .sharedHeartbeats:
                sharedOrbit
            case .nailGrowth:
                growthRuler
            case .wordsRead:
                bookStack
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animateIn = true
            }
        }
    }
    
    // MARK: - Ticking Counter (Seconds Alive)
    private var tickingCounter: some View {
        HStack(spacing: 4) {
            ForEach(0..<6) { i in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 40, height: 56)
                    .overlay(
                        Text("\(digitAt(i))")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                    )
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(i) * 0.06), value: animateIn)
            }
        }
        .frame(height: 60)
    }
    
    private func digitAt(_ index: Int) -> Int {
        let str = card.value.filter { $0.isNumber }
        let chars = Array(str)
        let reversed = Array(chars.reversed())
        let digitIndex = 5 - index
        if digitIndex < reversed.count {
            return Int(String(reversed[digitIndex])) ?? 0
        }
        return 0
    }
    
    // MARK: - Pulse Ring (Heartbeats)
    private var pulseRing: some View {
        ZStack {
            ForEach(0..<3) { ring in
                Circle()
                    .stroke(Color.red.opacity(Double(3 - ring) * 0.15), lineWidth: 2)
                    .frame(width: CGFloat(40 + ring * 30), height: CGFloat(40 + ring * 30))
                    .scaleEffect(animateIn ? 1 : 0.3)
                    .opacity(animateIn ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(Double(ring) * 0.1), value: animateIn)
            }
            
            Image(systemName: "heart.fill")
                .font(.system(size: 24))
                .foregroundColor(.red)
                .scaleEffect(animateIn ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animateIn)
        }
        .frame(height: 110)
    }
    
    // MARK: - Breathing Wave (Breaths)
    private var breathingWave: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<20, id: \.self) { i in
                let phase = Double(i) / 20.0 * .pi * 2
                let height = 20 + sin(phase) * 15
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 1, green: 0.6, blue: 0.6).opacity(0.7))
                    .frame(width: 8, height: animateIn ? CGFloat(height) : 4)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(Double(i) * 0.03), value: animateIn)
            }
        }
        .frame(height: 50)
    }
    
    // MARK: - Blink Meter (Times Blinked)
    private var blinkMeter: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: i < 3 ? "eye" : "eye.slash")
                        .font(.system(size: 22))
                        .foregroundColor(i < 3 ? .white.opacity(0.8) : .white.opacity(0.3))
                        .scaleEffect(animateIn ? 1 : 0)
                        .animation(.spring(response: 0.4).delay(Double(i) * 0.08), value: animateIn)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 8)
                    Capsule().fill(Color(red: 1, green: 0.6, blue: 0.6))
                        .frame(width: animateIn ? geo.size.width * 0.7 : 0, height: 8)
                        .animation(.easeOut(duration: 1.0).delay(0.3), value: animateIn)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Eyes open").font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("~70% of waking hours").font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(height: 70)
    }
    
    // MARK: - Growth Ruler (Hair / Nail)
    private var growthRuler: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 28)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [card.accentColor.opacity(0.6), card.accentColor], startPoint: .leading, endPoint: .trailing))
                        .frame(width: animateIn ? geo.size.width * 0.85 : 0, height: 28)
                        .animation(.easeOut(duration: 1.2).delay(0.2), value: animateIn)
                    
                    // Ruler ticks
                    ForEach(0..<10, id: \.self) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 1, height: i % 5 == 0 ? 16 : 8)
                            .offset(x: geo.size.width * CGFloat(i) / 10.0)
                    }
                }
            }
            .frame(height: 28)
            
            HStack {
                Text("0").font(.system(size: 10, design: .monospaced)).foregroundColor(.white.opacity(0.4))
                Spacer()
                Text(card.value).font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(card.accentColor)
            }
        }
    }
    
    // MARK: - Orbit Ring (Space Traveler)
    private var orbitRing: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                .frame(width: 100, height: 100)
            
            Circle()
                .trim(from: 0, to: animateIn ? 0.75 : 0)
                .stroke(Color.blue.opacity(0.6), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.5).delay(0.2), value: animateIn)
            
            // Sun
            Circle()
                .fill(Color.yellow)
                .frame(width: 20, height: 20)
                .shadow(color: .yellow.opacity(0.6), radius: 8)
            
            // Earth dot
            Circle()
                .fill(Color.cyan)
                .frame(width: 10, height: 10)
                .offset(x: 50)
                .rotationEffect(.degrees(animateIn ? 270 : 0))
                .animation(.easeInOut(duration: 2).delay(0.2), value: animateIn)
        }
        .frame(height: 110)
    }
    
    // MARK: - Moon Phases
    private var moonPhases: some View {
        HStack(spacing: 12) {
            ForEach(Array(["🌑","🌒","🌓","🌔","🌕","🌖","🌗","🌘"].enumerated()), id: \.offset) { index, emoji in
                Text(emoji)
                    .font(.system(size: 24))
                    .scaleEffect(animateIn ? 1 : 0)
                    .opacity(animateIn ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.06), value: animateIn)
            }
        }
        .frame(height: 40)
    }
    
    // MARK: - Planet Scale (Jupiter Age)
    private var planetScale: some View {
        HStack(alignment: .bottom, spacing: 20) {
            VStack(spacing: 4) {
                Circle()
                    .fill(Color.cyan.opacity(0.6))
                    .frame(width: animateIn ? 24 : 8, height: animateIn ? 24 : 8)
                    .animation(.spring(response: 0.6).delay(0.1), value: animateIn)
                Text("Earth")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            VStack(spacing: 4) {
                Circle()
                    .fill(LinearGradient(colors: [.orange.opacity(0.8), .brown.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                    .frame(width: animateIn ? 72 : 8, height: animateIn ? 72 : 8)
                    .animation(.spring(response: 0.8).delay(0.2), value: animateIn)
                Text("Jupiter")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(height: 90)
    }
    
    // MARK: - Sleep Donut
    private var sleepDonut: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 12)
                .frame(width: 90, height: 90)
            
            Circle()
                .trim(from: 0, to: animateIn ? 0.33 : 0)
                .stroke(Color.blue.opacity(0.7), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 90, height: 90)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.2).delay(0.2), value: animateIn)
            
            VStack(spacing: 2) {
                Text("33%")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text("of life")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(height: 100)
    }
    
    // MARK: - Screen Time Bars (Phone Void)
    private var screenTimeBars: some View {
        VStack(spacing: 6) {
            let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            let values: [CGFloat] = [0.6, 0.8, 0.5, 0.9, 0.7, 1.0, 0.4]
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.opacity(0.6))
                            .frame(width: 24, height: animateIn ? 50 * values[i] : 4)
                            .animation(.spring(response: 0.5).delay(Double(i) * 0.05), value: animateIn)
                        
                        Text(labels[i])
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
        }
        .frame(height: 70)
    }
    
    // MARK: - Coffee Stack (Caffeine River)
    private var coffeeStack: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { i in
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.brown.opacity(0.3))
                            .frame(width: 36, height: 44)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [.brown, .brown.opacity(0.6)], startPoint: .bottom, endPoint: .top))
                            .frame(width: 28, height: animateIn ? CGFloat(20 + i * 5) : 4)
                            .animation(.spring(response: 0.6).delay(Double(i) * 0.08), value: animateIn)
                    }
                    
                    Text("☕")
                        .font(.system(size: 14))
                        .opacity(animateIn ? 1 : 0)
                        .animation(.easeIn.delay(Double(i) * 0.1), value: animateIn)
                }
            }
        }
        .frame(height: 70)
    }
    
    // MARK: - Sunset Gradient
    private var sunsetGradient: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [.orange, .pink, .purple, .indigo],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(height: 60)
                .opacity(animateIn ? 1 : 0)
                .animation(.easeIn(duration: 1.0).delay(0.2), value: animateIn)
            
            Circle()
                .fill(Color.yellow)
                .frame(width: 24, height: 24)
                .offset(y: animateIn ? 20 : -10)
                .animation(.easeInOut(duration: 1.5).delay(0.3), value: animateIn)
                .shadow(color: .orange.opacity(0.5), radius: 10)
        }
        .frame(height: 60)
    }
    
    // MARK: - Progress to Mastery
    private var progressToMastery: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 14)
                    
                    Capsule()
                        .fill(LinearGradient(colors: [.green.opacity(0.7), .green], startPoint: .leading, endPoint: .trailing))
                        .frame(width: animateIn ? geo.size.width * 0.35 : 0, height: 14)
                        .animation(.easeOut(duration: 1.2).delay(0.2), value: animateIn)
                }
            }
            .frame(height: 14)
            
            HStack(spacing: 0) {
                Text("0h")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Text("10,000h")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.green.opacity(0.7))
            }
        }
    }
    
    // MARK: - Shared Orbit
    private var sharedOrbit: some View {
        ZStack {
            Circle()
                .stroke(Color.cyan.opacity(0.15), lineWidth: 2)
                .frame(width: 90, height: 90)
            
            Circle()
                .fill(Color.cyan.opacity(0.8))
                .frame(width: 14, height: 14)
                .offset(x: -45)
                .rotationEffect(.degrees(animateIn ? 360 : 0))
                .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: animateIn)
            
            Circle()
                .fill(Color.pink.opacity(0.8))
                .frame(width: 14, height: 14)
                .offset(x: 45)
                .rotationEffect(.degrees(animateIn ? 360 : 0))
                .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: animateIn)
            
            Image(systemName: "heart.fill")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.4))
                .scaleEffect(animateIn ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateIn)
        }
        .frame(height: 100)
    }
    
    // MARK: - Book Stack (Words Read)
    private var bookStack: some View {
        HStack(spacing: 4) {
            ForEach(0..<8, id: \.self) { i in
                let colors: [Color] = [.blue, .cyan, .teal, .indigo, .purple, .mint, .blue, .cyan]
                RoundedRectangle(cornerRadius: 3)
                    .fill(colors[i].opacity(0.6))
                    .frame(width: animateIn ? 16 : 4, height: CGFloat(30 + i * 4))
                    .animation(.spring(response: 0.5).delay(Double(i) * 0.06), value: animateIn)
            }
        }
        .frame(height: 70)
    }
}
