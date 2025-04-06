//
//  SettingsView.swift
//  mindplay
//
//  Created for MindPlay app.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("语言 / Language")) {
                    ForEach(AppLanguage.allCases) { language in
                        Button(action: {
                            languageManager.setLanguage(language)
                        }) {
                            HStack {
                                Text(language.displayName)
                                Spacer()
                                if languageManager.currentLanguage == language {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(header: Text(LocalizedStringKey.aboutTheApp.localized)) {
                    HStack {
                        Text(LocalizedStringKey.version.localized)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(LocalizedStringKey.developer.localized)
                        Spacer()
                        Text("蔡佳伟")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey.settings.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey.done.localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager())
}
