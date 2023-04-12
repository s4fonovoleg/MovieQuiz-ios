//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Олег Сафонов on 27.03.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
	func didReceiveNextQuestion(question: QuizQuestion?)
	func didLoadDataFromServer()
	func didFailToLoadData(with error: Error)
}
