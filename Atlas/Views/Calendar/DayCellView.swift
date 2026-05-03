import SwiftUI

struct DayCellView: View {

    let date: Date
    let events: [Event]
    @EnvironmentObject var theme: ColorTheme
    let isToday: Bool
    let onTapEvent: (Event) -> Void
    let onTapDay: (Date) -> Void

    private let maxVisible = 2

    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {

            // Day number
            HStack {
                Text("\(dayNumber)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isToday ? .white : .primary)
                    .frame(width: 22, height: 22)
                    .background(isToday ? theme.accent : Color.clear)
                    .clipShape(Circle())
                    .padding(.leading, 4)
                Spacer()
            }
            .padding(.top, 4)

            // Visible events
            let visible = Array(events.prefix(maxVisible))
            let overflow = events.count - visible.count

            ForEach(visible) { event in
                EventCellView(event: event)
                    .onTapGesture { onTapEvent(event) }
            }

            if overflow > 0 {
                Text("+\(overflow) more")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.leading, 6)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .contentShape(Rectangle())
        .onTapGesture { onTapDay(date) }
    }
}
