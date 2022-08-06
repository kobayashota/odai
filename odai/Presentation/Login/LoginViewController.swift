//
//  LoginViewController.swift
//  odai
//
//  Created by kobashou06 on 2021/08/07.
//

import UIKit
import Firebase

final class LoginViewController: UIViewController {
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var decisionButton: UIButton!
    private let indicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupIndicator()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = nil
        navigationController?.isNavigationBarHidden = true
    }

    private func login() {
        DispatchQueue.main.async { [weak self] in
            self?.view.alpha = 0.8
            self?.indicatorView.startAnimating()
        }

        Auth.auth().signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.view.alpha = 1.0
                self?.indicatorView.stopAnimating()
            }

            if let error = error {
                self?.showAlert(message: error.localizedDescription)
                return
            }

            let user = result?.user
            debugPrint(user!)

            guard let username = self?.textField.text else {
                UserDefaults.standard.set("名無し", forKey: "userName")
                self?.showTheme()
                return
            }

            UserDefaults.standard.set(username, forKey: "userName")

            self?.showTheme()
        }
    }

    @IBAction private func done(_ sender: Any) {
        login()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController.init(title: "ログイン失敗", message: message, preferredStyle: .alert)
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
            debugPrint("ログイン失敗")
        }
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }

    private func showTheme() {
        performSegue(withIdentifier: "Theme", sender: nil)
    }

    private func setupIndicator() {
        indicatorView.style = .large
        indicatorView.center.x = view.center.x
        indicatorView.center.y = decisionButton.center.y
        indicatorView.color = .white
        // アニメーション停止と同時に隠す設定
        indicatorView.hidesWhenStopped = true
        view.addSubview(indicatorView)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        login()
        return textField.resignFirstResponder()
    }
}
