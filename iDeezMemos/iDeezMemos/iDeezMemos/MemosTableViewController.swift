//
//  MemosTableViewController.swift
//  iDeezMemos
//
//  Created by Cistudent on 5/1/19.
//  Copyright © 2019 Hwang Clan. All rights reserved.
//

import UIKit
import CoreData

class MemosTableViewController: UITableViewController {
    
    var memos: [NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromDatabase() {
        // Read settings to enable sorting
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.kSortField)
        let sortAscending = settings.bool(forKey: Constants.kSortDirectionAscending)
        // Set up Core Data Context
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Memo")
        // Set up sorting
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptorArray = [sortDescriptor]
        // to sort by multiple fields, add more sort descriptors to the array
        request.sortDescriptors = sortDescriptorArray
        
        //Execute
        do {
            memos = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch . \(error), \(error.userInfo)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemosCell", for: indexPath)

        // Configure the cell...
        let memo = memos[indexPath.row] as? Memo
        cell.textLabel?.text = memo?.memoTitle
        
        //let formatter = DateFormatter()
        //formatter.dateStyle = .short
        
        //var dateStr = formatter.string(from: memo?.dateCreated as! Date)
        cell.detailTextLabel?.text = memo?.memoTitle
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let memo = memos[indexPath.row] as? Memo
            let context = appDelegate.persistentContainer.viewContext
            context.delete(memo!)
            do {
                try context.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
            loadDataFromDatabase()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMemo = memos[indexPath.row] as? Memo
        let title = selectedMemo!.memoTitle
        let actionHandler = { (action:UIAlertAction!) -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MemoController") as? MemosViewController
            controller?.currentMemo = selectedMemo
            self.navigationController?.pushViewController(controller!, animated: true)
        }
        
        let alertController = UIAlertController(title: "Memo selected",
                                                message: "Selected row: \(indexPath.row) (\(title))",
            preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let actionDetails = UIAlertAction(title: "Show Details", style: .default, handler: actionHandler)
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionDetails)
        
        present(alertController, animated: true, completion: nil)
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditMemo" {
            let memoController = segue.destination as? MemosViewController
            let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let selectedMemo = memos[selectedRow!] as? Memo
            memoController?.currentMemo = selectedMemo!
        }
    }
    

}
