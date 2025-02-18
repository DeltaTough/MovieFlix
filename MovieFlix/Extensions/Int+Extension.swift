//
//  Int+Extension.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 17/02/2025.
//

import Foundation

extension Int {
    func convertRuntime() -> String {
        let hours = self / 60
        let remainingMinutes = self % 60
        return "\(hours)h \(remainingMinutes)min"
    }
}
