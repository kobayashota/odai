//
//  CheckListTableViewCell.swift
//  odai
//
//  Created by Shota Kobayashi on 2021/08/22.
//

import UIKit
import RxSwift

final class CheckListTableViewCell: UITableViewCell {
    @IBOutlet private weak var answerLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private let tapLikeSubject = PublishSubject<Void>()
    var tapLike: Observable<Void> { tapLikeSubject }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction private func tapLikeButton(_ sender: UIButton) {
        tapLikeSubject.onNext(())
    }

    var answer: String? {
        get {
            answerLabel.text
        }
        set {
            answerLabel.text = newValue
        }
    }

    var answerNumberOfLines: Int {
        get {
            answerLabel.numberOfLines
        }
        set {
            answerLabel.numberOfLines = newValue
        }
    }

    var likeImage: UIImage? {
        get {
            likeButton.currentImage
        }
        set {
            likeButton.setImage(newValue, for: .normal)
        }
    }

    var count: String? {
        get {
            countLabel.text
        }
        set {
            countLabel.text = newValue
        }
    }
}
