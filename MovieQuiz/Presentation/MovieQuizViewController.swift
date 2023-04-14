import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
	// MARK: Properties
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var textLabel: UILabel!
	@IBOutlet private weak var counterLabel: UILabel!
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var noButton: UIButton!
	@IBOutlet private weak var yesButton: UIButton!

	private let questionsAmount: Int = 10
	private var currentQuestionIndex: Int = 0
	private var correctAnswersCount: Int = 0

	private var questionFactory: QuestionFactoryProtocol?
	private var statisticService: StatisticService?
	private var presenter: ResultAlertPresenter?
	private var currentQuestion: QuizQuestion?

	// MARK: - Actions
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		guard let currentQuestion = currentQuestion else {
			return
		}

		showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
	}

	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		guard let currentQuestion = currentQuestion else {
			return
		}

		showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
	}

	//MARK: Loading indicator
	private func showLoadingIndicator() {
		activityIndicator.startAnimating()
	}

	private func hideLoadingIndicator() {
		activityIndicator.stopAnimating()
	}

	// MARK: Network data loading
	func didLoadDataFromServer() {
		hideLoadingIndicator()
		showNextQuestionOrResults()
	}

	func didFailToLoadData(with error: Error) {
		hideLoadingIndicator()
		showNetworkError(message: error.localizedDescription)
	}

	private func showNetworkError(message: String) {
		hideLoadingIndicator()

		guard let presenter = presenter else {
			return
		}

		let alertModel = AlertModel(
			title: "Ошибка",
			message: message,
			buttonText: "Попробовать еще раз",
			completion: { [weak self] in
				self?.questionFactory?.loadData()
			})

		presenter.show(model: alertModel)
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		activityIndicator.hidesWhenStopped = true;
		
		questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
		statisticService = StatisticServiceImplementation()
		presenter = ResultAlertPresenter(delegate: self)
		
		imageView.layer.borderColor = UIColor.ypBlack.cgColor
		imageView.layer.borderWidth = 8
		imageView.layer.cornerRadius = 20
		imageView.layer.masksToBounds = true
		
		showLoadingIndicator()
		questionFactory?.loadData()
	}

	// MARK: - QuestionFactoryDelegate
	func didReceiveNextQuestion(question: QuizQuestion?) {
		hideLoadingIndicator()
		guard let question = question else { return }
		
		currentQuestion = question
		
		let viewModel = convert(model: question)
		
		DispatchQueue.main.async { [weak self] in
			self?.show(quiz: viewModel)
		}
	}

	// MARK: - Private functions
	private func convert(model: QuizQuestion) -> QuizStepViewModel {
		return QuizStepViewModel(
			image: UIImage(data: model.image) ?? UIImage(),
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
	}

	private func setButtonsEnabled(isEnabled: Bool) {
		noButton.isEnabled = isEnabled
		yesButton.isEnabled = isEnabled
	}

	private func show(quiz step: QuizStepViewModel) {
		imageView.image = step.image
		textLabel.text = step.question
		counterLabel.text = step.questionNumber
	}

	private func show(quiz result: QuizResultsViewModel) {
		guard let presenter = presenter else {
			return
		}

		let alertModel = AlertModel(
			title: result.title,
			message: result.text,
			buttonText: result.buttonText,
			completion: { [weak self] in
				self?.currentQuestionIndex = 0
				self?.showNextQuestionOrResults()
			})
		
		presenter.show(model: alertModel)
	}
	
	private func showAnswerResult(isCorrect: Bool) {
		setButtonsEnabled(isEnabled: false)
		imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
		
		if isCorrect {
			correctAnswersCount += 1
		}
		currentQuestionIndex += 1
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self = self else { return }

			self.setButtonsEnabled(isEnabled: true)
			self.showNextQuestionOrResults()
		}
	}
	
	private func showNextQuestionOrResults() {
		imageView.layer.borderColor = UIColor.ypBlack.cgColor
		showLoadingIndicator()

		if currentQuestionIndex < questionsAmount {
			self.questionFactory?.requestNextQuestion()
		} else {
			statisticService?.store(correct: correctAnswersCount, total: questionsAmount)
			questionFactory?.resetShowedQuestions()

			let result = QuizResultsViewModel(
				title: "Раунд окончен!",
				text: getGameResultMessage(),
				buttonText: "Сыграть еще раз")

			correctAnswersCount = 0
			currentQuestionIndex = 0

			show(quiz: result)
		}
	}
	
	private func getGameResultMessage() -> String {
		var message = "Ваш результат:\(correctAnswersCount)/10\n"

		guard let statisticService = statisticService else {
			return message
		}
		
		let bestGame = statisticService.bestGame
		let bestCorrectAnswers = bestGame.correct
		let bestTotal = bestGame.total
		let bestDate = bestGame.date.dateTimeString

		message += """
			Количество сыграных квизов: \(statisticService.gamesCount)
			Рекорд: \(bestCorrectAnswers)/\(bestTotal) (\(bestDate))
			Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
			"""
		return message
	}
}
