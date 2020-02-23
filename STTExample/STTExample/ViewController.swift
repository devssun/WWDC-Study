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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    print("허용")
                case .denied, .notDetermined, .restricted:
                    print("거부")
                @unknown default:
                    fatalError("권한 요청 실패")
                }
            }
        }
    }
}

