//
//  AnswerModel.swift
//  odai
//
//  Created by Shota Kobayashi on 2021/08/20.
//

import Foundation

struct AnswerModel {
    let answers: String
    let userName: String
    let docID: String
    let likeCount: Int
    let likeFlagDic: [String: Bool]
}
