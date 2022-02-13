//
//  DismissKeyboardViewContoller.swift
//  sampleFireStore
//
//  Created by 小林　将太 on 2022/02/13.
//

import UIKit

class DismissKeyboardViewContoller: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tappedDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tappedDismissKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tappedDismissKeyboard)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}
