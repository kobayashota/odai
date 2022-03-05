//
//  CommentViewController.swift
//  sampleFireStore
//
//  Created by Shota Kobayashi on 2021/08/21.
//

import UIKit
import Firebase

final class CommentViewController: DismissKeyboardViewContoller {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var kaitouLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    private var activeTextField: UITextField?
    var idString = String()
    var kaitouString = String()
    var userName = String()
    let db = Firestore.firestore()
    var dataSets: [CommentModel] = []
    let screenSize = UIScreen.main.bounds.size

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        kaitouLabel.text = kaitouString

        if UserDefaults.standard.object(forKey: "userName") != nil {
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }

        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadData()
        navigationController?.isNavigationBarHidden = false
    }

    private func loadData() {
        db.collection("Answers").document(idString)
            .collection("comments").order(by: "postDate").addSnapshotListener { snapShot, error in

                self.dataSets = []

                if error != nil {
                    return
                }

                if let snapShotDoc = snapShot?.documents {
                    for doc in snapShotDoc {
                        let data = doc.data()
                        if let userName = data["userName"] as? String,
                           let comment = data["comment"] as? String,
                           let postDate = data["postDate"] as? Double {

                            let commentModel = CommentModel(userName: userName, comment: comment, postDate: postDate)
                            self.dataSets.append(commentModel)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
    }

    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        guard let textField = activeTextField else {
            return
        }

        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }

        let textFieldFrame = textField.convert(textField.frame, to: self.view)
        let textFieldLimit = textFieldFrame.origin.y + textField.frame.height + 8.0
        let keyboardHeight = rect.size.height
        let keyboardLimit = screenSize.height - keyboardHeight

        if textFieldLimit >= keyboardLimit {
            UIView.animate(withDuration: duration) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            }
        }
    }

    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}

        UIView.animate(withDuration: duration) {
            self.view.transform = .identity
        }
    }

    @IBAction func sendAction(_ sender: Any) {
        guard let text = textField.text else {
            return
        }

        db.collection("Answers")
            .document(idString)
            .collection("comments")
            .document()
            .setData([
                "userName": userName as Any,
                "comment": text as Any,
                "postDate": Date().timeIntervalSince1970 as Any
            ])

        textField.resignFirstResponder()
        textField.text = ""
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
}

extension CommentViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }
}

extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        tableView.rowHeight = 200

        let commentLabel = cell.contentView.viewWithTag(1) as! UILabel
        commentLabel.numberOfLines = 0
        commentLabel.text = "\(dataSets[indexPath.row].userName)さん\n\(dataSets[indexPath.row].comment)"

        return cell
    }
}

extension CommentViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
}
