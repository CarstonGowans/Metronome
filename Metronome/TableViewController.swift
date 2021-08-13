//
//  TableViewController.swift
//  Metronome
//
//  Created by Carston Gowans on 10/8/21.
//

import UIKit
import SQLite3

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddTimingInformation, EditTimingInformation {
    
    @IBOutlet weak var tableView: UITableView!  // Table View Outlet
    
    var savedTempos: [timingInformation?] = []  // Array of Saved Tempos
    var tempoBeingEdited: Int!                  // Int of table cell being edited
    var db: OpaquePointer?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTempos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {    // Instantiates table View with required Information
        let cell = tableView.dequeueReusableCell(withIdentifier:
        "cell", for: indexPath)
        let cellBpm = "Tempo: \((savedTempos[indexPath.row]?.currBpm) ?? 60)"
        let cellTimeSignature = "\((savedTempos[indexPath.row]?.currNumberOfBeats) ?? 4) / \(savedTempos[indexPath.row]?.currTypeOfBeat ?? 4)"
        cell.textLabel?.text = cellBpm
        cell.detailTextLabel?.text = cellTimeSignature
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .destructive, title: "Delete") { (action:UIContextualAction, sourceView:UIView, actionPerformed:(Bool) -> Void) in
            tableView.beginUpdates()
            self.savedTempos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            actionPerformed(true)
        }   // Creates Delete Action
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action:UIContextualAction, sourceView:UIView, actionPerformed:(Bool) -> Void) in
            tableView.beginUpdates()
            self.tempoBeingEdited = indexPath.row
            print("The value of the row selected is \(indexPath.row)")
            self.performSegue(withIdentifier: "editSegue", sender: self)
            tableView.endUpdates()
            
            actionPerformed(true)
        }   // Creates Edit Action
        editAction.backgroundColor = UIColor.blue
            
        return UISwipeActionsConfiguration(actions: [editAction, completeAction])
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // Action to take information from selected Cell back to the first Screen
        currTime.currBpm = savedTempos[indexPath.row]?.currBpm
        currTime.currNumberOfBeats = savedTempos[indexPath.row]?.currNumberOfBeats
        currTime.currTypeOfBeat = savedTempos[indexPath.row]?.currTypeOfBeat
        print(savedTempos[indexPath.row]?.currNumberOfBeats ?? 4)
        switch savedTempos[indexPath.row]?.currTypeOfBeat {                     // Parses the value of the text to usuable value
        case 1:
            currTime.currTypeOfBeat = 0
        case 2:
            currTime.currTypeOfBeat = 1
        case 4:
            currTime.currTypeOfBeat = 2
        case 8:
            currTime.currTypeOfBeat = 3
        case 16:
            currTime.currTypeOfBeat = 4
        default:
            currTime.currTypeOfBeat = 2
        }
        tabTimerPrep()                                                          // Helper Function to transition back to the original Tab
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // Segues for adding and editing tempos
        if segue.identifier == "addSegue" {
            let view = segue.destination as! AddViewController
            view.delegate = self
        } else if segue.identifier == "editSegue" {
        let view = segue.destination as! EditViewController
            view.delegate = self
            view.passedTempo = savedTempos[tempoBeingEdited]
            }
        }
    
    func tabTimerPrep() {   // Helper function to jump to original tab
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {timer in self.tabBarController!.selectedIndex = 0}) // Timer used to delay transition
        timer.fire()
    }
    
    func addTempo(_ timingInformation: timingInformation) {      // Protocol to add time to array
        savedTempos.append(timingInformation)
        tableView.reloadData()
    }
    
    func EditTempo(_ timingInformation: timingInformation) {    // Protocol to edit time to array
        savedTempos[tempoBeingEdited]?.currBpm = timingInformation.currBpm
        savedTempos[tempoBeingEdited]?.currNumberOfBeats = timingInformation.currNumberOfBeats
        savedTempos[tempoBeingEdited]?.currTypeOfBeat = timingInformation.currTypeOfBeat
        tableView.reloadData()
    }
    
    func readValues() {         // SqLite database function to read values from database back into array
        savedTempos.removeAll()
        let queryString = "Select * FROM savedTempos"
        var stmt:OpaquePointer?
                                // Prepare the database
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                   let errmsg = String(cString: sqlite3_errmsg(db)!)
                   print("error preparing insert: \(errmsg)")
                   return
               }
                                // Tranverse through the Table
               while(sqlite3_step(stmt) == SQLITE_ROW){
                   let bpm = String(cString: sqlite3_column_text(stmt, 1))
                let dbTimeSignature = String(cString: sqlite3_column_text(stmt, 2))
                let components = dbTimeSignature.components(separatedBy: "/")
                savedTempos.append(timingInformation(currBpm: Int(bpm), currNumberOfBeats: Int(components[0]), currTypeOfBeat: Int(components[1])))
               }
               self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
                                // The database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("TimingInformation.sqlite")
 
                                // Opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
                                // Creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS savedTempos (id INTEGER PRIMARY KEY AUTOINCREMENT, bpm VARCHAR, dbTimeSignature VARCHAR)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        readValues()            // Read function call
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(saveToDatabase(_:)),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        super.viewDidLoad()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    @objc func saveToDatabase(_ notification:Notification){
                                // The database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("TimingInformation.sqlite")
 
                                // Opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
                                // Delete * From savedTempos query
        let deleteString = "DELETE FROM savedTempos"
        var deleteStmt: OpaquePointer?
          if sqlite3_prepare_v2(db, deleteString, -1, &deleteStmt, nil) ==
              SQLITE_OK {
            if sqlite3_step(deleteStmt) == SQLITE_DONE {
              print("\nSuccessfully deleted row.")
            } else {
              print("\nCould not delete row.")
            }
          } else {
            print("\nDELETE statement could not be prepared")
          }
          sqlite3_finalize(deleteStmt)
        
                                // Prepare the database
        for timingInformation in savedTempos {
            var stmt: OpaquePointer?
            let queryString = "INSERT INTO savedTempos (bpm, dbTimeSignature) VALUES (?,?)"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                       let errmsg = String(cString: sqlite3_errmsg(db)!)
                       print("error preparing insert: \(errmsg)")
                       return
                   }
           
            if sqlite3_bind_text(stmt, 1, (String((timingInformation?.currBpm)!) as NSString).utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding short description: \(errmsg)")
                return
            }
            if sqlite3_bind_text(stmt, 2, ("\(timingInformation?.currNumberOfBeats ?? 4)/\(timingInformation?.currTypeOfBeat ?? 4)" as NSString).utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding long description: \(errmsg)")
                return
            }
     
            if sqlite3_step(stmt) != SQLITE_DONE {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure inserting item: \(errmsg)")
                        return
                    }
        }
        sqlite3_close(db)
    }
}
