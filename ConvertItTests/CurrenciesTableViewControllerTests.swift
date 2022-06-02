//
//  CurrenciesTableViewControllerTests.swift
//  ConvertItTests
//
//  Created by Slik on 22.05.2022.
//

import XCTest
@testable import ConvertIt

class CurrenciesTableViewControllerTests: XCTestCase {

    var tvc: CurrenciesTableViewController!
    
    override func setUpWithError() throws {
        tvc = CurrenciesTableViewController()
        _ = tvc.view
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testViewDidLoadWithSelectionIsToSetsCurrenciesSegmentedControlSelectedIndexToOne() throws {
        //Given
        let selection: CurrenciesTableViewSelection = .to
        
        //When
        let tvc = CurrenciesTableViewController(selection: selection, currencyFrom: Currency(),
                                                currencyTo: Currency())
        _ = tvc.view
        
        //Then
        XCTAssertTrue(tvc.currencySegmentedControl.selectedItemIndex == 1)
    }

    func testViewDidLoadWithCurrenciesPlaceholdersRendersNoSegmentedControlItems() throws {
        //Given
        let currencyFromPlaceholder = Currency()
        let currencyToPlaceholder = Currency()
        
        //When
        let tvc = CurrenciesTableViewController(currencyFrom: currencyFromPlaceholder,
                                                currencyTo: currencyToPlaceholder)
        _ = tvc.view
        
        //Then
        XCTAssertTrue((tvc.currencySegmentedControl.items[0] as! CurrencyLabel).currencyIcon.image == nil)
        XCTAssertTrue((tvc.currencySegmentedControl.items[0] as! CurrencyLabel).currencyLabel.text == "")
        
        XCTAssertTrue((tvc.currencySegmentedControl.items[1] as! CurrencyLabel).currencyIcon.image == nil)
        XCTAssertTrue((tvc.currencySegmentedControl.items[1] as! CurrencyLabel).currencyLabel.text == "")
    }
    
    func testCurrenciesFromDoesNotContainSelectedCurrencyToOnInit() throws {
        //Given
        let currencyFrom = Currency(identifier: "usd",
                                    symbol: "",
                                    localizedDescription: "")
        let currencyTo = Currency(identifier: "eur",
                                  symbol: "",
                                  localizedDescription: "")
        
        //When
        let tvc = CurrenciesTableViewController(selection: .from,
                                                currencyFrom: currencyFrom,
                                                currencyTo: currencyTo)
        _ = tvc.view
        
        //Then
        XCTAssertFalse(tvc.currentCurrenciesDataSource.contains { $0.identifier == tvc.currencyTo.identifier} )
    }
    
    func testCurrenciesFromDoesNotContainSelectedCurrencyToAfterSelecting() throws {
        //Given
        let initialCurrencyFrom = Currency(identifier: "usd",
                                    symbol: "",
                                    localizedDescription: "")
        let initialCurrencyTo = Currency(identifier: "eur",
                                  symbol: "",
                                  localizedDescription: "")
        let selectedCurrencyTo = Currency(identifier: "rub",
                                  symbol: "",
                                  localizedDescription: "")
        
        //When
        let tvc = CurrenciesTableViewController(selection: .to,
                                                currencyFrom: initialCurrencyFrom,
                                                currencyTo: initialCurrencyTo)
        tvc.currencyTo = selectedCurrencyTo
        tvc.selection = .from
        
        //Then
        XCTAssertFalse(tvc.currentCurrenciesDataSource.contains { $0.identifier == tvc.currencyTo.identifier} )
    }
    
    func testTableIsNotEmptyAfterSearchTextFieldCleared() throws {
        //Given
        let searchText = "RUB"
        
        //When
        tvc.searchText = searchText
        tvc.searchText = ""
        
        //Then
        XCTAssertFalse(tvc.currentCurrenciesDataSource.isEmpty)
    }
    
    func testSearchWorksForUpperCase() throws {
        //Given
        let searchTextUpper = "RUB"
        
        //When
        tvc.searchText = searchTextUpper
        
        //Then
        XCTAssertEqual(tvc.currentCurrenciesDataSource.count, 1)
    }
    
    func testSearchWorksForLowerCase() throws {
        //Given
        let searchTextLower = "rub"
        
        //When
        tvc.searchText = searchTextLower
        
        //Then
        XCTAssertEqual(tvc.currentCurrenciesDataSource.count, 1)
    }
    
    func testTVCSavesLastSearchResultBeforeSelectionChanged() throws {
        //Given
        let searchText = "rub"
        
        let initialSelection: CurrenciesTableViewSelection = .from
        let newSelection: CurrenciesTableViewSelection = .to
        
        //When
        tvc.selection = initialSelection
        tvc.searchText = searchText
        
        tvc.selection = newSelection
        
        //Then
        XCTAssertNotEqual(tvc.lastSearchInputValues.CurrencyFrom, "")
    }
    
    func testTVCRecoversLastSearchResultAfterSelectionChanged() throws {
        //Given
        let searchText = "rub"
        
        let initialSelection: CurrenciesTableViewSelection = .from
        let newSelection: CurrenciesTableViewSelection = .to
        
        let expectedCountOfObjectsAfterSelectionChanged = 1
        let actualCountOfObjectsAfterSelectionChanged: Int
        
        //When
        tvc.selection = initialSelection
        tvc.searchText = searchText
        
        tvc.selection = newSelection
        tvc.selection = initialSelection
        
        actualCountOfObjectsAfterSelectionChanged = tvc.currentCurrenciesDataSource.count
        
        //Then
        XCTAssertEqual(actualCountOfObjectsAfterSelectionChanged, expectedCountOfObjectsAfterSelectionChanged)
    }
    
    func testSearchTextFieldClearButtonIsShownWhileFieldIsEditing() throws {
        //Given
        let searchText = "rub"
        
        //When
        tvc.searchText = searchText
        
        //Then
        XCTAssertTrue(tvc.searchTextField.rightViewMode == .always)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
