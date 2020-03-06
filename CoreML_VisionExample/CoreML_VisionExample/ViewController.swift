//
//  ViewController.swift
//  CoreML_VisionExample
//
//  Created by 최혜선 on 2020/03/06.
//  Copyright © 2020 jamie. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var imamgeView: UIImageView!
    @IBOutlet fileprivate weak var resultLabel: UILabel!
    @IBOutlet fileprivate weak var startClassfication: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startClassfication.addTarget(self, action: #selector(touchedStartClassfication), for: .touchUpInside)
    }

    @objc private func touchedStartClassfication() {
        startClassification()
    }
    
    /// 이미지 분류 실행
    private func startClassification() {
        resultLabel.text = "이미지 분류 중..."
        let classificationRequest = setupVisionWithCoreMLModel()
        let image = imamgeView.image
        let ciimage = CIImage(image: image!)
        runVisionRequest(ciImage: ciimage!, classificationRequest: classificationRequest!)
    }
    
    /// Run the Vision Request
    private func runVisionRequest(ciImage: CIImage, classificationRequest: VNCoreMLRequest) {
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                try handler.perform([classificationRequest])
            } catch {
                print("Failed to perfoem classification. \(error.localizedDescription)")
            }
        }
    }
    
    /// Set Up Vision with a Core ML Model
    private func setupVisionWithCoreMLModel() -> VNCoreMLRequest? {
        do {
            let model = try VNCoreMLModel(for: PetClassifier_1().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { request, error in
                self.processClassfications(for: request, error: error)
            })
            return request
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// Handle Image Classification Results
    private func processClassfications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                return
            }
            
            if let classifications = (results as? [VNClassificationObservation])?.first {
                self.resultLabel.text = "\(Int(classifications.confidence * 100))% 확률로 \(classifications.identifier)로 확인됩니다."
            }
        }
    }
}

