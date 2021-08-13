//
//  ViewController.swift
//  Metronome
//
//  Created by Carston Gowans on 9/8/21.
//

import UIKit
import SQLite3
import AVFoundation

struct timingInformation {                  // Struct for Bpm / time signature for the Metronome
    var currBpm: Int?
    var currNumberOfBeats: Int?
    var currTypeOfBeat: Int?
    
    init(currBpm: Int?, currNumberOfBeats: Int?, currTypeOfBeat: Int?) {
        self.currBpm = currBpm
        self.currNumberOfBeats = currNumberOfBeats
        self.currTypeOfBeat = currTypeOfBeat
    }
}
var currTime = timingInformation(currBpm: 60, currNumberOfBeats: 4, currTypeOfBeat: 2)  // Variable for what the Met is set to
var metronomeStatus = false // Status of if the met is running

let lowPitchUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "lowPitch.wav", ofType: nil)!) // Url for low pitch sound
let highPitchUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "highPitch.wav", ofType: nil)!)   // Url for high pitch sound
var lowPitchSound: AVAudioPlayer!   // Audio player for low pitch
var highPitchSound: AVAudioPlayer!  // Audio player for high pitch

class ViewController: UIViewController {
    @IBOutlet weak var numberOfBeats: UILabel!              // Variable initalization
    @IBOutlet weak var numberOfBeatsStepper: UIStepper!
    @IBOutlet weak var typeOfBeat: UILabel!
    @IBOutlet weak var typeOfBeatStepper: UIStepper!
    @IBOutlet weak var tempo: UILabel! //Yeha
    @IBOutlet weak var tempoStepper: UIStepper!
    @IBOutlet weak var metronomeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var downbeatSwitch: UISwitch!
    
    @IBAction func resetButtonAction(_ sender: Any) {       // Stops and resets the metronome to basic settings
        stopMetronome()
        resetMetronome()
    }
    var timerCount = 1          // Timer for the down beat.
    var downbeatStatus = true   // Status for if the metronome will play the high-pitch sound on the down beat
    var metTimer: Timer?        // Timer for the met
    
    @IBAction func buttonPressed(_ sender: Any) {
        if metronomeStatus == false {   // Setups and starts metronome
            metronomeSetup()
            metronomeButton.setTitle("Stop", for: UIControl.State.normal)
            metronomeButton.setTitleColor(UIColor.systemRed, for: UIControl.State.normal)
            metronomeStatus = true
        } else {
            stopMetronome()
        }
    }
    func stopMetronome() {          // Stops metronome
        metTimer?.invalidate()
        timerCount = 1
        metronomeButton.setTitle("Play", for: UIControl.State.normal)
        metronomeButton.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        metronomeStatus = false
    }
    func resetMetronome() {         // Resets metronome to basic values. 60bpm, 4/4 time
        tempo.text = " \(60)"
        tempoStepper.value = Double(60)
        currTime.currBpm = 60
        
        numberOfBeats.text = "\(4)"
        numberOfBeatsStepper.value = Double(4)
        currTime.currNumberOfBeats = 4
        
        typeOfBeat.text = "4"
        typeOfBeatStepper.value = 2
        currTime.currTypeOfBeat = 2
        downbeatSwitch.isOn = true
    }
    
    func metronomeSetup() {     // Setup for Metronome
        let timeInterval = Double(1.00 / (Double(currTime.currBpm ?? Int(60.00)) / 60.00))
        metTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(startMetronome), userInfo: nil, repeats: true) // Instantiate the NSTimer (which is now Timer)
         do {   // Instantiate both Sound players
            lowPitchSound = try AVAudioPlayer(contentsOf: lowPitchUrl)
            highPitchSound = try AVAudioPlayer(contentsOf: highPitchUrl)
        } catch {
            print("Audio could not load")
        }
        metTimer!.fire()    // Start the timer
    }
    @objc func startMetronome() {   // Starts the met
        if(downbeatSwitch.isOn) {   // plays the high pitch sound for the downbeat if true
            if timerCount == 1 {
                highPitchSound.play()
                timerCount += 1     // Add one to count
            } else if currTime.currNumberOfBeats == 1 { // Plays high pitch on beat if the time signature is every 1 / (any number)
                highPitchSound.play()
                timerCount = 1
            } else {
                lowPitchSound.play()    // plays down beats until the counter is > the number of beats in the time signature
                timerCount += 1
                if timerCount > currTime.currNumberOfBeats ?? 4 {
                    timerCount = 1
                }
            }
        } else {
            lowPitchSound.play()                        // Plays low sound only if the downbeatSwitch is turned off
        }
    }
    
    let beats = [1,2,4,8,16]                            // [whole, half, quarter, eighth, 16th] - used for parsing stepper
    
    func updateBpm(newBpm: Int) {                       // Assigns new Bpm to currTime
        currTime.currBpm = newBpm
    }
    func updateNumberOfBeats(newNumberOfBeats: Int) {   // Assigns new number of beats to currTime
        currTime.currNumberOfBeats = newNumberOfBeats
    }
    func updateTypeOfBeat(newBeatType: Int) {           // Assigns new type of beat to currTime
        currTime.currTypeOfBeat = newBeatType
    }
    
    @IBAction func numberStepperValueChange(_ sender: UIStepper) {      // Sets top portion of time signature. The values can be any postivie, non-zero int.
        numberOfBeats.text = Int(sender.value).description
        numberOfBeatsStepper.value = (sender.value)
        updateNumberOfBeats(newNumberOfBeats: Int(sender.value))
    }
    
    @IBAction func beatTypeStepperValueChange(_ sender: UIStepper) {    // Correctly sets bottom portion of time signature. The values can only be 1,4,8,16, or 32, but 32 is not incoporated.
        //let currentValue = Int(typeOfBeat.text!)
        let sentValue = Int(sender.value)
        typeOfBeat.text = "\(beats[sentValue])"
        typeOfBeatStepper.value = Double(sentValue)
        updateTypeOfBeat(newBeatType: Int(sender.value))                // This sends the raw number that hasn't been parsed
    }
    
    @IBAction func tempoStepperValueChange(_ sender: UIStepper) {       // Updates Stepper value and text
        // print("The value was \(String(describing: tempo.text))")
        tempo.text = Int(sender.value).description
        updateBpm(newBpm: Int(sender.value))
        tempoStepper.value = Double(sender.value)
        // print("The value after the input was \(String(describing: tempo.text))")
    }
    
    func SetTime(_ timingInformation: timingInformation) {             // calls the Update Function to set currTime Values to the View
        updateMetronome()
    }
    
    func updateMetronome() {                                           // Updates the View Text and Values to what currTime has
        tempo.text = " \(currTime.currBpm ?? 60)"
        tempoStepper.value = Double(currTime.currBpm ?? 60)
        
        numberOfBeats.text = "\(currTime.currNumberOfBeats ?? 4)"
        numberOfBeatsStepper.value = Double(currTime.currNumberOfBeats ?? 4)
        
        switch currTime.currTypeOfBeat {                                // Parses the raw value to the accurate representation
        case 0:
            typeOfBeat.text = "1"
            typeOfBeatStepper.value = 0
        case 1:
            typeOfBeat.text = "2"
            typeOfBeatStepper.value = 1
        case 2:
            typeOfBeat.text = "4"
            typeOfBeatStepper.value = 2
        case 3:
            typeOfBeat.text = "8"
            typeOfBeatStepper.value = 3
        case 4:
            typeOfBeat.text = "16"
            typeOfBeatStepper.value = 4
        default:
            typeOfBeat.text = "4"
            typeOfBeatStepper.value = 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMetronome()                           // Updates the View text after returning from the other tabbed view
    }
}

