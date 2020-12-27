//
//  InputViewController.swift
//  taskapp
//
//  Created by Norihiro.Nakano on 2020/12/09.
//  Copyright © 2020 Norihiro.Nakano. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var category: UITextField!
    
    var task:Task!
    let realm = try! Realm()
    var Data:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //背景を押したらdismissKeyboardメソッドを呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        category.text = task.category
    }
    
    //キーボードを閉じる
    @objc func dismissKeyboard(){
        view.endEditing(true) //endEditing:
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{  //Realmインスタンスの書き込みトランザクション(write)でオブジェクトの追加、削除、変更を行う。
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.category.text!
            self.realm.add(self.task, update: .modified) //addメソッドでデータの追加
            //上記が実行されるとデータベースにデータが書き込まれる
        }
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録
    func setNotification(task:Task){
       
        let content = UNMutableNotificationContent()
        //UNMutableNotificationContent:通知内容を設定するクラス
        //UNMutableNotificationContentのインスタンスを作成してから、通知内容を設定する
        
        //タイトルと内容を設定（中身がない場合はメッセージなしで音だけの通知になるので「〜なし」を表示する）
        if task.title == "" {
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        
        content.sound = UNNotificationSound.default
        //UNNotificationSound:通知の配信時に再生される音を設定するクラス
        
        //通知が発動するトリガーを設定（今回は日付）
        let calender = Calendar.current //ユーザーの現在のカレンダー
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        //dateComponents:カレンダーのタイムゾーンを使用して、日付のコンポーネントを返す。
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        //UNCalendarNotificationTrigger：特定の日付に通知が配信されるようにするトリガー条件
        
        //identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        //UNNotificationRequest:通知の内容やトリガーの情報を含めた通知を作成
        
        //requestをUNUserNotificationCenterにaddすることでローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            // errorがnilならローカル通知の登録に成功したと表示する。errorが存在すればerrorを表示する。
            print(error ?? "ローカル通知登録　OK")
            //※print(error ?? "ローカル通知登録　OK")の「？？」演算子は左の値がnilでなければ左の値を返す。nilであれば右の値を返す演算子
            //ここでは、errorがnilでなければ（エラーが存在すれば）error内容が表示される。nilなら「ローカル通知登録　OK」がログに表示される
        }
        
        //未通知のローカル通知一覧をログ出力。（登録が成功するたびに、現在の未通知のログが出力される）
        //例　1つ目の通知が登録成功するとログには ローカル通知登録OKのメッセージとidentifierが0の通知内容がログに出てくる
        //　　１つ目の通知がある状態で、２つ目の通知が登録成功すると、ローカル通知登録OKのメッセージと現時点で未通知のログが出力される。
        //　（今回の場合は、メッセージが出た後、identifierが0の通知内容とidentifierが1の通知内容のログが出力）
        
        center.getPendingNotificationRequests { (requests:[UNNotificationRequest]) in
            for request in requests {
                print("/--------------")
                print(request)
                print("/--------------")
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
