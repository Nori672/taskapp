//
//  Task.swift
//  taskapp
//
//  Created by Norihiro.Nakano on 2020/12/16.
//  Copyright © 2020 Norihiro.Nakano. All rights reserved.
//

import RealmSwift

class Task: Object{
    @objc dynamic var category = "" //カテゴリー

    @objc dynamic var id = 0 // 管理用ID(プライマリーキー)
    
    @objc dynamic var title = "" //タイトル
    
    @objc dynamic var contents = "" //内容
    
    @objc dynamic var date = Date() //日時
    
    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
