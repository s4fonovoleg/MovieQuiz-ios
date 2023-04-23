//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Олег Сафонов on 23.04.2023.
//

import UIKit

final class MovieQuizPresenter {
	let questionsAmount: Int = 10
	private var currentQuestionIndex: Int = 0

	func isLastQuestion() -> Bool {
		currentQuestionIndex == questionsAmount
	}
	
	func resetQuestionIndex() {
		currentQuestionIndex = 0
	}
	
	func switchToNextQuestion() {
		currentQuestionIndex += 1
	}
	
	func convert(model: QuizQuestion) -> QuizStepViewModel {
		return QuizStepViewModel(
			image: UIImage(data: model.image) ?? UIImage(),
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
	}
}
