//
//  EditViewController.swift
//  Metronome
//
//  Created by Carston Gowans on 9/8/21.
//

import UIKit

protocol EditTimingInformation {
func EditTempo(_ timingInformation: timingInformation)
}

class EditViewController: UIViewController {
    var delegate: TableViewController!
    var passedTempo: timingInformation?
    @IBOutlet weak var editBpm: UITextField!
    @IBOutlet weak var editTimeSignature: UITextView!
    
    var editingTimeInformation = timingInformation(currBpm: 60, currNumberOfBeats: 4, currTypeOfBeat: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Editing Timing Information"
        editBpm.text = "\((passedTempo?.currBpm) ?? 60)"
        editTimeSignature.text = "\((passedTempo?.currNumberOfBeats) ?? 4)/\((passedTempo?.currTypeOfBeat) ?? 4)"
        let save = UIBarButtonItem(barButtonSystemItem: .save,
        target: self,
                    action: #selector(saveTimeSignature))
                self.navigationItem.rightBarButtonItem = save
    }
    
    @objc func saveTimeSignature() {
        var editedTimeInformation = timingInformation(currBpm: 60, currNumberOfBeats: 4, currTypeOfBeat: 4)
        let components = editTimeSignature.text.components(separatedBy: "/") // String parse by the delimiter '/'
        editedTimeInformation.currBpm = Int(editBpm.text!)
        editedTimeInformation.currNumberOfBeats = Int(components[0])
        editedTimeInformation.currTypeOfBeat = Int(components[1])
        delegate.EditTempo(editedTimeInformation)
        self.navigationController?.popViewController(animated: true)
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
