//
//  ViewController.swift
//  STTExample
//
//  Created by 최혜선 on 2020/02/23.
//  Copyright © 2020 jamie. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var recordingButton: UIButton!
    
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    print("허용")
                    self.recordingButton.isEnabled = true
                    self.recordingButton.setTitle("Start Recording", for: [])
                case .denied, .notDetermined, .restricted:
                    print("거부")
                    self.recordingButton.isEnabled = false
                    self.recordingButton.setTitle("unavailable Recording", for: [])
                @unknown default:
                    fatalError("권한 요청 실패")
                }
            }
        }
    }
    
    private func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormmat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormmat) { (buffer, time) in
            self.recognitionRequest?.append(buffer)
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // 장치 인식 지원
        if speechRecognizer.supportsOnDeviceRecognition {
            print("장치 인식이 지원됩니다")
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal: Bool = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                print("result \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.recordingButton.isEnabled = true
                self.recordingButton.setTitle("Start Recording", for: [])
            }
        })
        
        audioEngine.prepare()
        try audioEngine.start()
        
        textView.text = "Tell Something"
    }
    
    @IBAction private func touchedRecordingButton(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordingButton.isEnabled = false
            recordingButton.setTitle("Stopping", for: .normal)
        } else {
            do {
                recordingButton.isEnabled = true
                recordingButton.setTitle("Stop Recording", for: .normal)
                try startRecording()
            } catch {
                self.recordingButton.isEnabled = false
                self.recordingButton.setTitle("error", for: .normal)
            }
        }
    }
}

extension ViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.recordingButton.isEnabled = true
            self.recordingButton.setTitle("Start Recording", for: [])
        } else {
            self.recordingButton.isEnabled = false
            self.recordingButton.setTitle("unavailble", for: .disabled)
        }
    }
}
