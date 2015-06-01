//
//  RecordViewController.swift
//  Pitch Perfect
//
//  Created by norlin on 13/05/15.
//  Copyright (c) 2015 norlin. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
	
	@IBOutlet weak var hintLabel: UILabel!
	@IBOutlet weak var stateLabel: UILabel!
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var stopButton: UIButton!
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var hintStopLabel: UILabel!
	
	var audioRecorder:AVAudioRecorder!
	var recordedAudio:RecordedAudio!
	var isRecording = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		clearStatus()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func recordAudio(sender: UIButton) {
		startRecord()
	}
	
	@IBAction func stopButtonClick(sender: UIButton) {
		stopRecord()
	}
	
	@IBAction func pauseButtonClick(sender: UIButton) {
		pauseRecord()
	}
	
	func clearStatus() {
		// reset all elements to initial state
		stateLabel.text = "recording"
		hintLabel.hidden = false
		stateLabel.hidden = true
		stopButton.hidden = true
		hintStopLabel.hidden = true
		recordButton.hidden = false
		pauseButton.hidden = true
	}
	
	func stopRecord() {
		if (audioRecorder != nil) {
			audioRecorder.stop()
			var audioSession = AVAudioSession.sharedInstance()
			audioSession.setActive(false, error: nil)
		}
	}
	
	func pauseRecord() {
		if (audioRecorder != nil && audioRecorder.recording) {
			audioRecorder.pause()
			recordButton.hidden = false
			pauseButton.hidden = true
			stateLabel.text = "Tap to continue"
		}
	}
	
	func startRecord() {
		if (audioRecorder == nil || !audioRecorder.recording) {
			if (!isRecording) {
				// if no recording – init new one
				isRecording = true
				let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
				
				let currentDateTime = NSDate()
				let formatter = NSDateFormatter()
				formatter.dateFormat = "ddMMyyyy-HHmmss"
				let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
				let pathArray = [dirPath, recordingName]
				let filePath = NSURL.fileURLWithPathComponents(pathArray)
				println(filePath)
				
				var session = AVAudioSession.sharedInstance()
				session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
				
				audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
				audioRecorder.delegate = self
				audioRecorder.meteringEnabled = true
				audioRecorder.prepareToRecord()
			}
			// ... otherwise just continue recording
			audioRecorder.record()
			
			// set element states
			clearStatus()
			hintLabel.hidden = true
			stateLabel.hidden = false
			stopButton.hidden = false
			hintStopLabel.hidden = false
			recordButton.hidden = true
			pauseButton.hidden = false
		}
	}
	
	func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
		if (flag) {
			recordedAudio = RecordedAudio(filePath: recorder.url, title: recorder.url.lastPathComponent!)
			
			self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
		} else {
			println("Something happened, audio is not recorded!")
		}
		isRecording = false
		clearStatus()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "stopRecording") {
			// send recorded audio to the playViewController
			let playViewController = segue.destinationViewController as! PlayViewController
			let data = sender as! RecordedAudio
			playViewController.receivedAudio = data
		}
	}
}

