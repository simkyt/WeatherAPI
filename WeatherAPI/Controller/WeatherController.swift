//
//  ViewController.swift
//  WeatherAPI
//
//  Created by arturs.olekss on 10/11/2023.
//

import UIKit
import Alamofire

class WeatherViewContoller: UIViewController {

    let apiKey:String = "0a31113ee6344fcebdd190629231211"
    let apiHost:String = "weatherapi-com.p.rapidapi.com"
    let apiUrl:String = "https://weatherapi-com.p.rapidapi.com/current.json"
    let city: String = "Riga"
    
    var currentWeather:CurrentWeather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeatherData()
    }
    
    func loadWeatherData(){
        let headers:[String:String] = ["X-RapidAPI-Key": apiKey,
            "X-RapidAPI-Host": apiHost]
        let params:[String:String] = ["q":city]
        AF.request(apiUrl,method: .get,parameters: params,headers: HTTPHeaders(headers)).responseDecodable(of:CurrentWeather.self){
            response in
            switch response.result{
            case .success(let value):
                do{
                    self.currentWeather = value
                }
                catch{
                    print("error::::",error)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    


}

