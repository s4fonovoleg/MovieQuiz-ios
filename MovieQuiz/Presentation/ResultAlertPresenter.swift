//
//  ResultAlertPresenter.swift
//  MovieQuiz
//
//  Created by Олег Сафонов on 28.03.2023.
//

import Foundation
import UIKit

class ResultAlertPresenter: AlertPresenterProtocol {
	weak var delegate: UIViewController?

	init(delegate: UIViewController) {
		self.delegate = delegate
	}

	func show(model: AlertModel) {
		guard let delegate = self.delegate else { return }

		let alert = UIAlertController(
			title: model.title,
			message: model.message,
			preferredStyle: .alert)

		let action = UIAlertAction(title: model.buttonText, style: .default) {_ in
			model.completion()
		}

		alert.addAction(action)
		delegate.present(alert, animated: true, completion: nil)
	}
}
