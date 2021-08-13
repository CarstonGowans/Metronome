//
//  AddViewController.swift
//  Metronome
//
//  Created by Carston Gowans on 9/8/21.
//

import UIKit

protocol AddTimingInformation {
    func addTempo(_ timingInformation: timingInformation)
}

class AddViewController: UIViewController {
    @IBOutlet weak var addBpm: UITextField!    
    @IBOutlet weak var addTimeSignature: UITextView!
    
    var delegate: TableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add New Tempo"
        
        let save = UIBarButtonItem(barButtonSystemItem: .save,
        target: self,
                    action: #selector(saveTempo))
                self.navigationItem.rightBarButtonItem = save
    }
    
    @objc func saveTempo() {                                                // Set up and call the function specified by the protocol
        let Bpm = addBpm.text ?? " "
        let components = addTimeSignature.text.components(separatedBy: "/") // String Delimiter by the character '/'
        let sentTimingInformation = timingInformation(currBpm: Int(Bpm) , currNumberOfBeats: Int(components[0]), currTypeOfBeat: Int(components[1]))
        delegate.addTempo(sentTimingInformation)
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
