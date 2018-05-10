//
//  BoneViewController.swift
//  Medical Hub
//
//  Created by Walter Bassage on 27/03/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO

class BoneViewController: UIViewController {
    @IBOutlet weak var imgClassification: UIImageView!           // For displaying the image and classification view
    @IBOutlet weak var cameraButton: UIToolbar!                  // For selecting from the users photo libary or user camrea
    @IBOutlet weak var injuryClassificationLabel: UILabel!       // For displaying top 3 and the pecentage of classification
    @IBOutlet weak var boneClassificationLabel: UILabel!         // For displaying top 3 and the pecentage of classification
    
    // Injury Classification Request
    lazy var injuryClassificationRequest: VNCoreMLRequest = {
        do {
            let injuryModel = try VNCoreMLModel(for: BoneInjuries_CoreML().model)
            let injuryrequest = VNCoreMLRequest(model: injuryModel, completionHandler: { [weak self] request, error in
                self?.processInjuryClassifications(for: request, error: error)
            })
            injuryrequest.imageCropAndScaleOption = .centerCrop
            return injuryrequest
        } catch {
            fatalError("Unable to load BoneInjuries_CoreML model: \(error)")
        }
    }()
    
    // Update Injury Classifications
    func updateInjuryClassifications(for image: UIImage) {
        injuryClassificationLabel.text = "Proccesing Request..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.injuryClassificationRequest])
            } catch {
                print("Unable to complete classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    // Process Injury Classifications
    func processInjuryClassifications(for injuryrequest: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let injuryResults = injuryrequest.results else {
                self.injuryClassificationLabel.text = "Can't classify image.\n\(error!.localizedDescription)"
                return
            }

            let classifications = injuryResults as! [VNClassificationObservation]
            if classifications.isEmpty {
                self.injuryClassificationLabel.text = "Nothing Identified."
            } else {
                let topClassifications = classifications.prefix(3)
                let descriptions = topClassifications.map { classification in
                    return String(format: "  %.2f %@", classification.confidence, classification.identifier)
                }
                self.injuryClassificationLabel.text = "Injury Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
    // Bone Classification Request
    lazy var boneClassificationRequest: VNCoreMLRequest = {
        do {
            let boneModel = try VNCoreMLModel(for: Handbones_CoreML().model)
            let request = VNCoreMLRequest(model: boneModel, completionHandler: { [weak self] request, error in
                self?.processBoneClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Unable to load Handbones_CoreML model: \(error)")
        }
    }()
    
    // Update Bone Classifications
    func updateBoneClassifications(for image: UIImage) {
        injuryClassificationLabel.text = "Proccesing Request..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
//        self.boneClassificationLabel.text = "I am Here 2"
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.boneClassificationRequest])
            } catch {
                print("Unable to complete classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    
    // Process Bone Classifications
    func processBoneClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.boneClassificationLabel.text = "Can't classify image.\n\(error!.localizedDescription)"
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            if classifications.isEmpty {
                self.boneClassificationLabel.text = "Nothing Identified."
            } else {
                // Ranks the top three as the model doesnt work as well as expected.
                let topClassifications = classifications.prefix(3)
                let descriptions = topClassifications.map { classification in
                    return String(format: "  %.2f %@", classification.confidence, classification.identifier)
                }
                self.boneClassificationLabel.text = "Bone Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
    
    // For Use of Camera
    @IBAction func takePicture(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Fixes the Issue I was having with the user not being able to access images due to the main device being an iPad
        if let popoverController = photoSourcePicker.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    // For making screen portrat
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        
    }
    @objc func canRotate() -> Void {}

}

extension BoneViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgClassification.image = image
        updateInjuryClassifications(for: image)
        updateBoneClassifications(for: image)
    }
}
