import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
	func setButtonsEnabled(isEnabled: Bool) {
		
	}
	
	func show(quiz step: MovieQuiz.QuizStepViewModel) {
		
	}
	
	func show(quiz result: MovieQuiz.QuizResultsViewModel) {
		
	}
	
	func highlightImageBorder(isCorrect: Bool) {
		
	}
	
	func showLoadingIndicator() {
		
	}
	
	func hideLoadingIndicator() {
		
	}
	
	func showNetworkError(message: String) {
		
	}
}

final class MovieQuizPresenterTests: XCTestCase {
	func testPresenterConvertModel() throws {
		let viewControllerMock = MovieQuizViewControllerMock()
		let presenter = MovieQuizPresenter(viewControler: viewControllerMock)
		
		let question = QuizQuestion(image: Data(), text: "Question", correctAnswer: true)
		let viewModel = presenter.convert(model: question)
		
		XCTAssertNotNil(viewModel.image)
		XCTAssertEqual(viewModel.question, "Question")
		XCTAssertEqual(viewModel.questionNumber, "1/10")
	}
}
