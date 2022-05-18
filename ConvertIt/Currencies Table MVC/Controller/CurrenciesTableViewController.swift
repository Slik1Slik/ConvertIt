//
//  CurrenciesTableViewController.swift
//  ConvertIt
//
//  Created by Slik on 08.05.2022.
//

import UIKit

class CurrenciesTableViewController: UIViewController {
    
    var currencyFrom: Currency = Currency()
    var currencyTo: Currency = Currency()
    
    var selection: CurrenciesTableViewSelection = .from {
        didSet {
            view.hideKeyboard()
            saveSearchResult()
            filterCurrencies()
            recoverLastSearchResult()
            tableView.reloadData()
        }
    }
    
    var onCurrencySelected: (Currency, CurrenciesTableViewSelection) -> () = { _, _ in }
    
    private let contentInset: CGFloat = 8
    
    private let padding: CGFloat = 20
    
    private let tableView = UITableView()
    
    private let header: UIView = UIView()
    
    private let currencySegmentedControl: CustomSegmentedControl = CustomSegmentedControl()
    
    private let searchTextField: UITextField = UITextField()
    
    private var currencies: [Currency] = []
    
    private var currentCurrenciesDataSource: [Currency] = []
    
    private var searchText: String = "" {
        didSet {
            initiateSearch()
            searchTextField.rightViewMode = searchText.isEmpty ? .never : .always
        }
    }
    
    private var lastSearchInputValues = (CurrencyFrom: "", CurrencyTo: "")
    
    init(selection: CurrenciesTableViewSelection = .from, currencyFrom: Currency, currencyTo: Currency) {
        super.init(nibName: nil, bundle: nil)
        
        self.selection = selection
        self.currencyFrom = currencyFrom
        self.currencyTo = currencyTo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "themeSecondary")
        
        addSubviews()
        
        setUpCurrencySegmentedControl()
        setUpSearchTextField()
        setUpHeader()
        
        setUpTableView()
        configureCell()
        
        fetchCurrencies()
        sortCurrencies()
        filterCurrencies()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = CGRect(x: 0,
                           y: header.frame.height,
                           width: view.bounds.width,
                           height: view.bounds.height - header.frame.height)
        tableView.frame = frame
    }
    
    private func setUpCurrencySegmentedControl() {
        currencySegmentedControl.frame = CGRect(x: padding,
                                                y: padding,
                                                width: self.view.frame.width - padding * 2,
                                                height: 50)
        
        updateCurrencySegmentedControl()
        
        currencySegmentedControl.selectedItemIndex = selection == .from ? 0 : 1
        
        currencySegmentedControl.onItemSelected = { [unowned self] index in
            selection = index == 0 ? .from : .to
        }
        currencySegmentedControl.updateView()
    }
    
    private func updateCurrencySegmentedControl() {
        
        let currencyFromLabel = CurrencyLabel()
        currencyFromLabel.configure(icon: UIImage(named: currencyFrom.identifier.lowercased()), label: currencyFrom.identifier)
        
        let currencyToLabel = CurrencyLabel()
        currencyToLabel.configure(icon: UIImage(named: currencyTo.identifier.lowercased()), label: currencyTo.identifier)
        
        currencySegmentedControl.items = [currencyFromLabel, currencyToLabel]
    }
    
    private func setUpSearchTextField() {
        searchTextField.frame = CGRect(x: padding,
                                       y: currencySegmentedControl.frame.height + padding + contentInset * 2,
                                       width: self.view.frame.width - padding * 2,
                                       height: 40)
        
        searchTextField.layer.cornerRadius = searchTextField.frame.height / 2
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.systemGray3.cgColor
        
        searchTextField.leftView = searchTextFieldImageView()
        searchTextField.leftViewMode = .always
        
        searchTextField.rightView = searchTextFieldClearButton()
        searchTextField.rightViewMode = .never
        
        searchTextField.placeholder = "Символ, наименование валюты"
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldValueDidChange), for: .editingChanged)
    }
    
    private func searchTextFieldImageView() -> UIView {
        let imageView = UIImageView(frame: CGRect(x: contentInset,
                                                  y: contentInset,
                                                  width: 20,
                                                  height: 20))
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        
        let viewToAppendPaddingToImageView = UIView(frame: CGRect(x: 0,
                                                                  y: 0,
                                                                  width: imageView.frame.width + contentInset * 2,
                                                                  height: imageView.frame.height + contentInset * 2))
        
        viewToAppendPaddingToImageView.addSubview(imageView)
        
        return viewToAppendPaddingToImageView
    }
    
    private func searchTextFieldClearButton() -> UIView {
        let button = UIButton(frame: CGRect(x: 8,
                                            y: 8,
                                            width: 20,
                                            height: 20))
        
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .tertiaryLabel
        
        let viewToAppendPaddingToButton = UIView(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: button.frame.width + contentInset * 2,
                                                               height: button.frame.height + contentInset * 2))
        
        viewToAppendPaddingToButton.addSubview(button)
        
        return viewToAppendPaddingToButton
    }
    
    @objc private func clearButtonTapped() {
        clearSearch()
    }
    
    private func setUpHeader() {
        header.frame = CGRect(x: 0,
                              y: 0,
                              width: self.view.frame.width,
                              height: currencySegmentedControl.frame.height + searchTextField.frame.height + contentInset + padding * 2)
        
        header.layer.backgroundColor = UIColor(named: "themeSecondary")?.cgColor
        
        header.addSubview(currencySegmentedControl)
        header.addSubview(searchTextField)
        
        let tapGestureRecognizerToHideKeyboard = UITapGestureRecognizer(target: self, action: #selector(onViewTapGesture))
        header.addGestureRecognizer(tapGestureRecognizerToHideKeyboard)
    }
    
    private func setUpTableView() {
        tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: CurrencyTableViewCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }
    
    private func configureCell() {
        tableView.rowHeight = 50
    }
    
    private func fetchCurrencies() {
        self.currencies = UserDataManager.shared.currencies
    }
    
    private func sortCurrencies() {
        currencies.sort { $0.identifier < $1.identifier }
        guard let currenciesPopularityRating = try? UserDataManager.shared.fetchCurrencyPopularityRating() else {
            return
        }
        let popularityRatingDict = Dictionary(uniqueKeysWithValues: currenciesPopularityRating.map { ($0.id, $0.popularity) })
        currencies.sort { currency1, currency2 in
            popularityRatingDict[currency1.identifier]! > popularityRatingDict[currency2.identifier]!
        }
    }
    
    private func filterCurrencies() {
        currentCurrenciesDataSource = filtredCurrencies()
    }
    
    private func filtredCurrencies() -> [Currency] {
        return currencies.filter({ currency in
            let currencyToFilter = selection == .from ? currencyTo : currencyFrom
            return currency.identifier != currencyToFilter.identifier
        })
    }
    
    private func addSubviews() {
        view.addSubview(header)
        view.addSubview(tableView)
    }
    
    @objc private func onViewTapGesture() {
        self.view.hideKeyboard()
    }
}

// MARK: - Search
extension CurrenciesTableViewController {
    
    @objc private func searchTextFieldValueDidChange() {
        guard let _ = searchTextField.text else { return }
        searchText = searchTextField.text!
    }
    
    private func initiateSearch() {
        let text = searchText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else {
            filterCurrencies()
            tableView.reloadData()
            return
        }
        let initialCurrencies = filtredCurrencies()
        currentCurrenciesDataSource = initialCurrencies.filter { currency in
            return currency.localizedDescription.lowercased().contains(text.lowercased()) || currency.identifier.contains(text.uppercased())
        }
        tableView.reloadData()
    }
    
    private func saveSearchResult() {
        guard !searchText.isEmpty else { return }
        switch selection {
        case .from:
            lastSearchInputValues.CurrencyTo = searchText.trimmingCharacters(in: .whitespaces)
        case .to:
            lastSearchInputValues.CurrencyFrom = searchText.trimmingCharacters(in: .whitespaces)
        }
    }
    
    private func clearSearch() {
        searchText = ""
        searchTextField.text = ""
    }
    
    private func recoverLastSearchResult() {
        switch selection {
        case .from:
            searchText = lastSearchInputValues.CurrencyFrom
        case .to:
            searchText = lastSearchInputValues.CurrencyTo
        }
        searchTextField.text = searchText
        if !searchText.isEmpty {
            searchTextField.becomeFirstResponder()
        }
    }
}

// MARK: - Table view data source
extension CurrenciesTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCurrenciesDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.reuseID, for: indexPath) as! CurrencyTableViewCell
        
        let currency = currentCurrenciesDataSource[indexPath.row]
        
        cell.configure(icon: UIImage(named: currency.identifier.lowercased()), primaryLabelText: currency.identifier, secondaryLabelText: currency.localizedDescription)
        
        switch selection {
        case .from:
            cell.state = currency == currencyFrom ? .selected : .unselected
        case .to:
            cell.state = currency == currencyTo ? .selected : .unselected
        }
        
        return cell
    }
}

// MARK: - Table view delegate
extension CurrenciesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selection == .from {
            currencyFrom = currentCurrenciesDataSource[indexPath.row]
            onCurrencySelected(currencyFrom, .from)
        } else {
            currencyTo = currentCurrenciesDataSource[indexPath.row]
            onCurrencySelected(currencyTo, .to)
        }
        self.view.hideKeyboard()
        updateCurrencySegmentedControl()
        tableView.reloadData()
    }
}


//MARK: - Error handling
extension CurrenciesTableViewController {
    
    private func handle(apiError: ExchangeRatesDataAPIError) {
    }
    
    private func handle(urlError: URLError) {
        guard urlError.urlErrorCode != .cancelled else { return }
        presentErrorMessageAlert(title: "Ошибка",
                                 message: NSLocalizedString(urlError.urlErrorCode.localizedStringKey, comment: ""))
        {
            
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

//MARK: Alert messages
extension CurrenciesTableViewController {
    
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
}

enum CurrenciesTableViewSelection {
    case from
    case to
}
