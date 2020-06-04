//
//  PostImageViewController.swift
//  CoreImageViewController
//
//  Created by Ezra Black on 6/1/20.
//  Copyright © 2020 Casanova Studios. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PostImageViewController: UIViewController {
    
    //MARK: Properties -
    
    private var originalImage: UIImage? {
        didSet {
            // 414 * 3 = 1,242 pixels (portrait on iPhone 11 Pro Max)
            guard let originalImage = originalImage else {
                scaledImage = nil // clear out image if set to nil
                return
            }
            
            var scaledSize = photoImageView.bounds.size
            let scale = UIScreen.main.scale
            print("original image size: \(originalImage.size)")
            print("size: \(scaledSize)")
            print("scale: \(scale)")
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    private let context = CIContext(options: nil)
    
    //MARK: Outlets -
    
    @IBOutlet weak var slider1Label: UILabel!
    @IBOutlet weak var slider2Label: UILabel!
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var slider4: UISlider!
    @IBOutlet weak var slider5: UISlider!
    enum Sliders {
        case slider1
        case slider2
        case slider3
        case slider4
        case slider5
    }
    @IBOutlet weak var photoImageView: UIImageView!
    //MARK: IBActions -
    @IBAction func slider1(_ sender: UISlider) {
        updateViews()
    }
    @IBAction func slider2(_ sender: Any) {
        updateViews()
    }
    @IBAction func slider3(_ sender: Any) {
        updateViews()
    }
    @IBAction func slider4(_ sender: Any) {
        updateViews()
    }
    @IBAction func slider5(_ sender: Any) {
        updateViews()
    }
    @IBAction func addPhotoButtonPressed(_ sender: Any) {
        presentImagePickerController()
    }
    @IBAction func savePhotoButtonPressed(_ sender: Any) {
        savePhoto()
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let guassianFilter = CIFilter.gaussianBlur()
//        let colorControlsFilter = CIFilter.colorControls()
//        let twirlFilter = CIFilter.hueAdjust()
//
        originalImage = photoImageView.image
        slider5.minimumValue = -3.141592653589793
        slider5.maximumValue = 3.141592653589793
        resetValues()
    }
    
    func updateViews() {
        //        if let originalImage = originalImage {
        //            photoImageView.image = filterImage(originalImage)
        //        } else {
        //            photoImageView.image = UIImage(named: "selfie")
        //        }
        if let scaledImage = scaledImage {
            photoImageView.image = filterImage(scaledImage)
        } else {
            photoImageView.image = nil
        }
    }
    
    //MARK: Methods -
    
    func filterImage(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let gaussianFilter = CIFilter.gaussianBlur()
        gaussianFilter.inputImage = ciImage
        gaussianFilter.radius = slider1.value
        guard let gaussianImage = gaussianFilter.outputImage else { return nil }
        
        // Apply affects
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = gaussianImage
        colorControlsFilter.brightness = slider2.value
        colorControlsFilter.contrast = slider3.value
        colorControlsFilter.saturation = slider4.value
        guard let colorControlsImage = colorControlsFilter.outputImage else { return nil }
        
        // Apply hue adjustment
        let hueFilter = CIFilter.hueAdjust()
        hueFilter.inputImage = colorControlsImage
        hueFilter.angle = slider5.value
        
        //        var inputImage: CIImage? { get set }
        //
        //            var sharpness: Float { get set }
        //
        //            var radius: Float { get set }
        //        }
        
        
        guard let outputCIImage = hueFilter.outputImage else { return nil }
        guard let outputCGIImage = context.createCGImage(outputCIImage,
                                                         from: outputCIImage.extent) else {
                                                                        return nil }
        return UIImage(cgImage: outputCGIImage)
    }
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: The photo library is not available")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    
    private func resetValues() {
           identityValues()
       }
       
       private func identityValues() {
        slider1.value = 0.5
        slider2.value = 0.5
        slider3.value = 0.5
        slider4.value = 0.5
        slider5.value = 0.5
       }
    
    private func savePhoto() {
        guard let originalImage = originalImage else { return }
        
        guard let filteredImage = filterImage(originalImage.flattened) else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetCreationRequest.creationRequestForAsset(from: filteredImage)
                
            }) { success, error in
                if let error = error {
                    print("Error saving photo: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    print("Saved photo")
                }
            }
        }
    }
}

extension PostImageViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
            photoImageView.image = originalImage
            resetValues()
        }
        resetValues()
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
extension PostImageViewController: UINavigationControllerDelegate {
    
}

