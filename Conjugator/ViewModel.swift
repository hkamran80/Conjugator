//
//  ViewModel.swift
//  Conjugator
//
//  Created by A. Zheng (github.com/aheze) on 10/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class ViewModel: ObservableObject {
    let maximumCoursesToDisplay = 6
    @Published var showingDetails = false
    @Published var showingAllCoursesView = false

    @Published var isLoading = true
    @Published var courses = [Course]()
    @Published var selectedCourse: Course?
    @Published var selectedLevel: Level?

    // MARK: - Data Persistence

    @AppStorage("dataSources") @Storage var dataSources = ["1t-onBgRP5BSHZ26XjvmVgi6RxZmpKO7RBI3JARYE3Bs"]
    @AppStorage("selectedDataSource") var selectedDataSource = "1t-onBgRP5BSHZ26XjvmVgi6RxZmpKO7RBI3JARYE3Bs"

    func loadLevels() async {
        var courses = [Course]()

        for dataSource in dataSources {
            if let course = await getCourse(from: dataSource) {
                courses.append(course)
            }
        }

        await { @MainActor in
            withAnimation(.spring(response: 0.4, dampingFraction: 1, blendDuration: 1)) {
                isLoading = false
                if courses.isEmpty {
                    showingDetails = true
                } else {
                    let selectedCourse = courses.first(where: { $0.dataSource == self.selectedDataSource }) ?? courses.first
                    self.courses = courses
                    self.selectedCourse = selectedCourse
                }
            }
        }()
    }
}
