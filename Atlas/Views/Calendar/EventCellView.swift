import SwiftUI

/// Compact colored pill shown inside each calendar day cell.
struct EventCellView: View {

    @EnvironmentObject var theme: ColorTheme
    let event: Event

    private var color: Color { theme.color(for: event.eventColor) }

    private var timeText: String? {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        if event.category == .work, event.workSubType == .event,
           let s = event.startTime, let e = event.endTime {
            return "\(f.string(from: s)) – \(f.string(from: e))"
        }
        if let t = event.time { return f.string(from: t) }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            // Title
            Text(event.displayTitle)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)

            // Subject (school only)
            if let subject = event.subjectName {
                Text(subject)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            // Time
            if let t = timeText {
                Text(t)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }

            // Basketball tag dots
            if event.workSubType == .basketball, event.hasRopero || event.hasPostres {
                HStack(spacing: 3) {
                    if event.hasRopero  { tagDot(theme.roperoTag) }
                    if event.hasPostres { tagDot(theme.postresTag) }
                }
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color)
        .cornerRadius(5)
        .padding(.horizontal, 2)
    }

    private func tagDot(_ color: Color) -> some View {
        Circle().fill(color).frame(width: 5, height: 5)
    }
}
