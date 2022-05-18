//
//  CurrencyAmountInputCheckTests.swift
//  ConvertItTests
//
//  Created by Slik on 17.05.2022.
//

import XCTest
@testable import ConvertIt

class CurrencyAmountInputCheckTests: XCTestCase {
    
    var currencyAmountInputChecker: CurrencyAmountInputChecker!
    var currencyAmountInputCorrector: CurrencyAmountInputCorrector!

    override func setUpWithError() throws {
        self.currencyAmountInputChecker = CurrencyAmountInputChecker()
        self.currencyAmountInputCorrector = CurrencyAmountInputCorrector()
    }

    override func tearDownWithError() throws {
        self.currencyAmountInputChecker = nil
        self.currencyAmountInputChecker = nil
    }
    
    func testCurrencyAmountCheckerForEmptyValue() throws {
        //Given
        let value = ""
        let expectedResult = false
        let actualResult: Bool
        
        //When
        actualResult = currencyAmountInputChecker.isInputValueCorrect(value)
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testCurrencyAmountCheckerForNegativeValue() throws {
        //Given
        let value = "-10"
        let expectedResult = false
        let actualResult: Bool
        
        //When
        actualResult = currencyAmountInputChecker.isInputValueCorrect(value)
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testCurrencyAmountCheckerForNonDoubleValue() throws {
        //Given
        let value = "value"
        let expectedResult = false
        let actualResult: Bool
        
        //When
        actualResult = currencyAmountInputChecker.isInputValueCorrect(value)
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testCurrencyAmountCorrectorForFirstEnteredSymbolIsSeparator() throws {
        //Given
        let value = "."
        let expectedResult = "0."
        let actualResult: String
        
        //When
        actualResult = currencyAmountInputCorrector.correctedValue(of: value)
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testCurrencyAmountCorrectorForFirstEnteredSymbolIsZeroAndSecondEnteredSymbolIsNumeric() throws {
        //Given
        let value = "03"
        let expectedResult = "0.3"
        let actualResult: String
        
        //When
        actualResult = currencyAmountInputCorrector.correctedValue(of: value)
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testCurrencyAmountCorrectorForSecondSeparatorEnteredAtNextPositionOfFirstSeparator() throws {
        //Given
        let value = "0..9"
        let expectedResult = "0.9"
        let actualResult: String
        
        //When
        actualResult = currencyAmountInputCorrector.correctedValue(of: value)
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testCurrencyAmountCorrectorForSeparatorEnteredAtStartIndexOfValue() throws {
        //Given
        let value = ".156"
        let expectedResult = "0.156"
        let actualResult: String
        
        //When
        actualResult = currencyAmountInputCorrector.correctedValue(of: value)
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testCurrencyAmoutCorrectorForZeroInsertedAtFirstIndexOfFractionalValue() throws {
        //Given
        let value = "00.157856"
        let expectedResult = "0.157856"
        let actualResult: String
        
        //When
        actualResult = currencyAmountInputCorrector.correctedValue(of: value)
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
