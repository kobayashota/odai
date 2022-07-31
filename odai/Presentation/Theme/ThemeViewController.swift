//
//  ViewController.swift
//  odai
//
//  Created by kobashou06 on 2021/08/07.
//

import UIKit
import Firebase

final class ThemeViewController: UIViewController {
    private let db1 = Firestore.firestore().collection("Odai").document("AOoJ18TmBOrB6xlzS3ma")
    private let db2 = Firestore.firestore()
    var userName = String()
    var idString = String()
    @IBOutlet private weak var odaiLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.object(forKey: "userName") != nil {
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if UserDefaults.standard.object(forKey: "documentID") != nil {
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        } else {
            idString = db2.collection("Answers").document().path
            print(idString)
            idString = String(idString.dropFirst(8))
            UserDefaults.standard.setValue(idString, forKey: "documentID")
        }

        navigationController?.isNavigationBarHidden = true
        loadQuestionData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Check" {
            let next = segue.destination as? CheckViewController
            next?.odaiString = odaiLabel.text ?? ""
        }
    }

    private func loadQuestionData() {
        db1.getDocument { snapShot, error in
            if error != nil {
                return
            }

            let data = snapShot?.data()
            self.odaiLabel.text = data?["odaiText"] as? String
        }
    }

    @IBAction private func send(_ sender: Any) {
        db2.collection("Answers").document(idString).setData(
            [
                "answer": textView.text as Any,
                "userName": userName as Any,
                "postDate": Date().timeIntervalSince1970,
                "like": 0,
                "likeFlagDic": [idString: false]
            ]
        )

        let alert = UIAlertController(title: "投稿完了！", message: "みんなの回答を見てみよう！", preferredStyle: .actionSheet)
        let doneAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(doneAction)

        present(alert, animated: true, completion: nil)
        textView.text = ""
    }

    @IBAction private func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {

            try firebaseAuth.signOut()
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "documentID")
        } catch let error as NSError {
            debugPrint("サインアウトエラー", error)
        }
    }
}
