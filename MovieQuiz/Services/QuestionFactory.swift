//
//  QuestionFactory .swift
//  MovieQuiz
//
//  Created by Олег Сафонов on 24.03.2023.
//

import Foundation

class QuestionFactory : QuestionFactoryProtocol {
	private static let questionText = "Рейтинг этого фильма больше чем 6?"
	
	private let questions: [QuizQuestion] = [
		QuizQuestion(
			image: "The Godfather",
			text: questionText,
			correctAnswer: true),
		QuizQuestion(
			image: "The Dark Knight",
			text: questionText,
			correctAnswer: true),
		QuizQuestion(
			image: "Kill Bill",
			text: questionText,
			correctAnswer: true),
		QuizQuestion(
			image: "The Avengers",
			text: questionText,
			correctAnswer: true),
		QuizQuestion(
			image: "Deadpool",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true),
		QuizQuestion(
			image: "The Green Knight",
			text: questionText,
			correctAnswer: true),
		QuizQuestion(
			image: "Old",
			text: questionText,
			correctAnswer: false),
		QuizQuestion(
			image: "The Ice Age Adventures of Buck Wild",
			text: questionText,
			correctAnswer: false),
		QuizQuestion(
			image: "Tesla",
			text: questionText,
			correctAnswer: false),
		QuizQuestion(
			image: "Vivarium",
			text: questionText,
			correctAnswer: false)
	]
	
	weak var delegate: QuestionFactoryDelegate?
	
	init(delegate: QuestionFactoryDelegate) {
		self.delegate = delegate
	}
	
	func requestNextQuestion() {
		guard let index = (0..<questions.count).randomElement() else {
			delegate?.didReceiveNextQuestion(question: nil)
			return
		}
		
		let question = questions[safe: index]
		delegate?.didReceiveNextQuestion(question: question)
	}
}
