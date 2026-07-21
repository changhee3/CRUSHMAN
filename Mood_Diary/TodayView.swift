import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context

    // 오늘 기록이 이미 있는지 조회
    @Query private var entries: [MoodEntry]

    private let emojis = ["😀", "🙂", "😐", "😞", "😢", "😡", "😴", "🥰"]

    @State private var selectedEmoji: String?
    @State private var note: String = ""
    @State private var showSavedCheck = false

    private var todayKey: String { MoodEntry.key(for: Date()) }
    private var todayEntry: MoodEntry? {
        entries.first { $0.dayKey == todayKey }
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("오늘 기분 어때?")
                .font(.title.bold())
                .padding(.top, 40)

            // 이모지 선택
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .font(.system(size: 44))
                        .scaleEffect(selectedEmoji == emoji ? 1.35 : 1.0)
                        .opacity(selectedEmoji == nil || selectedEmoji == emoji ? 1 : 0.4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: selectedEmoji)
                        .onTapGesture {
                            selectedEmoji = emoji
                            let haptic = UIImpactFeedbackGenerator(style: .medium)
                            haptic.impactOccurred()
                        }
                }
            }
            .padding(.horizontal)

            // 한 줄 메모
            TextField("오늘 한 마디...", text: $note)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 32)

            // 저장 버튼
            Button {
                save()
            } label: {
                Text(todayEntry == nil ? "저장" : "수정")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedEmoji == nil ? Color.gray.opacity(0.3) : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selectedEmoji == nil)
            .padding(.horizontal, 32)

            Spacer()
        }
        .overlay {
            if showSavedCheck {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear(perform: loadTodayIfExists)
    }

    private func loadTodayIfExists() {
        if let entry = todayEntry {
            selectedEmoji = entry.emoji
            note = entry.note
        }
    }

    private func save() {
        guard let emoji = selectedEmoji else { return }

        if let entry = todayEntry {
            entry.emoji = emoji          // 오늘 기록 수정
            entry.note = note
        } else {
            context.insert(MoodEntry(date: Date(), emoji: emoji, note: note))
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        withAnimation(.spring) { showSavedCheck = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showSavedCheck = false }
        }
    }
}
