//
//  CheckViewController.swift
//  sampleFireStore
//
//  Created by Shota Kobayashi on 2021/08/20.
//

import UIKit
import Firebase

final class CheckViewController: UIViewController {
    var odaiString = String()
    @IBOutlet private weak var odaiLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    var dataSets: [AnswerModel] = []
    var idString = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        odaiLabel.text = odaiString
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "CheckListTableViewCell", bundle: nil), forCellReuseIdentifier: "CheckListTableViewCell")
        if UserDefaults.standard.object(forKey: "documentID") != nil {
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadData()
        navigationController?.isNavigationBarHidden = false
    }
}

extension CheckViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Comment", bundle: nil)

        guard let vc = storyboard.instantiateViewController(withIdentifier: "comment") as? CommentViewController else {
            return
        }

        vc.idString = dataSets[indexPath.row].docID
        vc.kaitouString = "\(dataSets[indexPath.row].userName)さんの回答\n\(dataSets[indexPath.row].answers)"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CheckViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckListTableViewCell", for: indexPath) as! CheckListTableViewCell

        cell.answerLabel.numberOfLines = 0
        cell.answerLabel.text = "\(dataSets[indexPath.row].userName)さんの回答\n\(dataSets[indexPath.row].answers)"
        cell.likeButton.tag = indexPath.row
        cell.countLabel.text = String(dataSets[indexPath.row].likeCount)
        cell.likeButton.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)

        if let likeFlag = dataSets[indexPath.row].likeFlagDic[idString] {
            if likeFlag {
                cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
            } else {
                cell.likeButton.setImage(UIImage(named: "notlike"), for: .normal)
            }
        }

        return cell
    }

    @objc private func like(_ sender: UIButton) {
        var count = Int()
        let flag = dataSets[sender.tag].likeFlagDic[idString]

        if flag == nil {

            count = dataSets[sender.tag].likeCount + 1
            db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic": [idString: true]], merge: true)

        } else {

            if flag == true {

                count = dataSets[sender.tag].likeCount - 1
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic": [idString: false]], merge: true)

            } else {
                count = dataSets[sender.tag].likeCount + 1
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic": [idString: true]], merge: true)

            }
        }

        db.collection("Answers").document(dataSets[sender.tag].docID).updateData(["like": count], completion: nil)
        tableView.reloadData()
    }

    private func loadData() {
        db.collection("Answers").order(by: "postDate").addSnapshotListener { snapShot, error in
            self.dataSets = []
            if error != nil {
                return
            }

            if let snapShotDoc = snapShot?.documents {
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let answer = data["answer"] as? String,
                       let userName = data["userName"] as? String,
                       let likeCount = data["like"] as? Int,
                       let likeFlagDic = data["likeFlagDic"] as? [String: Bool] {

                        if likeFlagDic[doc.documentID] != nil {

                            let answerModel = AnswerModel(answers: answer,
                                                          userName: userName,
                                                          docID: doc.documentID,
                                                          likeCount: likeCount,
                                                          likeFlagDic: likeFlagDic)
                            self.dataSets.append(answerModel)
                        }
                    }
                }
                self.dataSets.reverse()
                self.tableView.reloadData()
            }
        }
    }
}
