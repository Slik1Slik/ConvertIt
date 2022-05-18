//
//  NetworkStatusBar.swift
//  ConvertIt
//
//  Created by Slik on 11.05.2022.
//

import UIKit

class NetworkStatusBar: UIView {
    
    private var currentStatus: Status = .none
    
    private let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        if #available(iOS 14.0, *) {
            label.font = UIFont.preferredFont(from: .caption)
        } else {
            label.font = UIFont.systemFont(ofSize: 12)
        }
        label.textColor = .white
        return label
    }()
    
    private let lineActivityIndicator: RunningLineActivityIndicatorView = {
        return RunningLineActivityIndicatorView(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: UIScreen.main.bounds.width,
                                                              height: 2))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setUpConstraints()
    }
    
    init() {
        super.init(frame: .zero)
        addSubviews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate(for status: Status) {
        currentStatus = status
        switch status {
        case .dataTask:
            showActivityIndicator()
            lineActivityIndicator.startAnimating()
        case .lostConnection:
            performConnectionLostAnimation()
        case .restoredConnection:
            performConnectionRestoredAnimation()
        default: return
        }
    }
    
    func stopAnimation() {
        switch currentStatus {
        case .dataTask:
            lineActivityIndicator.stopAnimating()
        case .lostConnection:
            performStopAnimation()
        case .restoredConnection:
            performStopAnimation()
        case .none:
            return
        }
    }
    
    private func hideActivityIndicator() {
        lineActivityIndicator.alpha = 0
    }
    
    private func hideConnectonStatusControls() {
        title.alpha = 0
        backgroundColor = .clear
    }
    
    private func showActivityIndicator() {
        lineActivityIndicator.alpha = 1
    }
    
    private func showConnectonStatusControls() {
        title.alpha = 1
    }
    
    private func performConnectionLostAnimation() {
        self.title.text = "Отсутствует подключение"
        self.title.sizeToFit()
        self.lineActivityIndicator.stopAnimating()
        self.showConnectonStatusControls()
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) { [weak self] in
            self?.backgroundColor = .systemRed
        }
    }
    
    private func performConnectionRestoredAnimation() {
        self.title.text = "Подключение восстановлено"
        self.title.sizeToFit()
        self.showConnectonStatusControls()
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) { [weak self] in
            self?.backgroundColor = .systemGreen
        } completion: { [weak self] _ in
            self?.performStopAnimation(delay: 2)
            self?.hideConnectonStatusControls()
        }
    }
    
    private func performStopAnimation(delay: Double = 0) {
        UIView.animate(withDuration: 0.3, delay: delay, options: [.curveEaseOut]) { [weak self] in
            self?.hideActivityIndicator()
            self?.hideConnectonStatusControls()
        }
        self.currentStatus = .none
    }
    
    private func setUpConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        lineActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3)
        ])
        
        NSLayoutConstraint.activate([
            lineActivityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineActivityIndicator.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    private func addSubviews() {
        addSubview(title)
        addSubview(lineActivityIndicator)
    }
}

extension NetworkStatusBar {
    enum Status {
        case dataTask
        case lostConnection
        case restoredConnection
        case none
    }
}
