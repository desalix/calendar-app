import SwiftUI
import SwiftData

struct ChatView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.timestamp) private var messages: [ChatMessage]

    @EnvironmentObject var theme: ColorTheme
    @State private var vm = ChatViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messageList
                Divider()
                inputBar
            }
            .background(theme.background)
            .navigationTitle("Atlas AI")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if messages.isEmpty {
                        emptyState
                    }
                    ForEach(messages) { message in
                        ChatBubbleView(message: message)
                            .id(message.id)
                    }
                    if vm.isLoading {
                        typingIndicator
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
            .onChange(of: messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: vm.isLoading) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if let last = messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message…", text: $vm.inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(22)
                .lineLimit(1...6)
                .accessibilityIdentifier("messageInput")

            Button {
                vm.send(context: modelContext)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(vm.inputText.isEmpty || vm.isLoading
                                     ? .gray.opacity(0.4)
                                     : theme.accent)
            }
            .disabled(vm.inputText.isEmpty || vm.isLoading)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white)
    }

    // MARK: - Accessories

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 44))
                .foregroundColor(.secondary.opacity(0.35))
            Text("Ask Atlas anything about your calendar.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.secondary.opacity(0.5))
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(theme.aiBubble)
            .cornerRadius(18)
            Spacer()
        }
    }
}

// MARK: - Bubble

struct ChatBubbleView: View {

    @EnvironmentObject var theme: ColorTheme
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isUser { Spacer(minLength: 52) }

            Text(message.content)
                .font(.body)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isUser ? theme.userBubble : theme.aiBubble)
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(18)

            if !message.isUser { Spacer(minLength: 52) }
        }
    }
}
