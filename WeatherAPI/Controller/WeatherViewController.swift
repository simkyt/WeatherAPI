//
//  ViewController.swift
//  WeatherAPI
//
//  Created by arturs.olekss on 10/11/2023.
//

import UIKit
import Alamofire
import SDWebImage
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    let apiKey:String = "e863aae720msh0e35c0ad135e211p183baejsnadedcffb2f2a"
    let apiHost:String = "weatherapi-com.p.rapidapi.com"
    let apiUrl:String = "https://weatherapi-com.p.rapidapi.com/forecast.json"
    var city: String = ""
    
    let locationManager = CLLocationManager()
    
    var currentWeather:CurrentWeather?
    private let weatherView = WeatherView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        weatherView.onCityNameChanged = { [weak self] newCity in
            self?.loadWeatherData(for: newCity)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if error == nil {
                    if let firstLocation = placemarks?[0],
                       let city = firstLocation.locality {
                        print(city)
                        self.city = city
                        self.loadWeatherData(for: city)
                    } else {
                        self.showAlert(title: "Error", message: "City was not found or there was an error fetching the weather data.")
                    }
                } else {
                    print("error:::: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:::: \(error.localizedDescription)")
    }
    
    func setupView() {
        view.backgroundColor = .secondarySystemBackground
        setupNavigationBarView()
        
        view.addSubview(weatherView)
        
        weatherView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weatherView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weatherView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            weatherView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            weatherView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBarView() {
        title = "Weather API"
        
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func loadWeatherData(for city: String){
        let headers:[String:String] = ["X-RapidAPI-Key": apiKey,
            "X-RapidAPI-Host": apiHost]
        let params:[String:String] = ["q":city]
        AF.request(apiUrl,method: .get,parameters: params,headers: HTTPHeaders(headers)).responseDecodable(of:CurrentWeather.self){
            response in
            switch response.result{
            case .success(let value):
                do{
                    self.currentWeather = value
                    if let urlString = self.currentWeather?.current.condition?.icon, var urlComponents = URLComponents(string: urlString) {
                        if urlComponents.scheme == nil {
                            urlComponents.scheme = "https"
                        }
                        if let url = urlComponents.url {
                            SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { [weak self] (image, data, error, cacheType, finished, imageURL) in
                                DispatchQueue.main.async {
                                    if let image = image {
                                        self?.weatherView.updateUI(withData: value, image: image)
                                    } else {
                                        self?.weatherView.updateUI(withData: value, image: UIImage(named: "notfound.jpg")!)
                                    }
                                    self?.updateHourlyForecast()
                                }
                            }
                        }
                    }
                }
                catch{
                    print("error::::",error)
                }
            case.failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "City was not found or there was an error fetching the weather data.")
                }
                print(error)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateHourlyForecast() {
        guard let forecastDay = currentWeather?.forecast.forecastday?.first, let hours = forecastDay.hour else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let currentHourString = dateFormatter.string(from: Date())

        guard let currentHour = Int(currentHourString) else { return }

        for i in 0..<6 {
            let targetHour = (currentHour + i) % 24
            if targetHour < hours.count {
                let hourData = hours[targetHour]
                let timeString = hourData.time?.split(separator: " ")[1] ?? ""
                let hourString = String(timeString.split(separator: ":")[0])
                if i == 0 {
                    weatherView.updateHourlyForecast(hourIndex: i, hourString: "Now", tempC: currentWeather?.current.tempC)
                } else {
                    weatherView.updateHourlyForecast(hourIndex: i, hourString: hourString, tempC: hourData.tempC)
                }
            }
        }
    }


}
    

