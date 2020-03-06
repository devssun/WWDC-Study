//
//  ViewController.swift
//  CoreML_VisionExample
//
//  Created by 최혜선 on 2020/03/06.
//  Copyright © 2020 jamie. All rights reserved.
//

import UIKit
import Vision
import Photos

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var imamgeView: UIImageView!
    @IBOutlet fileprivate weak var resultLabel: UILabel!
    @IBOutlet fileprivate weak var startClassficationButton: UIButton!
    @IBOutlet fileprivate weak var openAlbumButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startClassficationButton.addTarget(self, action: #selector(touchedStartClassfication), for: .touchUpInside)
        openAlbumButton.addTarget(self, action: #selector(touchedOpenAlbumButton), for: .touchUpInside)
    }

    /// 앨범 열기 버튼 타겟 이벤트
    @objc private func touchedOpenAlbumButton() {
        let albumController = UIImagePickerController()
        albumController.sourceType = .photoLibrary
        albumController.delegate = self
        DispatchQueue.main.async {
            self.present(albumController, animated: true, completion: nil)
        }
    }
    
    /// 분류 시작 버튼 타겟 이벤트ㅡ
    @objc private func touchedStartClassfication() {
        startClassification()
    }
    
    /// 이미지 분류 실행
    private func startClassification() {
        resultLabel.text = "이미지 분류 중..."
        guard let classificationRequest = setupVisionWithCoreMLModel() else {
            resultLabel.text = "요청 오류"
            return
        }
        if let uiimage = imamgeView.image, let ciimage = CIImage(image: uiimage) {
            runVisionRequest(ciImage: ciimage, classificationRequest: classificationRequest)
        } else {
            resultLabel.text = "요청하신 이미지가 올바르지 않습니다."
        }
    }
    
    /// Run the Vision Request
    private func runVisionRequest(ciImage: CIImage, classificationRequest: VNCoreMLRequest) {
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                try handler.perform([classificationRequest])
            } catch {
                print("Failed to perform classification. \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.resultLabel.text = "이미지 분류에 실패하였습니다."
                }
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
            DispatchQueue.main.async {
                self.resultLabel.text = "이미지 분류에 실패하였습니다."
            }
            return nil
        }
    }
    
    /// Handle Image Classification Results
    private func processClassfications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                return
            }
            
            if let bestMatchValue = (results as? [VNClassificationObservation])?.first {
                print("결과 \(Int(bestMatchValue.confidence * 100))% 확률로 \(bestMatchValue.identifier)로 확인됩니다.")
                self.resultLabel.text = "\(Int(bestMatchValue.confidence * 100))% 확률로 \(bestMatchValue.identifier)로 확인됩니다."
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            self.resultLabel.text = "이미지 불러오기 오류"
            return
        }
        
        DispatchQueue.main.async {
            self.imamgeView.image = image
            picker.dismiss(animated: true, completion: {
                self.startClassification()
            })
        }
    }
}
