//
//  String+Extension.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 14/02/2025.
//

import Foundation

extension String {
    func formatDate() -> Self? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
    
        if let date = inputFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMMM yyyy"
            return outputFormatter.string(from: date)
        }
        return nil
    }
}


