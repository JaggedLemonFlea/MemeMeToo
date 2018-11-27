//
//  ViewController.swift
//  MemeMe
//
//  Created by Steve Brylka on 9/20/18.
//  Copyright © 2018 Steve Brylka. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

// MARK: Outlets >>>
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = imagePickerView.image != nil
        //cancelButton.isEnabled = imagePickerView.image != nil
        setupTextFields(topTextField, with: "TOP")
        setupTextFields(bottomTextField, with: "BOTTOM")
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    

    // Function to pick an image (passed source type by "Pick An Image From..." actions below
    func pickAnImage(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

// MARK: Actions
    
    // Single action using tags to pass which source to get image from
    @IBAction func pickFromButton(_ sender: UIBarButtonItem){
        if sender.tag == 0 {
            pickAnImage(sourceType: .camera)
        }
        if sender.tag == 1 {
            pickAnImage(sourceType: .photoLibrary)
        }
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        imagePickerView.image = nil
        shareButton.isEnabled = false
        //cancelButton.isEnabled = false
        //topTextField.text = nil
        //bottomTextField.text = nil
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        dismiss(animated: true, completion: nil)
    }
    
// MARK:  Image Picker Controller takes image from Album or Camera and returns it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
            dismiss(animated: true, completion: nil)
        }
        
    }
    
// MARK: Meme Text Field setup
    
    // Text Field setup
    func setupTextFields(_ textField: UITextField, with default: String) {
        let memeTextAttributes: [NSAttributedString.Key: Any] =
            [
                NSAttributedString.Key.strokeColor: UIColor.black,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                NSAttributedString.Key.strokeWidth: -4.0
            ]
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    
// MARK: Keyboard Functions
    
    // Subscribe to keyboard notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe to keyboard notifications
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // Move frame up when botton text field is clicked and keyboard shows
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
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
        
        return true
    }
    
    
// MARK:  Save, Generate & Share meme functions
    
    // Save Meme
    func save() {
        
        // Update the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        // Add it to the memes array on the Applicatoin Delegate
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
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
        present(activityView, animated: true, completion: nil)
        
        // save meme
        activityView.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed) {
                let _ = self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

