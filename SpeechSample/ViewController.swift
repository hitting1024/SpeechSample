//
//  ViewController.swift
//  SpeechSample
//
//  Created by hitting on 2018/06/05.
//  Copyright © 2018年 Hit Apps. All rights reserved.
//

import UIKit

import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private let audioEngine = AVAudioEngine()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization({ authStatus in
            // for main thread
            OperationQueue.main.addOperation({ [weak self] in
                guard let `self` = self else { return }
                switch authStatus {
                case .authorized:
                    self.button.isEnabled = true
                case .denied:
                    self.button.isEnabled = false
                    self.button.setTitle("Access Denied", for: .disabled)
                case .restricted:
                    self.button.isEnabled = false
                    self.button.setTitle("Not supported", for: .disabled)
                case .notDetermined:
                    self.button.isEnabled = false
                    self.button.setTitle("Not Allowed", for: .disabled)
                }
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.speechRecognizer.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func startRecording() throws {
        self.refreshTask()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = self.audioEngine.inputNode
        guard let recognitionRequest = self.recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        recognitionRequest.shouldReportPartialResults = true
        
        self.recognitionTask = self.speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] result, error in
            guard let `self` = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.label.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.button.isEnabled = true
                self.button.setTitle("Start Speech", for: [])
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        })
        
        try startAudioEngine()
    }
    
    private func refreshTask() {
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }
    
    private func startAudioEngine() throws {
        self.audioEngine.prepare()
        try self.audioEngine.start()
        label.text = "Please Speech..."
    }
    
}

extension ViewController {
    
    @IBAction func startSpeech(_ sender: UIButton) {
        if self.audioEngine.isRunning {
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.button.isEnabled = false
            self.button.setTitle("Stopping...", for: .disabled)
        } else {
            try! self.startRecording()
            self.button.setTitle("Stop Speech", for: [])
        }
    }
    
}

extension ViewController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.button.isEnabled = true
            self.button.setTitle("Start Speech", for: [])
        } else {
            self.button.isEnabled = false
            self.button.setTitle("Stop Speech", for: .disabled)
        }
    }
    
}
