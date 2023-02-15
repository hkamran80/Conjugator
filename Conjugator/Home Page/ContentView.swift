//
//  ContentView.swift
//  Conjugator
//
//  Created by A. Zheng (github.com/aheze) on 10/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = ViewModel()

    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack {
                if let selectedLevel = model.selectedLevel {
                    levelHeader(selectedLevel: selectedLevel)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: model.showingDetails ? 12 : 2) {
                                Text("Conjugator")
                                    .font(.title.weight(.heavy))

                                VStack(alignment: .leading, spacing: 8) {
                                    if model.showingDetails {
                                        Text("My Courses")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }

                                    courses
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)) {
                                    model.showingDetails.toggle()
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .fontWeight(.heavy)
                                    .rotationEffect(.degrees(model.showingDetails ? 90 : 0))
                                    .frame(width: 42, height: 42)
                                    .background {
                                        Circle()
                                            .fill(Color.white.opacity(0.1))
                                    }
                            }
//                        https://docs.google.com/spreadsheets/d/1t-onBgRP5BSHZ26XjvmVgi6RxZmpKO7RBI3JARYE3Bs/edit#gid=0
                        }

                        announcement
                    }
                    .foregroundColor(.white)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                let color: Color = {
                    if let selectedLevel = model.selectedLevel, let hex = selectedLevel.colorHex {
                        return UIColor(hex: hex).getTextColor(backgroundIsDark: false).color
                    } else {
                        return Color.blue
                    }
                }()

                color
                    .ignoresSafeArea()
            }

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            Task {
                await model.loadLevels()
            }
        }
    }
}

extension ContentView {
    var courses: some View {
        VStack(spacing: 6) {
            ForEach(model.courses, id: \.dataSource) { course in
                let name = course.name ?? "Untitled Course"

                Button {
                    model.selectedDataSource = course.dataSource
                } label: {
                    HStack {
                        Text(name)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if model.selectedDataSource == course.dataSource {
                            Image(systemName: "checkmark")
                                .opacity(model.showingDetails ? 1 : 0)
                        }
                    }
                    .opacity(model.showingDetails ? 1 : 0.75)
                    .padding(.horizontal, model.showingDetails ? 16 : 0)
                    .padding(.vertical, model.showingDetails ? 12 : 0)
                    .background(
                        Color.white
                            .opacity(0.1)
                            .cornerRadius(16)
                            .opacity(model.showingDetails ? 1 : 0)
                    )
                }
            }

            if model.showingDetails {
                Button {
//                    model.selectedDataSource = course.dataSource
                } label: {
                    HStack {
                        Text("Add Course")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "plus")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Color.white
                            .opacity(0.1)
                            .cornerRadius(16)
                    )
                }
            }
        }
    }

    @ViewBuilder var announcement: some View {
        if !model.showingDetails, let announcement = model.selectedCourse?.announcement {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    if let announcementTitle = model.selectedCourse?.announcementTitle {
                        Text(announcementTitle)
                            .textCase(.uppercase)
                            .font(.caption)
                    }

                    Text(announcement)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: "person.wave.2.fill")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .transition(.scale(scale: 0.8, anchor: .bottom).combined(with: .opacity))
        }
    }
}

extension ContentView {
    func levelHeader(selectedLevel: Level) -> some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)) {
                    model.selectedLevel = nil
                }
            } label: {
                Image(systemName: "chevron.backward")

                    .fontWeight(.medium)
                    .padding(.trailing, 16)
                    .padding(.vertical, 16)
                    .contentShape(Rectangle())
                    .font(.title3)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .overlay {
            Text(selectedLevel.title)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
    }

    @ViewBuilder var content: some View {
        if let selectedLevel = model.selectedLevel {
            LevelView(model: model, level: selectedLevel)
                .transition(.offset(x: 20).combined(with: .opacity))
        } else {
            VStack {
                if let levels = model.selectedCourse?.levels {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(levels, id: \.title) { level in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)) {
                                        model.selectedLevel = level
                                    }
                                } label: {
                                    LevelCardView(level: level)
                                }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        Task {
                            await model.loadLevels()
                        }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(UIColor.secondarySystemBackground.color)
            .transition(.offset(x: -20).combined(with: .opacity))
        }
    }
}
