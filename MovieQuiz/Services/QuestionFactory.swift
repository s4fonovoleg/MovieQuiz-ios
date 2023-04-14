//
//  QuestionFactory .swift
//  MovieQuiz
//
//  Created by Олег Сафонов on 24.03.2023.
//

import Foundation

struct MockQuiezQuestion {
	let image: String
	let text: String
	let correctAnswer: Bool
}

final class QuestionFactory : QuestionFactoryProtocol {
	private static let mockQuestionText = "Рейтинг этого фильма больше, чем 6?"
	
	private let mockQuestions: [MockQuiezQuestion] = [
		MockQuiezQuestion(
			image: "The Godfather",
			text: mockQuestionText,
			correctAnswer: true),
		MockQuiezQuestion(
			image: "The Dark Knight",
			text: mockQuestionText,
			correctAnswer: true),
		MockQuiezQuestion(
			image: "Kill Bill",
			text: mockQuestionText,
			correctAnswer: true),
		MockQuiezQuestion(
			image: "The Avengers",
			text: mockQuestionText,
			correctAnswer: true),
		MockQuiezQuestion(
			image: "Deadpool",
			text: mockQuestionText,
			correctAnswer: true),
		MockQuiezQuestion(
			image: "The Green Knight",
			text: mockQuestionText,
			correctAnswer: true),
		MockQuiezQuestion(
			image: "Old",
			text: mockQuestionText,
			correctAnswer: false),
		MockQuiezQuestion(
			image: "The Ice Age Adventures of Buck Wild",
			text: mockQuestionText,
			correctAnswer: false),
		MockQuiezQuestion(
			image: "Tesla",
			text: mockQuestionText,
			correctAnswer: false),
		MockQuiezQuestion(
			image: "Vivarium",
			text: mockQuestionText,
			correctAnswer: false)
	]
	private var movies: [MostPopularMovie] = []
	
	private let lowestQuestionRating: Int = 6
	private var questionNumber: Int = 0
	private var indices: [Int] = []
	
	private let moviesLoader: MoviesLoading
	weak var delegate: QuestionFactoryDelegate?
	
	init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
		self.moviesLoader = moviesLoader
		self.delegate = delegate
	}
	
	func loadData() {
		moviesLoader.loadMovies() { [weak self] result in
			DispatchQueue.main.async {
				guard let self = self else { return }
				
				switch result {
				case .success(let mostPopularMovies):
					self.movies = mostPopularMovies.items
					self.resetShowedQuestions()
					self.delegate?.didLoadDataFromServer()
				case .failure(let error):
					self.delegate?.didFailToLoadData(with: error)
				}
			}
		}
	}
	
	func requestNextQuestion() {
		DispatchQueue.global().async { [weak self] in
			guard let self = self else { return }

			guard let index = indices[safe: questionNumber],
				  let movie = self.movies[safe: index] else {
				return
			}
			
			var imageData = Data()
			
			do {
				imageData = try Data(contentsOf: movie.resizedImageURL)
			} catch {
				print("Failed to load image")
			}
			
			let rating = Float(movie.rating) ?? 0
			let questionRating = (lowestQuestionRating..<10).randomElement() ?? 0
			let text = "Рейтинг этого фильма больше, чем \(questionRating)?"
			let correctAnswer = rating > Float(questionRating)
			let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
					
			questionNumber += 1
			
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.delegate?.didReceiveNextQuestion(question: question)
			}
		}
	}
	
	func resetShowedQuestions() {
		indices = (0..<movies.count).shuffled()
		questionNumber = 0
	}
}
