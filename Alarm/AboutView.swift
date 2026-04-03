import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            // MARK: - App Info
            Section {
                HStack {
                    Text("Version")
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(Theme.textSecondary)
                }
                .listRowBackground(Theme.surface)

                HStack {
                    Text("Build")
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                        .foregroundStyle(Theme.textSecondary)
                }
                .listRowBackground(Theme.surface)
            } header: {
                Text("App")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.amber.opacity(0.7))
                    .tracking(1.5)
            }

            // MARK: - Acknowledgements
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Flip Clock Component")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)

                    Text("The split flap clock design is based on \"Flip Clock\" by Anastasiia (@a30125c9_fb9c_4), licensed under CC BY 4.0. Changes were made: adapted for SwiftUI, added flip animation, modified dimensions and styling for use as an alarm time picker.")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(2)

                    VStack(alignment: .leading, spacing: 6) {
                        Link(destination: URL(string: "https://www.figma.com/community/file/1533113961439163674")!) {
                            HStack(spacing: 4) {
                                Text("View original work")
                                    .font(.caption.weight(.medium))
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                            }
                            .foregroundStyle(Theme.amber)
                        }

                        Link(destination: URL(string: "https://creativecommons.org/licenses/by/4.0/")!) {
                            HStack(spacing: 4) {
                                Text("CC BY 4.0 License")
                                    .font(.caption.weight(.medium))
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                            }
                            .foregroundStyle(Theme.amber)
                        }
                    }
                }
                .padding(.vertical, 4)
                .listRowBackground(Theme.surface)
            } header: {
                Text("Acknowledgements")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.amber.opacity(0.7))
                    .tracking(1.5)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.dark)
}
