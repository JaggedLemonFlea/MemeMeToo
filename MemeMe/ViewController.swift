//
//  ViewController.swift
//  MemeMe
//
//  Created by Steve Brylka on 9/20/18.
//  Copyright © 2018 Steve Brylka. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

// MARK: Outlets >>>
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var tfTop: UITextField!
    @IBOutlet weak var tfBottom: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
// <<< Outlets
    
// MARK: Structs >>>
    
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfTop.delegate = self
        tfBottom.delegate = self
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = imagePickerView.image != nil
        cancelButton.isEnabled = imagePickerView.image != nil
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
// MARK:  Actions >>>
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme() {
        imagePickerView.image = nil
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        tfTop.text = nil
        tfBottom.text = nil
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    // MARK:  Image Picker Controller takes image from Album or Camera and returns it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFill
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
            dismiss(animated: true, completion: nil)
        }
        
    }
    
// MARK: Meme Text Field setup
    
    // Font styling
//    let memeTextAttributes: [String: Any] =
//        [
//            NSAttributedString.Key.strokeColor.rawValue: UIColor.black,
//            NSAttributedString.Key.foregroundColor.rawValue: UIColor.white,
//            NSAttributedString.Key.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
//            NSAttributedString.Key.strokeWidth.rawValue: -3.0
//        ]
//    
//    // Text Field setup
//    func setupTextFields(_ textField: UITextField, with default: String) {
//        textField.defaultTextAttributes = memeTextAttributes
//        textField.textAlignment = .center
//
//    }
    
    
// MARK: Keyboard Functions >>>
    
    // Subscribe to keyboard notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe to keyboard notifications
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // Move frame up when botton text field is clicked and keyboard shows
    @objc func keyboardWillShow(_ notification: Notification) {
        if tfBottom.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    // Move frame back down after keyboard is for bottom text field is dismissed
    @objc func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    }
    
    // Get keyboard height
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Dismisses the keyboard when return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
// <<< Keyboard Functions
    
    
    // MARK:  Save, Generate & Share meme functions
    
    // Save Meme
    func save() {
        let meme = Meme(topText: tfTop.text!, bottomText: tfBottom.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        print(meme)
    }
    
    // Generate Meme
    func generateMemedImage() -> UIImage {
        hideToolBars(when: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hideToolBars(when: false)
        return memedImage
    }
    
    // Hide top and bottom toolbars called while generating meme to keep toolbars out of generated image
    func hideToolBars(when bool: Bool) {
        toolBar.isHidden = bool
        navBar.isHidden = bool
    }
    
    // Share Meme
    @IBAction func shareMeme(){
        let memedImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityView.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed) {
                let _ = self.save()
            }
        }
        
        self.present(activityView, animated: true, completion: nil)
    }
    
}

