//
//  EnvironmentVariables.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

import Foundation

struct EnvironmentVariables {
    
    static var apiToken: String {
        "API_TOKEN".infoPlist ?? ""
    }
    
    static var apiKey: String {
        "API_KEY".infoPlist ?? ""
    }
    
}

private extension String {

    var infoPlist: String? {
        guard let value = Bundle.main.infoDictionary?[self] as? String else {
            return nil
        }
        guard !value.isEmpty else {
            return nil
        }
        return value
    }
    
}
