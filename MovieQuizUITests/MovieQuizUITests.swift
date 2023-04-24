//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Олег Сафонов on 15.04.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		app = XCUIApplication()
		app.launch()

		continueAfterFailure = false
	}

	override func tearDownWithError() throws {
		try super.tearDownWithError()
		
		app.terminate()
		app = nil
	}
	
	func testYesButton() {
		tapButton("Yes")
	}
	
	func testNoButton() {
		tapButton("No")
	}
	
	func testQuizResultAlert() {
		sleep(2)
		for _ in 0..<10 {
			app.buttons["Yes"].tap()
			sleep(2)
		}

		let alert = app.alerts["Game results"]

		XCTAssertTrue(alert.exists)
		XCTAssertEqual(alert.label, "Раунд окончен!")
		XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
	}

	func testQuizResultAlertDismiss() {
		sleep(2)
		for _ in 0..<10 {
			app.buttons["Yes"].tap()
			sleep(2)
		}
		
		let alert = app.alerts["Game results"]
		alert.buttons.firstMatch.tap()

		sleep(2)
		
		let indexLabel = app.staticTexts["Index"]
		
		XCTAssertFalse(alert.exists)
		XCTAssertEqual(indexLabel.label, "1/10")
	}
	
	func tapButton(_ buttonIdentifier: String) {
		sleep(2)

		let firstPoster = app.images["Poster"]
		let firstPostedData = firstPoster.screenshot().pngRepresentation
		let indexLabel = app.staticTexts["Index"]

		XCTAssertTrue(firstPoster.exists)
		app.buttons[buttonIdentifier].tap()
		
		sleep(2)

		let secondPoster = app.images["Poster"]
		let secondPosterData = secondPoster.screenshot().pngRepresentation

		XCTAssertEqual(indexLabel.label, "2/10")
		XCTAssertTrue(secondPoster.exists)
		XCTAssertNotEqual(secondPosterData, firstPostedData)
	}
}
