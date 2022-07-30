//
//  CheckViewController.swift
//  odai
//
//  Created by Shota Kobayashi on 2021/08/20.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

final class CheckViewController: UIViewController {
    var odaiString = String()
    @IBOutlet private weak var odaiLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    let db = Firestore.firestore()
    var dataSets: [AnswerModel] = []
    var idString = String()
    private let disposeBag = DisposeBag()

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

        cell.answerNumberOfLines = 0

        cell.answer = "\(dataSets[indexPath.row].userName)さんの回答\n\(dataSets[indexPath.row].answers)"

        cell.tag = indexPath.row

        cell.tapLike.subscribe(onNext: { [weak self] _ in
            self?.like(cell.tag)
        }).disposed(by: disposeBag)

        cell.count = String(dataSets[indexPath.row].likeCount)

        if let likeFlag = dataSets[indexPath.row].likeFlagDic[idString] {
            if likeFlag {
                cell.likeImage = UIImage(named: "like")
            } else {
                cell.likeImage = UIImage(named: "notlike")
            }
        }

        return cell
    }

    private func like(_ tag: Int) {
        guard let isLike = dataSets[tag].likeFlagDic[idString] else {
            debugPrint("isLike nil")
            db.collection("Answers").document(dataSets[tag].docID).setData(["likeFlagDic": [idString: true]], merge: true)
            return
        }

        var count = Int()

        if isLike {
            count = dataSets[tag].likeCount - 1
            db.collection("Answers").document(dataSets[tag].docID).setData(["likeFlagDic": [idString: false]], merge: true)
        } else {
            count = dataSets[tag].likeCount + 1
            db.collection("Answers").document(dataSets[tag].docID).setData(["likeFlagDic": [idString: true]], merge: true)
        }

        db.collection("Answers").document(dataSets[tag].docID).updateData(["like": count], completion: nil)
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
