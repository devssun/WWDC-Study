//
//  UserData.swift
//  Landmarks
//
//  Created by 최혜선 on 2020/03/01.
//  Copyright © 2020 jamie. All rights reserved.
//

import SwiftUI
import Combine

final class UserData: ObservableObject {
    @Published var showFavoritesOnly = false
    @Published var landmarks = landmarkData
}
