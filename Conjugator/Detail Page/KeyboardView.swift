//
//  KeyboardView.swift
//  Conjugator
//
//  Created by A. Zheng (github.com/aheze) on 1/26/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

struct KeyboardView: View {
    @ObservedObject var levelViewModel: LevelViewModel

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    var body: some View {
        switch levelViewModel.keyboardMode {
        case .blank:
            EmptyView()
        case .info:
            VStack(spacing: 16) {
                Text(levelViewModel.level.title)
                    .font(.headline.bold())

                Text(levelViewModel.level.description)
            }
        case .choices(choices: let choices):
            VStack(alignment: .leading) {
                Text("Seleccione una opción.")
                    .font(.headline.bold())

                LazyVGrid(columns: columns) {
                    ForEach(choices) { choice in

                        Button {
                            //                        levelViewModel.submitChoice(conversation: conversation, message: message, choice: choice)
                        } label: {
                            Text(choice.text)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(16)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        Color.clear
    }
}
