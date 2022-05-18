//
//  ViewController.swift
//  ConvertIt
//
//  Created by Slik on 30.04.2022.
//

import UIKit

class MainViewController: UIViewController {
    
    private let statusBar: NetworkStatusBar = NetworkStatusBar()
    
    private let pickCurrencyFromButtton: PickCurrencyButton = PickCurrencyButton()
    
    private let pickCurrencyToButtton: PickCurrencyButton = PickCurrencyButton()
    
    private let swapCurrenciesButton: DefaultApplicationButton = DefaultApplicationButton(style: .regular)
    
    private let amountTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: UIScreen.main.bounds.width - 40,
                                                  height: 50))
        textField.keyboardType = .decimalPad
        if #available(iOS 14.0, *) {
            textField.font = UIFont.preferredFont(from: .title3)
        } else {
            textField.font = UIFont.systemFont(ofSize: 25)
        }
        textField.addBottomBorder()
        textField.textAlignment = .center
        textField.placeholder = "Значение"
        return textField
    }()
    
    private let doneButton: UIBarButtonItem = {
        if #available(iOS 14.0, *) {
            return UIBarButtonItem(systemItem: .done)
        } else {
            return UIBarButtonItem(title: "Готово", style: .done, target: nil, action: nil)
        }
    }()
    
    private let secondaryResultLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 14.0, *) {
            label.font = UIFont.preferredFont(from: .footnote)
        } else {
            label.font = UIFont.systemFont(ofSize: 13)
        }
        label.textAlignment = .center
        label.alpha = UserSettings.shared.wasDataQueryEverMade! ? 1 : 0
        return label
    }()
    
    private let primaryResultLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 14.0, *) {
            label.font = UIFont.preferredFont(from: .largeTitle)
        } else {
            label.font = UIFont.systemFont(ofSize: 34)
        }
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.alpha = UserSettings.shared.wasDataQueryEverMade! ? 1 : 0
        return label
    }()
    
    private let outputControlsHStack: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 20
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let initiateCurrencyDataRequestButton: DefaultApplicationButton = DefaultApplicationButton(style: .regular)
    
    private let cancelTaskButton: DefaultApplicationButton = DefaultApplicationButton(style: .regular)
    
    private let changeSystemAppereanceButton: DefaultApplicationButton = DefaultApplicationButton(style: .large)
    
    private let systemAppereanceSegmentedControl: CustomSegmentedControl = CustomSegmentedControl()
    
    private let padding: CGFloat = 20
    
    private let contentInset: CGFloat = 30
    private let groupedContentInset: CGFloat = 20
    
    private let api: ExchangeRatesAPI = ExchangeRatesDataAPI()
    
    private var query: ParsedExchangeRatesDataQuery = ParsedExchangeRatesDataQuery()
    private var response: ParsedExchangeRatesDataResponse = ParsedExchangeRatesDataResponse()
    
    private var amountTextValue: String = "" {
        didSet {
            inputValueCheck()
            let isCorrect = amountInputChecker.isInputValueCorrect(amountTextValue)
            doneButton.isEnabled = isCorrect
            initiateCurrencyDataRequestButton.isEnabled = isCorrect
            if isCorrect {
                query.amount = amountTextValue.doubleValue!
            }
        }
    }
    
    private let amountInputChecker: CurrencyAmountInputChecker = CurrencyAmountInputChecker()
    private let amountInputCorrector: CurrencyAmountInputCorrector = CurrencyAmountInputCorrector()
    
    private var isDataTaskProcessing = false {
        didSet {
            changeCurrentRequestPrimaryButton()
            updateStatusBar()
        }
    }
    
    private var isSystemAppereanceSegmentedControlShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "themeSecondary")
        
        observeInternetConnectionChanges()
        
        fetchLastResponse()
        
        setUpPickCurrencyFromButton()
        setUpPickCurrencyToButton()
        
        setUpSwapCurrenciesButton()
        
        setUpTextField()
        
        setUpInitiateCurrencyDataRequestButton()
        setUpCancelTaskButton()
        
        setUpOutputControlsHStack()
        
        setUpChangeSystemAppereanceButton()
        
        setUpSystemAppereanceSegmentedControl()
        
        addSubviews()
        setUpConstraints()
        addViewTapGestureRecognizer()
    }
    
    private func addViewTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onViewTapGesture))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func onViewTapGesture() {
        self.view.hideKeyboard()
    }
    
    private func addSubviews() {
        view.addSubview(statusBar)
        view.addSubview(pickCurrencyFromButtton)
        view.addSubview(pickCurrencyToButtton)
        view.addSubview(swapCurrenciesButton)
        view.addSubview(amountTextField)
        view.addSubview(secondaryResultLabel)
        view.addSubview(primaryResultLabel)
        view.addSubview(changeSystemAppereanceButton)
        view.addSubview(outputControlsHStack)
        view.addSubview(systemAppereanceSegmentedControl)
    }
}

//MARK: - Status bar
extension MainViewController {
    private func updateStatusBar() {
        if isDataTaskProcessing {
            statusBar.animate(for: .dataTask)
        } else {
            statusBar.stopAnimation()
        }
    }
}

//MARK: - Currency Buttons
extension MainViewController {
    
    private func setUpPickCurrencyFromButton() {
        pickCurrencyFromButtton.addTarget(self, action: #selector(pickCurrencyFromButtonTapped), for: .touchUpInside)
    }
    
    @objc private func pickCurrencyFromButtonTapped() {
        presentCurrenciesTVC(withInitialSelection: .from)
    }
    
    private func setUpPickCurrencyToButton() {
        pickCurrencyToButtton.addTarget(self, action: #selector(pickCurrencyToButtonTapped), for: .touchUpInside)
    }
    
    @objc private func pickCurrencyToButtonTapped() {
        presentCurrenciesTVC(withInitialSelection: .to)
    }
    
    private func presentCurrenciesTVC(withInitialSelection selection: CurrenciesTableViewSelection) {
        let vc = CurrenciesTableViewController(selection: selection,
                                               currencyFrom: query.currencyFrom,
                                               currencyTo: query.currencyTo)
        vc.onCurrencySelected = { [unowned self] currency, selection in
            switch selection {
            case .from:
                self.query.currencyFrom = currency
                self.updatePickCurrencyFromButton()
            case .to:
                self.query.currencyTo = currency
                self.updatePickCurrencyToButton()
            }
            
        }
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true, completion: nil)
    }
    
    private func setUpSwapCurrenciesButton() {
        swapCurrenciesButton.configure(imageName: "arrow.up.arrow.down.circle.fill")
        swapCurrenciesButton.addTarget(self, action: #selector(swapCurrenciesButtonTapped), for: .touchUpInside)
    }
    
    @objc private func swapCurrenciesButtonTapped() {
        let from = query.currencyFrom
        query.currencyFrom = query.currencyTo
        query.currencyTo = from
        updateInputControls()
    }
}

//MARK: - Amount Text Field
extension MainViewController {
    
    private func setUpTextField() {
        amountTextField.inputAccessoryView = createValueTextFieldToolBar()
        amountTextField.clearsOnInsertion = true
        amountTextField.addTarget(self, action: #selector(amountTextFieldValueDidChange), for: .editingChanged)
        amountTextField.pasteDelegate = self
    }
    
    private func createValueTextFieldToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        doneButton.action = #selector(doneButtonTapped)
        doneButton.target = self
        doneButton.isEnabled = false
        
        toolBar.items = [flexibleSpace, doneButton]
        toolBar.sizeToFit()
        
        return toolBar
    }
    
    @objc private func doneButtonTapped() {
        guard amountInputChecker.isInputValueCorrect(amountTextValue) else {
            return
        }
        self.view.hideKeyboard()
        initiateDataRequest()
    }
}

//MARK: - Output controls
extension MainViewController {
    
    private func setUpOutputControlsHStack() {
        //outputControlsHStack.addArrangedSubview(showChartButton)
        if isDataTaskProcessing {
            outputControlsHStack.addArrangedSubview(cancelTaskButton)
        } else {
            outputControlsHStack.addArrangedSubview(initiateCurrencyDataRequestButton)
        }
    }
    
    @objc private func showChartButtonTapped(_ sender: Any) {
        
    }
    
    private func setUpInitiateCurrencyDataRequestButton() {
        initiateCurrencyDataRequestButton.configure(imageName: "arrow.right.circle.fill")
        initiateCurrencyDataRequestButton.addTarget(self, action: #selector(initiateCurrencyDataRequestButtonTapped), for: .touchUpInside)
    }
    
    @objc private func initiateCurrencyDataRequestButtonTapped(_ sender: Any) {
        guard amountInputChecker.isInputValueCorrect(amountTextValue) else {
            return
        }
        initiateDataRequest()
    }
    
    private func setUpCancelTaskButton() {
        cancelTaskButton.configure(imageName: "xmark.circle.fill")
        cancelTaskButton.addTarget(self, action: #selector(cancelTaskButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelTaskButtonTapped(_ sender: Any) {
        presentDataTaskCancellationAlert()
    }
    
    private func changeCurrentRequestPrimaryButton() {
        UIView.transition(with: outputControlsHStack, duration: 0.1, options: .transitionCrossDissolve, animations: { [weak self] in
            guard let self = self else { return }
            if self.isDataTaskProcessing {
                self.initiateCurrencyDataRequestButton.removeFromSuperview()
                self.outputControlsHStack.addArrangedSubview(self.cancelTaskButton)
            } else {
                self.cancelTaskButton.removeFromSuperview()
                self.outputControlsHStack.addArrangedSubview(self.initiateCurrencyDataRequestButton)
            }
        }, completion: nil)
    }
    
    private func showOutputControls() {
        UIView.animate(withDuration: 0.3, delay: 0, options: []) { [weak self] in
            self?.secondaryResultLabel.alpha = 1
            self?.primaryResultLabel.alpha = 1
        }
    }
}

//MARK: - System appereance controls
extension MainViewController {
    
    private func setUpChangeSystemAppereanceButton() {
        changeSystemAppereanceButton.configure(imageName: "moon.circle.fill")
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeSystemAppereanceButtonTapped))
        changeSystemAppereanceButton.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                      action: #selector(changeSystemAppereanceButtonLongPressed))
        changeSystemAppereanceButton.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc private func changeSystemAppereanceButtonTapped(_ sender: Any) {
        if isSystemAppereanceSegmentedControlShown {
            isSystemAppereanceSegmentedControlShown.toggle()
            updateSystemAppereanceSegmentedControlForState()
            updateChangeSystemAppereanceButtonForCurrentState()
        } else {
            switch UserSettings.shared.systemAppereanceMode {
            case .system:
                changeSystemAppereance(to: .dark)
            case .light:
                changeSystemAppereance(to: .dark)
            case .dark:
                changeSystemAppereance(to: .light)
            }
        }
    }
    
    private func changeSystemAppereance(to mode: SystemAppereanceMode) {
        guard mode != UserSettings.shared.systemAppereanceMode else { return }
        systemAppereanceSegmentedControl.selectedItemIndex = mode.rawValue
        UserSettings.shared.systemAppereanceMode = mode
        UIView.transition(with: view, duration: 0.3, options: [.transitionCrossDissolve]) { [weak self] in
            self?.view.window?.overrideUserInterfaceStyle = mode.userInterfaceStyle
        }
        systemAppereanceSegmentedControl.updateView()
    }
    
    @objc private func changeSystemAppereanceButtonLongPressed(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .ended:
            guard !isSystemAppereanceSegmentedControlShown else { return }
            
            isSystemAppereanceSegmentedControlShown.toggle()
            
            updateChangeSystemAppereanceButtonForCurrentState()
            updateSystemAppereanceSegmentedControlForState()
        default:
            return
        }
    }
    
    private func updateSystemAppereanceSegmentedControlForState() {
        UIView.animate(withDuration: 0.3, delay: 0, options: []) { [weak self] in
            guard let self = self else { return }
            self.systemAppereanceSegmentedControl.alpha = self.isSystemAppereanceSegmentedControlShown ? 1 : 0
        }
    }
    
    private func updateChangeSystemAppereanceButtonForCurrentState() {
        let imageName = isSystemAppereanceSegmentedControlShown ? "xmark.circle.fill" : "moon.circle.fill"
        UIView.transition(with: changeSystemAppereanceButton, duration: 0.1, options: .transitionCrossDissolve, animations: { [weak self] in
            guard let self = self else { return }
            self.changeSystemAppereanceButton.configure(imageName: imageName)
        }, completion: nil)
    }
    
    private func setUpSystemAppereanceSegmentedControl() {
        
        let width = view.frame.width - padding - 12 - ApplicationButtonStyle.large.pointSize - 12
        
        systemAppereanceSegmentedControl.frame = CGRect(x: 0,
                                                        y: 0,
                                                        width: width,
                                                        height: ApplicationButtonStyle.large.pointSize)
        
        systemAppereanceSegmentedControl.alpha = 0
        
        systemAppereanceSegmentedControl.items = SystemAppereanceMode.allCases.map { appereanceModeLabel(for: $0) }
        systemAppereanceSegmentedControl.selectedItemIndex = UserSettings.shared.systemAppereanceMode.rawValue
        systemAppereanceSegmentedControl.onItemSelected = { [unowned self] value in
            self.changeSystemAppereance(to: SystemAppereanceMode.allCases.first { $0.rawValue == value }!)
        }
        
        systemAppereanceSegmentedControl.updateView()
    }
    
    private func appereanceModeLabel(for mode: SystemAppereanceMode) -> UILabel {
        let appereanceModeLabel = UILabel()
        appereanceModeLabel.text = mode.localizedDescription
        appereanceModeLabel.textAlignment = .center
        if #available(iOS 14.0, *) {
            appereanceModeLabel.font = .preferredFont(from: .callout)
        } else {
            appereanceModeLabel.font = UIFont.systemFont(ofSize: 16)
        }
        appereanceModeLabel.sizeToFit()
        appereanceModeLabel.frame = CGRect(x: 0,
                                           y: 0,
                                           width: 100,
                                           height: appereanceModeLabel.frame.height)
        appereanceModeLabel.isUserInteractionEnabled = true
        return appereanceModeLabel
    }
}

//MARK: - Constraints
extension MainViewController {
    
    private func setUpStatusBarConstraints() {
        statusBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statusBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            statusBar.heightAnchor.constraint(equalToConstant: (navigationController?.navigationBar.frame.height ?? 50) + 10),
            statusBar.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    private func setUpCurrencyButtonsConstraints() {
        pickCurrencyFromButtton.translatesAutoresizingMaskIntoConstraints = false
        pickCurrencyToButtton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pickCurrencyFromButtton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding),
            pickCurrencyFromButtton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding),
            pickCurrencyFromButtton.heightAnchor.constraint(equalToConstant: 80),
            pickCurrencyFromButtton.topAnchor.constraint(lessThanOrEqualTo: statusBar.bottomAnchor, constant: contentInset)
        ])
        
        NSLayoutConstraint.activate([
            pickCurrencyToButtton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding),
            pickCurrencyToButtton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding),
            pickCurrencyToButtton.heightAnchor.constraint(equalToConstant: 80),
            pickCurrencyToButtton.topAnchor.constraint(lessThanOrEqualTo: pickCurrencyFromButtton.bottomAnchor, constant: groupedContentInset)
        ])
    }
    
    private func setUpSwapCurrenciesButtonConstraints() {
        swapCurrenciesButton.translatesAutoresizingMaskIntoConstraints = false
        
        let leftAnchorConstant = view.frame.width - padding - groupedContentInset - ApplicationButtonStyle.regular.pointSize
        let rightAnchorConstant = padding + groupedContentInset
        
        NSLayoutConstraint.activate([
            swapCurrenciesButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -rightAnchorConstant),
            swapCurrenciesButton.heightAnchor.constraint(equalToConstant: ApplicationButtonStyle.regular.pointSize),
            swapCurrenciesButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: leftAnchorConstant),
            swapCurrenciesButton.centerYAnchor.constraint(equalTo: pickCurrencyFromButtton.bottomAnchor, constant: groupedContentInset / 2)
        ])
    }
    
    private func setUpAmountTextFieldConstraints() {
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            amountTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding),
            amountTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding),
            amountTextField.heightAnchor.constraint(equalToConstant: 50),
            amountTextField.topAnchor.constraint(lessThanOrEqualTo: pickCurrencyToButtton.bottomAnchor, constant: contentInset)
        ])
    }
    
    private func setUpResultLabelsConstraints() {
        primaryResultLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryResultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            secondaryResultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            secondaryResultLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),
            secondaryResultLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: contentInset)
        ])
        
        NSLayoutConstraint.activate([
            primaryResultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            primaryResultLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),
            primaryResultLabel.topAnchor.constraint(equalTo: secondaryResultLabel.bottomAnchor, constant: groupedContentInset)
        ])
    }
    
    private func setUpRequestResultControlsHStackConstraints() {
        outputControlsHStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            outputControlsHStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            outputControlsHStack.heightAnchor.constraint(equalToConstant: ApplicationButtonStyle.regular.pointSize),
            outputControlsHStack.widthAnchor.constraint(equalToConstant: 110),
            outputControlsHStack.topAnchor.constraint(equalTo: primaryResultLabel.bottomAnchor, constant: contentInset)
        ])
    }
    
    private func setUpSystemAppereanceControlsConstrains() {
        changeSystemAppereanceButton.translatesAutoresizingMaskIntoConstraints = false
        systemAppereanceSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            changeSystemAppereanceButton.widthAnchor.constraint(equalToConstant: ApplicationButtonStyle.large.pointSize),
            changeSystemAppereanceButton.heightAnchor.constraint(equalToConstant: ApplicationButtonStyle.large.pointSize),
            changeSystemAppereanceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            changeSystemAppereanceButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            systemAppereanceSegmentedControl.heightAnchor.constraint(equalToConstant: ApplicationButtonStyle.large.pointSize),
            systemAppereanceSegmentedControl.trailingAnchor.constraint(equalTo: changeSystemAppereanceButton.leadingAnchor, constant: -12),
            systemAppereanceSegmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding),
            systemAppereanceSegmentedControl.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -padding)
        ])
    }
    
    private func setUpConstraints() {
        setUpStatusBarConstraints()
        setUpCurrencyButtonsConstraints()
        setUpSwapCurrenciesButtonConstraints()
        setUpAmountTextFieldConstraints()
        setUpResultLabelsConstraints()
        setUpRequestResultControlsHStackConstraints()
        setUpSystemAppereanceControlsConstrains()
    }
}

//MARK: - Amount text field input check
extension MainViewController {
    
    @objc private func amountTextFieldValueDidChange() {
        amountTextValue = amountTextField.text ?? ""
    }
    
    private func inputValueCheck() {
        let correctedValue = amountInputCorrector.correctedValue(of: amountTextValue)
        if amountTextValue != correctedValue {
            amountTextValue = correctedValue
            amountTextField.text = correctedValue
        }
    }
}

//MARK: - Text field paste delegate
extension MainViewController: UITextPasteDelegate {
    func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, performPasteOf attributedString: NSAttributedString, to textRange: UITextRange) -> UITextRange {
        
        guard let doubleValue = attributedString.string.doubleValue, doubleValue > 0 else {
            return textRange
        }
        
        var pastedString = attributedString.string
        
        if pastedString.first! == "0" {
            let secondSymbolIndex = pastedString.index(after: pastedString.startIndex)
            if pastedString[secondSymbolIndex] == "0" {
                pastedString = pastedString.doubleValue!.description
            }
        }
        
        guard let currentTextValue = amountTextField.text else {
            return textRange
        }
        
        guard !currentTextValue.isEmpty else {
            amountTextField.replace(textRange, withText: pastedString)
            return textRange
        }
        
        guard !(currentTextValue.contains(Locale.current.decimalSeparatorCharacter.last!) && pastedString.contains(Locale.current.decimalSeparatorCharacter.last!))
        else {
            return textRange
        }
        
        guard !(currentTextValue.count == 1 && String(currentTextValue.first!) == "0") else {
            return textRange
        }
        
        amountTextField.replace(textRange, withText: pastedString)
        
        return textRange
    }
}

//MARK: - Network
extension MainViewController {
    
    private func observeInternetConnectionChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onInternetConnectionDidBecomeLost),
                                               name: NetworkService.Notifications.internetConnectionDidBecomeLostNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onInternetConnectionDidRestore),
                                               name: NetworkService.Notifications.internetConnectionDidRestoreNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onInternetConnectionDidBecomeMonitored),
                                               name: NetworkService.Notifications.internetConnectionDidBecomeMonitoredNotification,
                                               object: nil)
    }
    
    @objc private func onInternetConnectionDidBecomeLost() {
        doneButton.isEnabled = false
        initiateCurrencyDataRequestButton.isEnabled = false
        statusBar.animate(for: .lostConnection)
    }
    
    @objc private func onInternetConnectionDidRestore() {
        doneButton.isEnabled = amountInputChecker.isInputValueCorrect(amountTextValue)
        initiateCurrencyDataRequestButton.isEnabled = true
        statusBar.animate(for: .restoredConnection)
    }
    
    @objc private func onInternetConnectionDidBecomeMonitored() {
        let isConnectionAvailable = NetworkService.shared.isConnectionAvailable
        doneButton.isEnabled = isConnectionAvailable
        initiateCurrencyDataRequestButton.isEnabled = isConnectionAvailable
        if !isConnectionAvailable {
            statusBar.animate(for: .lostConnection)
        }
    }
}

//MARK: - API - Controller - View
extension MainViewController {
    
    private func initiateDataRequest() {
        isDataTaskProcessing = true
        api.resultOfConverting(amount: query.amount,
                               ofCurrencyAtCode: query.currencyFrom.identifier,
                               toCurrencyAtCode: query.currencyTo.identifier) { result in
            DispatchQueue.main.async { [unowned self] in
                switch result {
                case .failure(let error):
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    self.handle(apiError: error)
                case .success(let data):
                    JSONManager.read(for: ExchangeRatesDataResponse.self, from: data) { [unowned self] decodingResult in
                        switch decodingResult {
                        case .success(let response):
                            ExchangeRatesDataResponseParser.parse(response) { parsingResult in
                                switch parsingResult {
                                case .success(let parsedResponse):
                                    self.response = parsedResponse
                                    self.updateOutputControls()
                                    self.updateUserData()
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                case .failure(let error):
                                    self.handle(anyError: error)
                                }
                            }
                        case .failure(let error):
                            self.handle(decodingError: error)
                        }
                    }
                }
                self.isDataTaskProcessing = false
            }
        }
    }
    
    private func updateUserData() {
        try? UserDataManager.shared.increasePopularityRating(forId: query.currencyFrom.identifier)
        try? UserDataManager.shared.increasePopularityRating(forId: query.currencyTo.identifier)
        if response.isSuccessful {
            try? UserDataManager.shared.saveExchangeRatesDataResponse(response)
            if !UserSettings.shared.wasDataQueryEverMade! {
                UserSettings.shared.wasDataQueryEverMade = true
            }
        }
    }
    
    private func fetchLastResponse() {
        guard let wasDataQueryEverMade = UserSettings.shared.wasDataQueryEverMade,
              wasDataQueryEverMade == true,
              let response = try? UserDataManager.shared.fetchLastExchangeRatesDataResponse() else {
            query.currencyFrom = UserDataManager.shared.currencyFromPlaceholder
            query.currencyTo = UserDataManager.shared.currencyToPlaceholder
            query.amount = 1
            updateInputControls()
            amountTextValue = String(format: "%g", query.amount)
            response.isSuccessful = false
            return
        }
        
        if response.isSuccessful {
            self.response = response
            self.query = response.query
            updateOutputControls()
        }
        
        updateInputControls()
        amountTextValue = String(format: "%g", query.amount)
    }
    
    private func updateInputControls() {
        updatePickCurrencyFromButton()
        updatePickCurrencyToButton()
        
        amountTextField.text = String(format: "%g", query.amount)
    }
    
    private func updatePickCurrencyFromButton() {
        pickCurrencyFromButtton.configure(icon: UIImage(named: query.currencyFrom.identifier.lowercased()), primaryLabelText: query.currencyFrom.identifier, secondaryLabelText: query.currencyFrom.localizedDescription)
    }
    
    private func updatePickCurrencyToButton() {
        pickCurrencyToButtton.configure(icon: UIImage(named: query.currencyTo.identifier.lowercased()), primaryLabelText: query.currencyTo.identifier, secondaryLabelText: query.currencyTo.localizedDescription)
    }
    
    private func updateOutputControls() {
        secondaryResultLabel.text = secondaryResultLabelText()
        primaryResultLabel.text = response.result.description + " " + response.query.currencyTo.symbol
        showOutputControls()
    }
    
    private func secondaryResultLabelText() -> String {
        let dateString = Date(timeIntervalSince1970: TimeInterval(response.timestamp)).string(format: "d MMMM yyyy, HH:mm")
        let amountString = String(format: "%g", response.query.amount)
        return "По данным на " + dateString + ", " + amountString + " " + response.query.currencyFrom.symbol + " ="
    }
    
    private func cancelDataTask() {
        api.cancelCurrentTask()
        isDataTaskProcessing = false
    }
}

//MARK: - Error handling
extension MainViewController {
    
    private func handle(apiError: ExchangeRatesDataAPIError) {
        let errorTitle = "Ошибка"
        switch apiError {
        case .badRequest:
            presentErrorMessageAlert(title: errorTitle,
                                     message: apiError.localizedDescription,
                                     onRetry: nil)
        case .unauthorized:
            presentErrorMessageAlert(title: errorTitle,
                                     message: apiError.localizedDescription) {
                self.initiateDataRequest()
            }
        case .notFound:
            presentErrorMessageAlert(title: errorTitle,
                                     message: apiError.localizedDescription,
                                     onRetry: nil)
        case .requestLimitExceeded:
            presentErrorMessageAlert(title: errorTitle,
                                     message: apiError.localizedDescription,
                                     onRetry: nil)
        case .serverError:
            presentErrorMessageAlert(title: errorTitle,
                                     message: apiError.localizedDescription) {
                self.initiateDataRequest()
            }
        case .failedToCreateURL:
            presentErrorMessageAlert(title: errorTitle,
                                     message: apiError.localizedDescription,
                                     onRetry: nil)
        case .notHTTPResponse:
            presentErrorMessageAlert(title: errorTitle,
                                     message: apiError.localizedDescription) {
                self.initiateDataRequest()
            }
        case .unknownServersideError(let error):
            if let urlError = error as? URLError {
                handle(urlError: urlError)
            } else {
                handle(anyError: error)
            }
        case .unknownError:
            presentErrorMessageAlert(title: errorTitle,
                                     message: apiError.localizedDescription) {
                self.initiateDataRequest()
            }
        }
    }
    
    private func handle(urlError: URLError) {
        guard urlError.urlErrorCode != .cancelled else { return }
        presentErrorMessageAlert(title: "Ошибка",
                                 message: NSLocalizedString(urlError.urlErrorCode.localizedStringKey, comment: ""))
        {
            self.initiateDataRequest()
        }
    }
    
    private func handle(decodingError: JSONManager.JSONManagerError) {
        presentErrorMessageAlert(title: "Ошибка",
                                 message: decodingError.localizedDescription,
                                 onRetry: nil)
    }
    
    private func handle(anyError: Error) {
        presentErrorMessageAlert(title: "Ошибка",
                                 message: anyError.localizedDescription,
                                 onRetry: nil)
    }
}

//MARK: - Alert messages
extension MainViewController {
    
    private func presentErrorMessageAlert(title: String, message: String, onRetry: (() -> ())?) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        if let onRetry = onRetry, NetworkService.shared.isConnectionAvailable {
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            alert.addAction(UIAlertAction(title: "Попробовать еще раз", style: .default, handler: { _ in
                onRetry()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentDataTaskCancellationAlert() {
        let alert = UIAlertController(title: "Предупреждение",
                                      message: "Вы уверены, что хотите отменить операцию?",
                                      preferredStyle: UIAlertController.Style.alert)
        
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { [unowned self] _ in
            self.cancelDataTask()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
