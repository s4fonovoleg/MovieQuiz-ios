//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Олег Сафонов on 23.04.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
	private var currentQuestionIndex: Int = 0
	let questionsAmount: Int = 10
	var correctAnswersCount: Int = 0
	var currentQuestion: QuizQuestion?
	
	private var questionFactory: QuestionFactoryProtocol?
	private weak var viewControler: MovieQuizViewControllerProtocol?
	private var statisticService = StatisticServiceImplementation()
	
	init(viewControler: MovieQuizViewControllerProtocol) {
		self.viewControler = viewControler
		
		questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
		viewControler.showLoadingIndicator()
		questionFactory?.loadData()
	}

	// MARK: QuestionFactoryDelegate
	func didLoadDataFromServer() {
		viewControler?.hideLoadingIndicator()
		showNextQuestionOrResults()
	}
	
	func didFailToLoadData(with error: Error) {
		viewControler?.hideLoadingIndicator()
		viewControler?.showNetworkError(message: error.localizedDescription)
	}
	
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else {
			return
		}
		
		currentQuestion = question
		
		let viewModel = convert(model: question)
		
		DispatchQueue.main.async { [weak self] in
			self?.viewControler?.show(quiz: viewModel)
		}
	}
	
	func restartGame() {
		correctAnswersCount = 0
		currentQuestionIndex = 0
		questionFactory?.requestNextQuestion()
	}
	
	func isLastQuestion() -> Bool {
		currentQuestionIndex == questionsAmount
	}
	
	func switchToNextQuestion() {
		currentQuestionIndex += 1
	}
	
	// MARK: Buttons
	func yesButtonClicked() {
		didAnswer(givenAnswer: true)
	}
	
	func noButtonClicked() {
		didAnswer(givenAnswer: false)
	}
	
	func convert(model: QuizQuestion) -> QuizStepViewModel {
		return QuizStepViewModel(
			image: UIImage(data: model.image) ?? UIImage(),
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
	}
	
	// MARK: Private functions
	private func didAnswer(givenAnswer: Bool) {
		guard let currentQuestion = currentQuestion else {
			return
		}

		let isCorrect = currentQuestion.correctAnswer == givenAnswer;

		if isCorrect {
			correctAnswersCount += 1
		}

		showAnswerResult(isCorrect: isCorrect)
	}
	
	private func showAnswerResult(isCorrect: Bool) {
		viewControler?.setButtonsEnabled(isEnabled: false)
		viewControler?.highlightImageBorder(isCorrect: isCorrect)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self = self else { return }
			
			switchToNextQuestion()
			self.viewControler?.setButtonsEnabled(isEnabled: true)
			self.showNextQuestionOrResults()
		}
	}
	
	private func showNextQuestionOrResults() {
		if !isLastQuestion() {
			questionFactory?.requestNextQuestion()
		} else {
			statisticService.store(correct: correctAnswersCount, total: questionsAmount)
			questionFactory?.resetShowedQuestions()

			let result = QuizResultsViewModel(
				title: "Раунд окончен!",
				text: getGameResultMessage(),
				buttonText: "Сыграть еще раз")

			restartGame()

			viewControler?.show(quiz: result)
		}
	}
	
	private func getGameResultMessage() -> String {
		let bestGame = statisticService.bestGame
		let bestCorrectAnswers = bestGame.correct
		let bestTotal = bestGame.total
		let bestDate = bestGame.date.dateTimeString

		let message = """
			Ваш результат:\(correctAnswersCount)/10
			Количество сыграных квизов: \(statisticService.gamesCount)
			Рекорд: \(bestCorrectAnswers)/\(bestTotal) (\(bestDate))
			Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
			"""
		return message
	}
}
