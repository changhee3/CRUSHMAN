import SwiftUI
import SwiftData
import PhotosUI          // ← 추가

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query private var entries: [MoodEntry]

    private let emojis = ["😀", "🙂", "😐", "😞", "😢", "😡", "😴", "🥰"]

    @State private var selectedEmoji: String?
    @State private var note: String = ""
    @State private var showSavedCheck = false

    // 사진 관련 상태
    @State private var pickerItem: PhotosPickerItem?
    @State private var photoData: Data?

    private var todayKey: String { MoodEntry.key(for: Date()) }
    private var todayEntry: MoodEntry? {
        entries.first { $0.dayKey == todayKey }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
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
                                HapticManager.play(for: emoji)
                            }
                    }
                }
                .padding(.horizontal)

                // 한 줄 메모
                TextField("오늘 한 마디...", text: $note)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 32)

                // 사진 첨부
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    if let photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal, 32)
                    } else {
                        Label("사진 추가", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal, 32)
                    }
                }
                .onChange(of: pickerItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            photoData = data
                        }
                    }
                }

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
            }
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
            photoData = entry.photoData
        }
    }

    private func save() {
        guard let emoji = selectedEmoji else { return }

        if let entry = todayEntry {
            entry.emoji = emoji
            entry.note = note
            entry.photoData = photoData
        } else {
            context.insert(MoodEntry(date: Date(), emoji: emoji, note: note, photoData: photoData))
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.spring) { showSavedCheck = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showSavedCheck = false }
        }
    }
}
