//
//  WeatherManager.swift
//  Clima
//
//  Created by David Alejandro Ijaji Guerrero on 25/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager ,weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid={ADD_API_KEY}&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeatherCity(cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        let normalized = urlString.folding(options: .diacriticInsensitive, locale: .current)
        performRequest(with: normalized)
    }
    func performRequest(with urlString:String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data{
                    if let weather = parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self,weather:weather)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch{
            print(error)
            return nil
        }
    }

}
