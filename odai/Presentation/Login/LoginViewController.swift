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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = nil
        navigationController?.isNavigationBarHidden = true
    }

    private func login() {
        Auth.auth().signInAnonymously { [weak self] result, error in
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
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        login()
        return textField.resignFirstResponder()
    }
}
