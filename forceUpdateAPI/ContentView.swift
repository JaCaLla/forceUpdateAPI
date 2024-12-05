//
//  ContentView.swift
//  forceUpdateAPI
//
//  Created by Javier Calatrava on 4/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var responseText: String = "Press button for making request."

    var body: some View {
        VStack(spacing: 20) {
            Text("Backend answer:")
                .font(.headline)
            
            Text(responseText)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
        .padding()
        .onAppear {
            Task {
                switch await SampleService().sample() {
                case .success(let versionResponseDTO):
                    let marketingVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                    let isLatest = versionResponseDTO.currentVersion == marketingVersion
                    responseText = "\( isLatest ? "UPDATED LATEST VERSION!" : "NOT LATEST VERSION, COULD UPDATE")"
                case .failure(let err):
                    if err.localizedDescription == ErrorService.upgradeRequired.localizedDescription {
                        responseText = "UPGRADE REQUIRED!!!"
                    } else {
                        responseText = "Error: \(err)"
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
