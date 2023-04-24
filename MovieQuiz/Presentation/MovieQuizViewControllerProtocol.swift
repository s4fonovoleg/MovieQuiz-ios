//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Олег Сафонов on 24.04.2023.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
	func show(quiz step: QuizStepViewModel)
	func show(quiz result: QuizResultsViewModel)
	func highlightImageBorder(isCorrect: Bool)
	
	func showLoadingIndicator()
	func hideLoadingIndicator()
	func showNetworkError(message: String)
	
	func setButtonsEnabled(isEnabled: Bool)
}
