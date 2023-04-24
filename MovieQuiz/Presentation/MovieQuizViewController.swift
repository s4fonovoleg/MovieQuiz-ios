import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
	// MARK: IBOutlets
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var textLabel: UILabel!
	@IBOutlet private weak var counterLabel: UILabel!
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var noButton: UIButton!
	@IBOutlet private weak var yesButton: UIButton!

	// MARK: Private properties
	private var presenter: MovieQuizPresenter?
	private var resultAlertPresenter: ResultAlertPresenter?

	// MARK: - Actions
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		presenter?.noButtonClicked()
	}

	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		presenter?.yesButtonClicked()
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		resultAlertPresenter = ResultAlertPresenter(delegate: self)
		presenter = MovieQuizPresenter(viewControler: self)
		
		activityIndicator.hidesWhenStopped = true;
		imageView.layer.borderColor = UIColor.ypBlack.cgColor
		imageView.layer.borderWidth = 8
		imageView.layer.cornerRadius = 20
		imageView.layer.masksToBounds = true
	}

	func setButtonsEnabled(isEnabled: Bool) {
		noButton.isEnabled = isEnabled
		yesButton.isEnabled = isEnabled
	}

	func show(quiz step: QuizStepViewModel) {
		hideLoadingIndicator()

		imageView.layer.borderColor = UIColor.ypBlack.cgColor
		imageView.image = step.image
		textLabel.text = step.question
		counterLabel.text = step.questionNumber
	}

	func show(quiz result: QuizResultsViewModel) {
		guard let resultAlertPresenter = resultAlertPresenter else {
			return
		}

		let alertModel = AlertModel(
			title: result.title,
			message: result.text,
			buttonText: result.buttonText,
			completion: { [weak self] in
				self?.presenter?.restartGame()
			})
		
		resultAlertPresenter.show(model: alertModel)
	}

	func highlightImageBorder(isCorrect: Bool) {
		imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
	}
	
	//MARK: Loading indicator
	func showLoadingIndicator() {
		activityIndicator.startAnimating()
	}

	func hideLoadingIndicator() {
		activityIndicator.stopAnimating()
	}

	func showNetworkError(message: String) {
		hideLoadingIndicator()

		guard let resultAlertPresenter = resultAlertPresenter else {
			return
		}

		let alertModel = AlertModel(
			title: "Ошибка",
			message: message,
			buttonText: "Попробовать еще раз",
			completion: { [weak self] in
				self?.presenter?.restartGame()
			})

		resultAlertPresenter.show(model: alertModel)
	}
}
