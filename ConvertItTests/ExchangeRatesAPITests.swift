//
//  ExchangeRatesAPITests.swift
//  ConvertItTests
//
//  Created by Slik on 18.05.2022.
//

import XCTest
@testable import ConvertIt

class ExchangeRatesAPITests: XCTestCase {
    
    var api: ExchangeRatesAPI!

    override func setUpWithError() throws {
        
        self.api = MockExchangeRatesDataAPI()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAPIForCorrectInputValuesAndNoServersideError() throws {
        //Given
        let amount = 200.0
        let expectedResult: ExchangeRatesAPI.DataTaskResult = .success(Data())
        var actualResult: ExchangeRatesAPI.DataTaskResult?
        
        let expectation = expectation(description: "Expectation of " + #function)
        
        //When
        api.resultOfConverting(amount: amount,
                               ofCurrencyAtCode: "",
                               toCurrencyAtCode: "") { result in
            actualResult = result
            expectation.fulfill()
        }
        
        //Then
        waitForExpectations(timeout: 2.1) {_ in
            XCTAssertEqual(expectedResult, actualResult)
        }
    }
    
    func testAPIForIncorrectInputValuesAndNoServersideError() throws {
        //Given
        let amount = 404.0
        let expectedResult: ExchangeRatesAPI.DataTaskResult = .failure(.notFound)
        var actualResult: ExchangeRatesAPI.DataTaskResult?
        
        let expectation = expectation(description: "Expectation of " + #function)
        
        //When
        api.resultOfConverting(amount: amount,
                               ofCurrencyAtCode: "",
                               toCurrencyAtCode: "") { result in
            actualResult = result
            expectation.fulfill()
        }
        
        //Then
        waitForExpectations(timeout: 2.1) {_ in
            XCTAssertEqual(expectedResult, actualResult)
        }
    }
    
    func testAPIForServersideError() throws {
        //Given
        let amount = -1.0
        let expectedResult: ExchangeRatesAPI.DataTaskResult = .failure(.unknownServersideError(URLError(.unknown)))
        var actualResult: ExchangeRatesAPI.DataTaskResult?
        
        let expectation = expectation(description: "Expectation of " + #function)
        
        //When
        api.resultOfConverting(amount: amount,
                               ofCurrencyAtCode: "",
                               toCurrencyAtCode: "") { result in
            actualResult = result
            expectation.fulfill()
        }
        
        //Then
        waitForExpectations(timeout: 2.1) {_ in
            XCTAssertEqual(expectedResult, actualResult)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
