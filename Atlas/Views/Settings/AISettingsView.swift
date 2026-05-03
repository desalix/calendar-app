import SwiftUI

struct AISettingsView: View {

    @State private var draftKey:   String = ""
    @State private var isRevealed: Bool   = false
    @State private var saved:      Bool   = false

    var body: some View {
        List {
            Section {
                HStack {
                    Group {
                        if isRevealed {
                            TextField("Paste API key here", text: $draftKey)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        } else {
                            SecureField("Paste API key here", text: $draftKey)
                        }
                    }
                    .font(.system(.body, design: .monospaced))

                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    KeychainHelper.apiKey = draftKey.trimmingCharacters(in: .whitespaces)
                    saved = true
                } label: {
                    Text("Save Key")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(draftKey.trimmingCharacters(in: .whitespaces).isEmpty)

                if KeychainHelper.apiKey != nil {
                    Button(role: .destructive) {
                        KeychainHelper.clear()
                        draftKey = ""
                        saved    = false
                    } label: {
                        Text("Remove Saved Key")
                            .frame(maxWidth: .infinity)
                    }
                }
            } header: {
                Text("Gemini API Key")
            } footer: {
                Text("Get a free key at aistudio.google.com → Get API key. The key is stored in your device's secure Keychain and never leaves it.")
            }

            if KeychainHelper.apiKey != nil {
                Section {
                    Label("API key is saved", systemImage: "checkmark.shield.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("AI")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if let existing = KeychainHelper.apiKey { draftKey = existing }
        }
        .alert("Key saved", isPresented: $saved) {
            Button("OK", role: .cancel) {}
        }
    }
}
