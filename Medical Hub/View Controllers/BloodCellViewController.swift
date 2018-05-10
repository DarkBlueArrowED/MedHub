//
//  BloodCellViewController.swift
//  Medical Hub
//
//  Created by Walter Bassage on 24/03/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit
// Allow me to use the Core ML model Blood_Cells
import CoreML
import Vision
import ImageIO

class BloodCellViewController: UIViewController {
    
    // UI IBOutlets
    @IBOutlet weak var imgClassificationImage: UIImageView!     // For displaying the image and classification view
    @IBOutlet weak var cameraButton: UIBarButtonItem!           // For selecting from the users photo libary or user camrea
    @IBOutlet weak var classificationLabel: UILabel!            // For displaying the pecentage of classification and the classification label
    @IBOutlet weak var bloodCellName: UILabel!                  // For displaying the Classified Blood Cells name
    @IBOutlet weak var bloodCellInfo: UITextView!               // For displaying the infromation about the classifyed Blood Cell
    

    // Setup for Model refraces
    lazy var bloodClassificationRequest: VNCoreMLRequest = {
        do {
            // Looking to see if model is availble
            let model = try VNCoreMLModel(for: Blood_Cells().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processBloodCellClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            // If model is not found or conncetion has and error
            fatalError("Unable to load Blood_Cells model: \(error)")
        }
    }()
    
    // Prefroms the classification request
    func updateBloodCellClassifications(for image: UIImage) {
        classificationLabel.text = "Proccesing Request..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.bloodClassificationRequest])
            } catch {
                print("Unable to complete classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func processBloodCellClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Can't classify image.\n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing Identified."
            } else {
                // Classifications shown by ranked.
                let topClassifications = classifications.prefix(1)
                let bloodCellName = topClassifications.map { classification in
                    // Formats the classification name for displaying cell info later on
                    return String(format: classification.identifier)
                }
                let descriptions = topClassifications.map { classification in
                    return String(format: "%.2f %@", classification.confidence, classification.identifier)
                }
                self.bloodCellName.text = bloodCellName.joined(separator: "\n")
                self.classificationLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
                if self.bloodCellName.text == "neutrophil"{
                    self.bloodCellInfo.text = "Neutrophils (also known as neutrocytes) are the most abundant type of granulocytes and the most abundant (40% to 70%) type of white blood cells in most mammals. They form an essential part of the innate immune system."
                }
                else if self.bloodCellName.text == "eosinophil"{
                    self.bloodCellInfo.text = "Eosinophils sometimes called eosinophiles or, less commonly, acidophils, are a variety of white blood cells and one of the immune system components responsible for combating multicellular parasites and certain infections in vertebrates."
                }
                else if self.bloodCellName.text == "lymphocyte"{
                    self.bloodCellInfo.text = "A lymphocyte is one of the subtypes of white blood cell in a vertebrate's immune system. Lymphocytosis include natural killer cells (which function in cell-mediated, cytotoxic innate immunity), T cells (for cell-mediated, cytotoxic adaptive immunity), and B cells (for humoral, antibody-driven adaptive immunity)."
                }
                else if self.bloodCellName.text == "monocyte"{
                    self.bloodCellInfo.text = "Monocytes are a type of leukocyte, or white blood cell. They are the largest type of leukocyte and can differentiate into macrophages and myeloid lineage dendritic cells. As a part of the vertebrate innate immune system monocytes also influence the process of adaptive immunity."
                }
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
    
    // For making screen landscape and not portrat
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
        }
        
    }
}

extension BloodCellViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgClassificationImage.image = image
        updateBloodCellClassifications(for: image)
    }
}

