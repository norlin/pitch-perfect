//
//  PlayViewController.swift
//  Pitch Perfect
//
//  Created by norlin on 14/05/15.
//  Copyright (c) 2015 norlin. All rights reserved.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController, AVAudioPlayerDelegate {
	@IBOutlet weak var stopButton: UIButton!
	var audioPlayer: AVAudioPlayer!
	var receivedAudio: RecordedAudio!
	var audioEngine: AVAudioEngine!
	var audioFile: AVAudioFile!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		audioEngine = AVAudioEngine()
		audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePath, error: nil)
		audioFile = AVAudioFile(forReading: receivedAudio.filePath, error: nil)
		audioPlayer.delegate = self
	}
	
	override func viewWillAppear(animated: Bool) {
		resetPlayer()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func slowPlay(sender: UIButton) {
		playAtRate(0.5)
	}
	
	@IBAction func fastPlay(sender: UIButton) {
		playAtRate(2)
	}
	
	@IBAction func chipmunkPlay(sender: UIButton) {
		playWithPitch(1000)
	}
	
	@IBAction func vaderPlay(sender: UIButton) {
		playWithPitch(-1000)
	}
	
	@IBAction func reverbPlay(sender: UIButton) {
		playWithReverb(AVAudioUnitReverbPreset.Cathedral, andWet: 60)
	}
	
	@IBAction func echoPlay(sender: UIButton) {
		playWithEcho()
	}
	
	@IBAction func stopPlay(sender: UIButton) {
		resetPlayer()
	}

	// return Bool to check if we can play
	func resetPlayer() -> Bool {
		stopButton.hidden = true
		if (audioPlayer != nil) {
			audioPlayer.stop()
			audioPlayer.enableRate = true
			audioPlayer.currentTime = 0
			audioPlayer.rate = 1
		}
		if (audioEngine != nil) {
			audioEngine.reset()
			audioEngine.stop()
			audioEngine.disconnectNodeInput(audioEngine.outputNode)
		}
		return audioPlayer != nil || audioEngine != nil
	}
	
	func resetPlayerVoid() {
		resetPlayer()
	}
	
	func playAtRate(rate: Float) {
		// play audio with specified Rate
		if (resetPlayer()) {
			audioPlayer.rate = rate
			audioPlayer.play()
			stopButton.hidden = false
		}
	}
	
	func playWithPitch(pitch: Float) {
		// play audio with specified Pitch
		var timePitch = AVAudioUnitTimePitch()
		timePitch.pitch = pitch
		
		playWithEffect(timePitch)
	}
	
	func playWithReverb(preset: AVAudioUnitReverbPreset, andWet wet: Float) {
		// play audio with Reverb effect
		var reverbUnit = AVAudioUnitReverb()
		reverbUnit.loadFactoryPreset(preset)
		reverbUnit.wetDryMix = wet
		
		playWithEffect(reverbUnit)
	}
	
	func playWithEcho() {
		// play audio with Echo effect
		var echoUnit = AVAudioUnitDelay()
		echoUnit.delayTime = 0.1
		
		playWithEffect(echoUnit)
	}
	
	func playWithEffect(effect: AVAudioNode) {
		// first make player reset to stop playing sounds/effects/etc
		if (resetPlayer()) {
			var effectPlayer = AVAudioPlayerNode()
			audioEngine.attachNode(effectPlayer)
			audioEngine.attachNode(effect)
			
			audioEngine.connect(effectPlayer, to: effect, format: nil)
			audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)

			// here is a bug with completionHandler – it's called before audioEngine really stops playing. So, we can't call engine.stop on this handler...
			// effectPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: resetPlayerVoid)
			effectPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
			
			if (audioEngine.startAndReturnError(nil)) {
				effectPlayer.play()
				stopButton.hidden = false
			}
		}
	}
	
	func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
		resetPlayer()
	}
	
}
