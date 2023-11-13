//
//  Forecast.swift
//  WeatherAPI
//
//  Created by Simonas Kytra on 13/11/2023.
//

import UIKit

struct Forecast: Codable {
    let forecastday: [Forecastday]?
}
