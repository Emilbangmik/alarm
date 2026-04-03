import SwiftUI
import WidgetKit
import AlarmKit

nonisolated struct AlarmMeta: AlarmMetadata {}

struct AlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<AlarmMeta>.self) { context in
            // Lock screen presentation
            HStack {
                Image(systemName: "alarm.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    if case let .countdown(countdown) = context.state.mode {
                        Text(timerInterval: Date.now...countdown.fireDate)
                            .font(.title2.monospacedDigit().bold())
                            .foregroundStyle(.white)
                    }

                    if case .alert = context.state.mode {
                        Text("Alarm")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }
                }

                Spacer()
            }
            .padding()
            .activityBackgroundTint(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "alarm.fill")
                        .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if case let .countdown(countdown) = context.state.mode {
                        Text(timerInterval: Date.now...countdown.fireDate)
                            .monospacedDigit()
                            .foregroundStyle(.white)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {}
            } compactLeading: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                if case let .countdown(countdown) = context.state.mode {
                    Text(timerInterval: Date.now...countdown.fireDate)
                        .monospacedDigit()
                }
            } minimal: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}
