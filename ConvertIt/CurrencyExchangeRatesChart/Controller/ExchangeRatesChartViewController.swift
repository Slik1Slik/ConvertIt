//
//  ExchangeRatesChartViewController.swift
//  ConvertIt
//
//  Created by Slik on 02.06.2022.
//

import UIKit

class ExchangeRatesChartViewController: UIViewController {
    
    let chartView = LineChartView()
    
    let closeVCButton: DefaultApplicationButton = DefaultApplicationButton(style: .regular)
    
    private var rates: [DailyExchangeRate] = []
    
    init(rates: [DailyExchangeRate]) {
        super.init(nibName: nil, bundle: nil)
        
        self.rates = rates
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        addSubviews()
        setUpConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setUpChartView()
        setUpCloseVCButton()
    }
    
    private func addSubviews() {
        self.view.addSubview(chartView)
        self.view.addSubview(closeVCButton)
    }
    
    private func setUpConstraints() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        closeVCButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            chartView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            chartView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            chartView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        NSLayoutConstraint.activate([
            closeVCButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            closeVCButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
        ])
    }
    
    private func setUpChartView() {
        
        let frame = CGRect(x: 0,
                           y: self.view.frame.height / 2 - 150,
                           width: self.view.frame.width,
                           height: 300)
        
        
        chartView.frame = frame
        chartView.drawChart(for: rates.map { $0.rate })
    }
    
    private func setUpCloseVCButton() {
        closeVCButton.configure(imageName: "xmark.circle.fill")
        closeVCButton.tintColor = .gray
        closeVCButton.addTarget(self, action: #selector(closeVCButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeVCButtonTapped() {
        self.dismiss(animated: true)
    }
}
