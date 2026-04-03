import SwiftUI
import WidgetKit

struct OpenAppControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "OpenSlap") {
            ControlWidgetButton(action: OpenAppIntent()) {
                Label("Slap", systemImage: "alarm.fill")
            }
        }
        .displayName("Open Slap")
        .description("Open the Slap alarm app.")
    }
}
