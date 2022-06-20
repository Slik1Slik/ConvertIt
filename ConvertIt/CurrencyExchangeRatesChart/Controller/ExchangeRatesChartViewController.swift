//
//  ExchangeRatesChartViewController.swift
//  ConvertIt
//
//  Created by Slik on 02.06.2022.
//

import UIKit

class ExchangeRatesChartViewController: UIViewController {
    
    let chartView = LineChartView()
    
    let closeVCButton: DefaultApplicationButton = DefaultApplicationButton(style: .small)
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentMode = .center
        scrollView.decelerationRate = .fast
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()
    
    let chartBottomBar: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    let chartSideBar: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    let getToCurrentRateOnChartButton: DefaultApplicationButton = .init(style: .extraSmall)
    
    private let chartBordersLayer: CAShapeLayer = CAShapeLayer()
    
    var selection: Selection = .year
    
    private var lastDeviceOrientation: UIDeviceOrientation = .unknown
    
    private var screen: CGRect {
        return UIScreen.main.bounds
    }
    
    private let window: UIWindow = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return UIWindow() }
        
        return UIWindow(windowScene: windowScene)
    }()
    
    private let padding: CGFloat = 20
    private let contentInset: CGFloat = 16
    private let groupedContentInset: CGFloat = 8
    
    private var rates: [DailyExchangeRate] = []
    
    init(rates: [DailyExchangeRate]) {
        super.init(nibName: nil, bundle: nil)
        
        self.rates = rates.sorted(by: { $0.date < $1.date })
        
        self.startObservingOrientationChanges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopObservingOrientationChanges()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpChartView()
        layoutChartView()
        
        setUpChartBottomBar()
        setUpChartSideBar()
        
        layoutScrollViewContent()
        setUpScrollView()
        
        setUpCloseVCButton()
        
        setUpGetToCurrentRateOnChartButton()
        
        setUpConstraints()
        
        drawChartBorders()
    }
    
    private func addSubviews() {
        self.view.addSubview(chartView)
        self.view.addSubview(chartBottomBar)
        self.view.addSubview(scrollView)
        self.view.addSubview(closeVCButton)
        self.view.addSubview(chartSideBar)
        self.view.addSubview(getToCurrentRateOnChartButton)
    }
    
    private func setUpChartView() {
        chartView.values = rates.map { $0.rate }
    }
    
    private func setUpChartBottomBar() {
        chartBottomBar.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for label in generateMonthLabels() {
            chartBottomBar.addArrangedSubview(label)
        }
        chartBottomBar.frame.size = CGSize(width: chartBottomBar.arrangedSubviews.first!.frame.width * CGFloat(chartBottomBar.arrangedSubviews.count),
                                           height: chartBottomBar.arrangedSubviews.first!.frame.height)
        chartBottomBar.alignment = .top
        chartBottomBar.distribution = .equalSpacing
        chartBottomBar.spacing = chartView.xStep * 30 - chartBottomBar.arrangedSubviews.first!.frame.width
    }
    
    private func setUpScrollView() {
        scrollView.addSubview(chartView)
        scrollView.addSubview(chartBottomBar)
        scrollView.contentMode = .top
        scrollView.contentOffset.x = chartView.frame.width
        scrollView.contentInset = UIEdgeInsets(top: 0, left: groupedContentInset, bottom: 0, right: groupedContentInset)
        scrollView.delegate = self
    }
    
    private func generateMonthLabels() -> [UILabel] {
        var labels: [UILabel] = []
        
        var labelFont = UIFont()
        
        if #available(iOS 14.0, *) {
            labelFont = UIFont.preferredFont(from: .footnote)
        } else {
            labelFont = UIFont.systemFont(ofSize: 13)
        }
        
        var maxLabelWidth: CGFloat = 0
        
        for dateLabel in monthAndYearLabels() {
            let label = UILabel()
            label.font = labelFont
            label.text = dateLabel
            label.sizeToFit()
            label.layoutSubviews()
            if maxLabelWidth < label.frame.width {
                maxLabelWidth = label.frame.width
            }
            label.frame.size = CGSize(width: maxLabelWidth, height: label.frame.size.height)
            labels.append(label)
        }
        
        return labels
    }
    
    private func datesOfMonths() -> [Date] {
        guard !rates.isEmpty,
              let firstDateDayNumber = rates.first!.date.dayNumber,
              let lastDateDayNumber = rates.last!.date.dayNumber
        else { return [] }
        
        let dates = rates.map { $0.date }
        
        let interval = DateInterval(start: dates.first!, end: dates.last!)
        let components = DateComponents(day: firstDateDayNumber > lastDateDayNumber ? firstDateDayNumber : lastDateDayNumber)
        var result = DateConstants.calendar.generateDates(inside: interval,
                                                    matching: components)
        if firstDateDayNumber > lastDateDayNumber {
            result.append(dates.last!)
        } else if lastDateDayNumber > firstDateDayNumber {
            result.append(dates.first!)
            result.swapAt(result.endIndex, result.startIndex)
        }
        return result
    }
    
    private func monthAndYearLabels() -> [String] {
        let datesOfMonths = datesOfMonths()
        
        var monthAndYearLabels: [String] = []
        
        for index in 1..<datesOfMonths.count {
            
            if datesOfMonths[index].yearNumber != datesOfMonths[index - 1].yearNumber {
                monthAndYearLabels.append(datesOfMonths[index].yearNumber!.description)
            } else {
                monthAndYearLabels.append(datesOfMonths[index].monthSymbol(.shortStandaloneMonthSymbol).capitalized)
            }
        }
        
        return monthAndYearLabels
    }
    
    private func setUpChartSideBar() {
        chartSideBar.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for label in generateRateLabels() {
            chartSideBar.addArrangedSubview(label)
        }
        chartSideBar.axis = .vertical
        chartSideBar.alignment = .trailing
        chartSideBar.distribution = .equalSpacing
    }
    
    private func generateRateLabels() -> [UILabel] {
        var labels: [UILabel] = []
        
        let allRates = rates.map { $0.rate }
        
        let keyRates: [Double] = [
            allRates.min() ?? 0,
            allRates[allRates.count / 2],
            allRates.max() ?? 0
        ]
        
        for rate in keyRates {
            let label = UILabel()
            label.text = "\(rate)".prefix(6).description
            label.font = UIFont.systemFont(ofSize: 13)
            label.sizeToFit()
            labels.append(label)
        }
        
        return labels
    }
    
    private func setUpCloseVCButton() {
        closeVCButton.configure(imageName: "xmark.circle.fill")
        closeVCButton.tintColor = .gray
        closeVCButton.addTarget(self, action: #selector(closeVCButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeVCButtonTapped() {
        self.dismiss(animated: true)
    }
    
    private func setUpGetToCurrentRateOnChartButton() {
        getToCurrentRateOnChartButton.isHidden = true
        getToCurrentRateOnChartButton.configure(imageName: "chevron.right.circle.fill")
        getToCurrentRateOnChartButton.tintColor = .gray
        getToCurrentRateOnChartButton.addTarget(self, action: #selector(getToCurrentRateOnChartButtonTapped), for: .touchUpInside)
    }
    
    @objc private func getToCurrentRateOnChartButtonTapped() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear]) { [weak self] in
            guard let self = self else { return }
            self.scrollView.contentOffset.x = self.chartView.point(forIndex: self.rates.count-1).x - self.scrollView.frame.maxX
        }
    }
}

//MARK: - Constraints
extension ExchangeRatesChartViewController {
    
    private func setUpConstraints() {
        setUpCloseVCButtonConstraints()
        setUpScrollViewConstraints()
        setUpChartViewConstraints()
        setUpSideBarConstraints()
        setUpBottomBarConstraints()
        setUpGetToCurrentRateOnChartButtonConstraints()
    }
    
    private func setUpScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: closeVCButton.bottomAnchor, constant: contentInset),
            scrollView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -padding),
        ])
    }
    
    private func setUpChartViewConstraints() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            chartView.bottomAnchor.constraint(equalTo: chartBottomBar.topAnchor, constant: groupedContentInset),
            chartView.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        ])
    }
    
    private func setUpCloseVCButtonConstraints() {
        closeVCButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeVCButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -padding),
            closeVCButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: padding),
        ])
    }
    
    private func setUpBottomBarConstraints() {
        chartBottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        chartBottomBar.topAnchor.constraint(equalTo: chartSideBar.bottomAnchor, constant: groupedContentInset).isActive = true
    }
    
    private func setUpSideBarConstraints() {
        chartSideBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartSideBar.topAnchor.constraint(equalTo: scrollView.topAnchor),
            chartSideBar.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -groupedContentInset-chartBottomBar.frame.height),
            chartSideBar.leftAnchor.constraint(equalTo: scrollView.rightAnchor, constant: groupedContentInset),
            chartSideBar.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -padding)
        ])
    }
    
    private func setUpGetToCurrentRateOnChartButtonConstraints() {
        getToCurrentRateOnChartButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            getToCurrentRateOnChartButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -padding),
            getToCurrentRateOnChartButton.topAnchor.constraint(equalTo: chartSideBar.bottomAnchor, constant: 1),
            getToCurrentRateOnChartButton.leftAnchor.constraint(equalTo: scrollView.rightAnchor, constant: groupedContentInset),
        ])
    }
}

//MARK: - Selection
extension ExchangeRatesChartViewController {
    
    enum Selection {
        case year
        case month
    }
}

//MARK: - Chart view layout
extension ExchangeRatesChartViewController {
    
    private func layoutChartView() {
        chartView.frame = chartViewRect()
        chartView.drawChart()
        //chartView.setBorders([.all], type: .infinite)
    }
    private func chartViewRect() -> CGRect {
        let height = screen.height - padding * 2 - contentInset * 2 - ApplicationButtonStyle.small.pointSize - groupedContentInset - window.safeAreaInsets.top - window.safeAreaInsets.bottom
        
        return CGRect(x: 0,
                      y: 0,
                      width: 0,
                      height: height)
    }
    
    private func layoutScrollViewContent() {
        scrollView.contentSize = CGSize(width: chartView.frame.size.width,
                                        height: chartView.frame.height + groupedContentInset + contentInset)
    }
}

//MARK: - Observe orientation changes
extension ExchangeRatesChartViewController {
    
    private func startObservingOrientationChanges() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        self.lastDeviceOrientation = UIDevice.current.orientation
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleOrientationDidChangeNotification),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    @objc private func handleOrientationDidChangeNotification() {
        guard lastDeviceOrientation != UIDevice.current.orientation else { return }
        
        lastDeviceOrientation = UIDevice.current.orientation
        
        layoutChartView()
        
        layoutScrollViewContent()
        
        drawChartBorders()
    }
    
    private func stopObservingOrientationChanges() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Chart borders layer
extension ExchangeRatesChartViewController {
    
    private func drawChartBorders() {
        
        chartBordersLayer.path = chartBordersPath().cgPath
        chartBordersLayer.fillColor = UIColor.clear.cgColor
        chartBordersLayer.strokeColor = UIColor.separator.cgColor
        chartBordersLayer.lineWidth = 1
        self.view.layer.addSublayer(chartBordersLayer)
    }
    
    private func chartBordersPath() -> UIBezierPath {
        
        let path = UIBezierPath()
        
        let topBorderYPoint = window.safeAreaInsets.top + padding + ApplicationButtonStyle.small.pointSize + contentInset
        path.move(to: CGPoint(x: 0,
                              y: topBorderYPoint))
        path.addLine(to: CGPoint(x: screen.maxX,
                                 y: topBorderYPoint))
        
        let rightBorderXPoint = screen.maxX - padding - chartSideBar.arrangedSubviews[0].frame.width - window.safeAreaInsets.right - groupedContentInset
        let rightBorderYPoint = screen.maxY - window.safeAreaInsets.bottom - chartBottomBar.frame.height - groupedContentInset - padding
        path.move(to: CGPoint(x: rightBorderXPoint,
                              y: topBorderYPoint))
        path.addLine(to: CGPoint(x: rightBorderXPoint,
                                 y: rightBorderYPoint))
        
        path.move(to: CGPoint(x: 0,
                              y: rightBorderYPoint))
        path.addLine(to: CGPoint(x: screen.maxX,
                                 y: rightBorderYPoint))
        
        let bottomBorderYPoint = screen.maxY - window.safeAreaInsets.bottom - contentInset
        for _ in 0..<2 {
            path.move(to: CGPoint(x: 0,
                                  y: bottomBorderYPoint))
            path.addLine(to: CGPoint(x: screen.maxX,
                                     y: bottomBorderYPoint))
        }
        
        path.lineWidth = 1
        
        return path
    }
}

//MARK: - UIScrollViewDelegate
extension ExchangeRatesChartViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x < chartView.point(forIndex: rates.count - 1).x / 2) &&
            (UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .unknown) {
            getToCurrentRateOnChartButton.isHidden = false
        } else {
            getToCurrentRateOnChartButton.isHidden = true
        }
    }
}
