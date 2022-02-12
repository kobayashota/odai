//
//  UIViewController+Extension.swift
//  sampleFireStore
//
//  Created by 小林　将太 on 2022/02/12.
//

import UIKit

extension UIViewController {
    // キーボードを閉じる
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
