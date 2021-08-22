//
//  LoginViewController.swift
//  sampleFireStore
//
//  Created by kobashou06 on 2021/08/07.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.text = nil
        navigationController?.isNavigationBarHidden = true
    }
    
    private func login() {
        Auth.auth().signInAnonymously { result, error in
            let user = result?.user
            debugPrint(user!)
            UserDefaults.standard.set(self.textField.text, forKey: "userName")
            let viewController = self.storyboard?.instantiateViewController(identifier: "view") as! ViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func done(_ sender: Any) {
        if textField.text != "" {
            login()
        } else {
            let alert = UIAlertController.init(title: "ユーザ名が空です",
                                               message: "ユーザ名を入力してください",
                                               preferredStyle: .alert)
            let confirmAction: UIAlertAction = UIAlertAction(title: "OK",
                                                             style: UIAlertAction.Style.default,
                                                             handler: { (action: UIAlertAction!) -> Void in
                                                                debugPrint("ログインしようとしましたが、入力欄が空でした")
                                                             })
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
        }
    }
}
