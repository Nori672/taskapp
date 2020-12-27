//
//  ViewController.swift
//  taskapp
//
//  Created by Norihiro.Nakano on 2020/12/09.
//  Copyright © 2020 Norihiro.Nakano. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

//UITableViewDelegate:TableViewのユーザー操作（タップ時の動作など）に関するプロトコル。
//UITableViewDataSource:TableViewの表示内容に関するプロトコル
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Filtering: UISearchBar! //UISearchBar:検索ボタンとテキストフィールドが一緒になったUI部品
    
    
    let realm = try! Realm() //ここでRealmのインスタンスの取得
    
    //.objects→Realmクラスのメソッド。クラスを指定して一覧を取得。
    //.sorted→Realmクラスのメソッド。ソートして配列を取り出す。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        Filtering.delegate = self
    }
    
    //セルの数を返すメソッド。UITableViewDataSourceプロトコルを使う時には必ず使わないといけないデリゲートメソッド。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    //各セルの内容を返すメソッド。UITableViewDataSourceプロトコルを使う時には必ず使わないといけないデリゲートメソッド。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil) //＋ボタンもしくはセルをタップした時にタスク作成・編集画面へ遷移させている
    }
    
    //セルが削除可能か・並び替え可能かなどどのような編集ができるかを返すメソッド。今回は削除を可能にしている。
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //セルが削除される時に呼び出されるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //削除するタスクを取得
            let task = self.taskArray[indexPath.row]
            
            //未通知のローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力(削除すると現時点で残っている未通知のログが出力される)
            //例　identifierが0,1,2の未通知のログがある状態で、identifierが1の通知を削除したとすると、
            //　　ログには今残っているidentifierが0と2の通知内容が出力される
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests{
                    print("------------")
                    print(request)
                    print("------------")
                }
            }
        }
    }
    
    //segueで画面遷移した時に行う処理。データであるTaskクラスを渡している。
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0{
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }

    
    
    //入力画面（タスク作成・編集画面）から戻ってきた時に、TableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //UISearchBarの検索ボタンを押した時の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let categoryText = searchBar.text
        let resultArray = try! Realm().objects(Task.self).filter("category BEGINSWITH '\(categoryText!)'")
        
        if categoryText == ""{
            //検索欄が空白の場合はリストを全表示
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        }else{
            //フィルタリングをかけた時の処理（検索結果に引っかかったものだけを表示。何も引っ掛からなければリストは非表示になる）
           taskArray = resultArray
        }
        tableView.reloadData()
    }


}

