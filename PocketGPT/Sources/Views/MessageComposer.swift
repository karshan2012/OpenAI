import SwiftUI

struct MessageComposer: View {
    @Binding var text: String
    let onSend: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            TextEditor(text: $text)
                .frame(minHeight: 44, maxHeight: 120)
                .padding(8)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .padding(10)
                    .background(text.isEmpty ? Color.gray.opacity(0.3) : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .disabled(text.isEmpty)
        }
    }
}
