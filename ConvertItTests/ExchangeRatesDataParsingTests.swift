//
//  ExchangeRatesDataParsingTests.swift
//  ConvertItTests
//
//  Created by Slik on 18.05.2022.
//

import XCTest
@testable import ConvertIt

class ExchangeRatesDataParsingTests: XCTestCase {
    
    var queryParser: MockExchangeRatesDataQueryParser.Type!

    override func setUpWithError() throws {
        self.queryParser = MockExchangeRatesDataQueryParser.self
    }

    override func tearDownWithError() throws {
        self.queryParser = nil
    }

    func testExchangeRatesDataQueryParserForIncorrectValue() throws {
        //Given
        let value = ExchangeRatesConversionResultResponseQuery(amount: 0, from: "", to: "")
        let expectedResult: ExchangeRatesDataQueryParserProtocol.ParsingResult = .failure(.incorrectDataFormat)
        var actualResult: ExchangeRatesDataQueryParserProtocol.ParsingResult?
        
        //When
        queryParser.parse(value, completion: { result in
            actualResult = result
        })
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func testExchangeRatesDataQueryParserForCorrectValue() throws {
        //Given
        let value = ExchangeRatesConversionResultResponseQuery(amount: 0, from: "USD", to: "EUR")
        
        let currencyFromInput = Currency(identifier: "USD",
                                    symbol: "",
                                    localizedDescription: "")
        let currencyToInput = Currency(identifier: "EUR",
                                  symbol: "",
                                  localizedDescription: "")
        
        let expectedResult: ExchangeRatesDataQueryParserProtocol.ParsingResult = .success(
            .init(currencyFrom: currencyFromInput,
                  currencyTo: currencyToInput,
                  amount: 0)
        )
        var actualResult: ExchangeRatesDataQueryParserProtocol.ParsingResult?
        
        //When
        queryParser.parse(value, completion: { result in
            actualResult = result
        })
        
        //Then
        XCTAssertEqual(expectedResult, actualResult)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
