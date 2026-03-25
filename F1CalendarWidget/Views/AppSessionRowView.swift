import SwiftUI

struct AppSessionRowView: View {
    let session: Session

    private var isCompleted: Bool {
        guard let end = session.endDate else { return false }
        return end < Date()
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(session.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.f1Text)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isCompleted {
                Text("COMPLETED")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.f1SecondaryText)
                    .frame(width: 72, alignment: .leading)
            } else {
                Text(session.day)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.f1SecondaryText)
                    .frame(width: 95, alignment: .leading)
            }

            if session.isLive {
                Text("LIVE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color.f1Red))
                    .frame(width: 100, alignment: .trailing)
            } else {
                Text(session.time)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.f1Text)
                    .frame(width: 100, alignment: .trailing)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 10)
        .opacity(isCompleted ? 0.45 : 1.0)
    }
}

// MARK: - Previews

#Preview("Upcoming") {
    VStack(spacing: 0) {
        ForEach(Array(F1Calendar.fallbackRaces[2].sessions.enumerated()), id: \.offset) { _, session in
            AppSessionRowView(session: session)
        }
    }
    .background(Color("f1Background"))
    .preferredColorScheme(.dark)
}

#Preview("Live FP1") {
    VStack(spacing: 0) {
        ForEach(Array(Race.previewLive.sessions.enumerated()), id: \.offset) { _, session in
            AppSessionRowView(session: session)
        }
    }
    .background(Color("f1Background"))
    .preferredColorScheme(.dark)
}
