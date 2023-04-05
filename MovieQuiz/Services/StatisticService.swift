//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Олег Сафонов on 03.04.2023.
//

import Foundation

struct GameRecord: Codable, Comparable {
	let correct: Int
	let total: Int
	let date: Date
	
	static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
		lhs.correct < rhs.correct
	}
}

protocol StatisticService {
	var totalAccuracy: Double { get }
	var gamesCount: Int { get }
	var totalCorrectAnswersCount: Int { get }
	var totalQuestionsCount: Int { get }
	var bestGame: GameRecord { get }
	
	func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
	private let userDefaults = UserDefaults.standard
	
	private enum Keys: String {
		case correct, totalAccuracy, gamesCount, totalCorrectAnswersCount, totalQuestionsCount, bestGame
	}
	
	var totalAccuracy: Double {
		get {
			let totalAccuracy = userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
			
			return totalAccuracy
		}
		set {
			userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
		}
	}
	
	var gamesCount: Int {
		get {
			let gamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
			
			return gamesCount
		}
		set {
			userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
		}
	}
	
	var totalCorrectAnswersCount: Int {
		get {
			let totalCorrectAnswersCount = userDefaults.integer(forKey: Keys.totalCorrectAnswersCount.rawValue)
			
			return totalCorrectAnswersCount
		}
		set {
			userDefaults.set(newValue, forKey: Keys.totalCorrectAnswersCount.rawValue)
		}
	}
	
	var totalQuestionsCount: Int {
		get {
			let totalQuestionsCount = userDefaults.integer(forKey: Keys.totalQuestionsCount.rawValue)
			
			return totalQuestionsCount
		}
		set {
			userDefaults.set(newValue, forKey: Keys.totalQuestionsCount.rawValue)
		}
	}
	
	var bestGame: GameRecord {
		get {
			guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
			let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
				return .init(correct: 0, total: 0, date: Date())
			}

			return record
		}
		set {
			guard let data = try? JSONEncoder().encode(newValue) else {
				print("Невозможно сохранить результат")
				return
			}

			userDefaults.set(data, forKey: Keys.bestGame.rawValue)
		}
	}
	
	func store(correct count: Int, total amount: Int) {
		let gameResult = GameRecord(correct: count, total: amount, date: Date())
		if (gameResult > bestGame) {
			bestGame = gameResult
		}
		
		totalCorrectAnswersCount += count
		totalQuestionsCount += amount
		gamesCount += 1
		totalAccuracy = Double(totalCorrectAnswersCount) / Double(totalQuestionsCount) * 100
	}
}
