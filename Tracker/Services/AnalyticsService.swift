//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Aleksei Frolov on 07.01.2025.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(
            apiKey: "d89fb769-586f-4138-8d76-0ddfb7885f53"
        ) else {
            return
        }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func logEvent(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]
        if let item = item {
            params["item"] = item
        }
        
        YMMYandexMetrica.reportEvent("user_action", parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
        
        print("Event: \(event), Screen: \(screen), Item: \(item ?? "None")")
    }
}
