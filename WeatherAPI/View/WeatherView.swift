//
//  WeatherView.swift
//  WeatherAPI
//
//  Created by Simonas Kytra on 12/11/2023.
//

import UIKit

extension WeatherView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let newCity = textField.text, !newCity.isEmpty {
            onCityNameChanged?(newCity)
            cityTextField.text = ""
        }
        return true
    }
}

class WeatherView: UIView {
    let cityLabel = UILabel()
    let tempLabel = UILabel()
    let conditionLabel = UILabel()
    let conditionImage = UIImageView()
    let conditionStackView = UIStackView()
    let cityTextField = UITextField()
    
    var onCityNameChanged: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .secondarySystemBackground
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        cityTextField.translatesAutoresizingMaskIntoConstraints = false
        conditionLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionImage.translatesAutoresizingMaskIntoConstraints = false
        conditionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        cityLabel.font = UIFont.systemFont(ofSize: 35)

        cityTextField.placeholder = "Enter city name"
        cityTextField.delegate = self
        cityTextField.borderStyle = .roundedRect
        
        conditionStackView.axis = .horizontal
        conditionStackView.alignment = .center
        conditionStackView.distribution = .equalSpacing
        conditionStackView.spacing = 10
        
        tempLabel.font = UIFont.systemFont(ofSize: 65)
        conditionLabel.font = UIFont.systemFont(ofSize: 17)
        conditionImage.contentMode = .scaleAspectFit
        
        conditionStackView.addArrangedSubview(conditionLabel)
        conditionStackView.addArrangedSubview(conditionImage)
        
        addSubview(cityLabel)
        addSubview(tempLabel)
        addSubview(cityTextField)
        addSubview(conditionStackView)
        
        NSLayoutConstraint.activate([
            cityTextField.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cityTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cityTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            cityLabel.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 30),
            cityLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            tempLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 7),
            
            conditionStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            conditionStackView.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 5),
            conditionStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            conditionStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            
            conditionImage.widthAnchor.constraint(equalToConstant: 30),
            conditionImage.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    func updateUI(withData: CurrentWeather, image: UIImage) {
        UIView.animate(withDuration: 0.7, animations: {
            self.cityLabel.transform = CGAffineTransform(translationX: self.bounds.width, y: 0)
        }, completion: { _ in
            self.updateContent(withData: withData, image: image)

            self.cityLabel.transform = CGAffineTransform(translationX: -self.bounds.width, y: 0)

            UIView.animate(withDuration: 0.7) {
                self.cityLabel.transform = CGAffineTransform.identity
            }
        })

        UIView.animate(withDuration: 0.7, delay: 0.1, options: [], animations: {
            self.tempLabel.transform = CGAffineTransform(translationX: self.bounds.width, y: 0)
        }, completion: { _ in
            self.tempLabel.transform = CGAffineTransform(translationX: -self.bounds.width, y: 0)

            UIView.animate(withDuration: 0.7) {
                self.tempLabel.transform = CGAffineTransform.identity
            }
        })

        UIView.animate(withDuration: 0.7, delay: 0.2, options: [], animations: {
            self.conditionStackView.transform = CGAffineTransform(translationX: self.bounds.width, y: 0)
        }, completion: { _ in
            self.conditionStackView.transform = CGAffineTransform(translationX: -self.bounds.width, y: 0)

            UIView.animate(withDuration: 0.7) {
                self.conditionStackView.transform = CGAffineTransform.identity
            }
        })
    }

    
    func updateContent(withData: CurrentWeather, image: UIImage) {
        cityLabel.text = withData.location.name
        tempLabel.text = String(format: "%0.f°", withData.current.tempC ?? "Not found")
        conditionLabel.text = withData.current.condition?.text
        conditionImage.image = image
    }
}
