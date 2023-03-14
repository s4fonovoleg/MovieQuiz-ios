import UIKit

final class MovieQuizViewController: UIViewController {
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

	private struct QuizQuestion {
		let image: String
		let text: String
		let correctAnswer: Bool
	}
	
	private struct QuizStepViewModel {
		let image: UIImage
		let question: String
		let questionNumber: String
	}

	private struct QuizResultsViewModel {
		let title: String
		let text: String
		let buttonText: String
	}
	
	private var currentQuestionIndex: Int = 0
	private var correctAnswersCount: Int = 0
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var textLabel: UILabel!
	@IBOutlet weak var counterLabel: UILabel!
	
	@IBAction func noButtonClicked(_ sender: UIButton) {
		let currentQuestion = questions[currentQuestionIndex]

		showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
	}

	@IBAction func yesButtonClicked(_ sender: UIButton) {
		let currentQuestion = questions[currentQuestionIndex]

		showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
	}
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		showNextQuestionOrResults()
	}
	
	private func show(quiz step: QuizStepViewModel) {
		imageView.image = step.image
		textLabel.text = step.question
		counterLabel.text = step.questionNumber
	}

	private func show(quiz result: QuizResultsViewModel) {
		let alert = UIAlertController(
			title: result.text,
			message: result.title,
			preferredStyle: .alert)

		let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
			self.currentQuestionIndex = 0
			self.showNextQuestionOrResults()
		}

		alert.addAction(action)

		self.present(alert, animated: true, completion: nil)
	}

	private func convert(model: QuizQuestion) -> QuizStepViewModel {
		return QuizStepViewModel(
			image: UIImage(named: model.image) ?? UIImage(),
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
	}
	
	private func showAnswerResult(isCorrect: Bool) {
		imageView.layer.masksToBounds = true
		imageView.layer.borderWidth = 8
		imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
		imageView.layer.cornerRadius = 20
		
		if isCorrect {
			correctAnswersCount += 1
		}
		currentQuestionIndex += 1
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.showNextQuestionOrResults()
		}
	}
	
	private func showNextQuestionOrResults() {
		imageView.layer.borderColor = UIColor.black.cgColor

		if currentQuestionIndex < questions.count {
			let currentQuestion = questions[currentQuestionIndex]
			let questionViewModel = convert(model: currentQuestion)

			show(quiz: questionViewModel)
		} else {
			let result = QuizResultsViewModel(
				title: "Раунд окончен!",
				text: "Ваш результат:\(correctAnswersCount)/10",
				buttonText: "Сыграть еще раз")

			correctAnswersCount = 0
			currentQuestionIndex = 0

			show(quiz: result)
		}
	}
}
