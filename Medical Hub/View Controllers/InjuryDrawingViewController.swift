//
//  InjuryDrawingViewController.swift
//  Medical Hub
//
//  Created by Walter Bassage on 28/03/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit

class InjuryDrawingViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var imageSavedLabel: UILabel!
    
    // variables
    var lastPoint = CGPoint.zero
    var swiped = false
    var red:CGFloat = 0.0
    var green:CGFloat = 0.0
    var blue:CGFloat = 255.0
    var isColouring = true
    var lineSize:CGFloat = 7.0
    var alphaValue:CGFloat = 0.5
    var switchTool:UIImageView!
    var handBoneImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the dot as paint Current tool (switchTool)
        switchTool = UIImageView()
        switchTool.frame = CGRect(x: self.view.bounds.size.width, y: self.view.bounds.size.height, width: 20, height: 20)
        switchTool.image = #imageLiteral(resourceName: "Paint Brush")
        self.view.addSubview(switchTool)
        
    }
    
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    // Function for the drawing of lines
    func drawLines(fromPoint:CGPoint, toPoint:CGPoint) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        switchTool.center = toPoint
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(lineSize)
        context?.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: alphaValue).cgColor)
        context?.strokePath()
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageSavedLabel.isHidden = true
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    
    // Resets the image view back to the Hand bone diagram
    @IBAction func reset(_ sender: Any) {
        self.imageView.image = #imageLiteral(resourceName: "Hand diagram")
    }
    
    /* Eraser button has been selected and sets
     switchtool to Eraser image and sets colours to white */
    @IBAction func eraser(_ sender: Any) {
        if (isColouring) {
            (red,green,blue) = (1,1,1)
            switchTool.image = #imageLiteral(resourceName: "Eraser")
            eraserButton.setImage(#imageLiteral(resourceName: "Paint Brush"), for: .normal)
            
        }else {
            /* Drawing button has been selected and sets
             switchtool to Dot image and sets colours to defult Tenderness */
            (red,green,blue) = (0,0,255)
            switchTool.image = #imageLiteral(resourceName: "Paint Brush")
            eraserButton.setImage(#imageLiteral(resourceName: "Eraser"), for: .normal)
        }
        
        isColouring = !isColouring
    }

    @IBOutlet weak var save: UIButton!
    
    // Function for saving the users image
    @IBAction func save(_ sender: Any) {
        if let image = self.imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            imageSavedLabel.isHidden = false
        }
    }
    
    // Action used for picking injury type using tages as Identification between buttons
    @IBAction func ColourPicked(_ sender: AnyObject) {
        if sender.tag == 0 {
            // For Tenderness
            (red,green,blue) = (0,0,255)
        }else if sender.tag == 1{
            // For Numbness
            (red,green,blue) = (0,255,0)
        }else if sender.tag == 2{
            // For Discoloration
            (red,green,blue) = (255,255,0)
        }else if sender.tag == 3{
            // For DRM
            (red,green,blue) = (128,0,128)
        }else if sender.tag == 4{
            // For Deformity
            (red,green,blue) = (255,0,0)
        }
    }
    
    // For making screen portrat and not landscape
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        
    }
    // Allows for rotation of to portrait but courses errors still and shows landscape
    @objc func canRotate() -> Void {}
}
