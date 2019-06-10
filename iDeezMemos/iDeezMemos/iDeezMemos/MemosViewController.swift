//
//  MemosViewController.swift
//  iDeezMemos
//
//  Created by Cistudent on 4/30/19.
//  Copyright © 2019 Hwang Clan. All rights reserved.
//
import CoreData
import UIKit

class MemosViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    var currentMemo: Memo?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtBody: UITextField!
    @IBOutlet weak var lblDateCreated: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var makingChanges: Bool?
    var lastModified: Date?
    //var priority: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let today = Date()
        if currentMemo != nil {
            
            txtTitle.text = currentMemo!.memoTitle
            txtBody.text = currentMemo!.memoBody
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            if currentMemo!.dateCreated != nil {
                lblDateCreated.text = formatter.string(from: today)
            }
            
            //lastModified = currentMemo!.lastModified as Date?
            
            //priority = currentMemo!.priority
        }
        
        makingChanges = false
        self.changeModes(self)
        let textFields: [UITextField] = [txtTitle, txtBody]
        
        for textField in textFields {
            textField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)), for: UIControlEvents.editingDidEnd)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardNotifications()
    }
    
    func changeModes(_ sender: Any) {
        let textFields: [UITextField] = [txtTitle, txtBody]
        
        if makingChanges == false {
            for textField in textFields {
                textField.isEnabled = true
                textField.borderStyle = UITextBorderStyle.roundedRect
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                target: self,
                                                                action: #selector(self.saveMemo))
        } else {
            for textField in textFields {
                textField.isEnabled = false
                textField.borderStyle = UITextBorderStyle.none
            }
            /*
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                target: self,
                                                                action: #selector(self.saveMemo))
 */
            navigationItem.rightBarButtonItem = nil
        }
    }
 
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        currentMemo?.memoTitle = txtTitle.text
        currentMemo?.memoBody = txtBody.text
        return true
    }
    /*
    func saveDate(date: Date) {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        if currentMemo != nil {
            currentMemo?.dateCreated = date as NSDate?
            currentMemo?.lastModified = today as NSDate?
        } else {
            currentMemo?.dateCreated = today as NSDate?
            currentMemo?.lastModified = today as NSDate?
        }
        
        appDelegate.saveContext()
        
        lblDateCreated.text = formatter.string(from: currentMemo?.dateCreated as Date!)
    }
    */
    // SAVE MEMO
    
    func saveMemo() {
        let today = Date()
        
        currentMemo?.dateCreated = today as NSDate?
        currentMemo?.lastModified = today as NSDate?
        if currentMemo == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentMemo = Memo(context: context)
            
        }
        
        appDelegate.saveContext()
        makingChanges = false
        changeModes(self)
    }
    
    
    // KEYBOARD STUFF
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector:
            #selector(MemosViewController.keyboardDidShow(notification:)), name:
            NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:
            #selector(MemosViewController.keyboardWillHide(notification:)), name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardSize.height
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = 0
        
        self.scrollView.contentInset = contentInset
        self.scrollView.contentInset = UIEdgeInsets.zero
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSortSettings" {
            let sortController = segue.destination as! SortViewController
            
            sortController.delegate = self
        }
    }
 */

}
