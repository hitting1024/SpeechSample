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
