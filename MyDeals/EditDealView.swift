//
//  EditDealView.swift
//  MyDeals
//
//  Created by Mathieu Corti on 9/15/17.
//  Copyright © 2017 Mathieu Corti. All rights reserved.
//

import UIKit
import CoreData

class EditDealView: UIViewController, SelectLinkDelegate, UITextFieldDelegate,
UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var deal: Deal?
    var isNewDeal: Bool = true
    
    @IBOutlet weak var dealTitle_input: UITextField!
    @IBOutlet weak var dealImageLink_input: UITextField!
    @IBOutlet weak var dealLink_input: UITextField!
    @IBOutlet weak var dealMerchant_input: UITextField!
    @IBOutlet weak var dealPrice_input: UITextField!
    @IBOutlet weak var dealDescription_input: UITextView!
    
    @IBOutlet weak var submitDeal_button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable autocomplete for both links fields
        dealLink_input.autocorrectionType = .no
        dealImageLink_input.autocorrectionType = .no
        
        // Add borders to description text field
        dealDescription_input.layer.cornerRadius = 5
        dealDescription_input.layer.borderColor = UIColor.lightGray.cgColor
        dealDescription_input.layer.borderWidth = 0.2
        
        // Add rounded cormners to button
        submitDeal_button.layer.cornerRadius = 3
        
        // Delegate
        dealPrice_input.delegate = self
        dealDescription_input.delegate = self
        
        // Add alert controllers
        dealImageLink_input.addTarget(self, action: #selector(onClick(_:)), for: .touchDown)
        dealLink_input.addTarget(self, action: #selector(onClick(_:)), for: .touchDown)
        
        // Hide keyboard when touch outside
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditting)))
        
        // Add submit button on navbar
        let submit = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitDeal))
        navigationItem.rightBarButtonItem = submit
        
        // Fill fields if editting deal
        if isNewDeal == false, let dealObject = deal {
            dealTitle_input.text = dealObject.title
            dealImageLink_input.text = dealObject.imageLink
            dealLink_input.text = dealObject.link
            dealMerchant_input.text = dealObject.merchant?.replacingOccurrences(of: "@", with: "")
            dealPrice_input.text = dealObject.price
            dealDescription_input.text = dealObject.desc?.replacingOccurrences(of: "<br>", with: "\n").replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: "")
        }
    }
    
    func fillFields() {
        
    }
    
    func onClick(_ textField: UITextField) {
        
        let imagePicker = UIImagePickerController()
        let inputAction = UIAlertController(title: "Editing style",
                                            message: nil,
                                            preferredStyle: .actionSheet)

        let leftViewMode_state = textField.leftViewMode
        let placeholder_state = textField.placeholder
        
        textField.leftViewMode = UITextFieldViewMode.never
        textField.placeholder = ""
        
        imagePicker.delegate = self
        
        // Add basics actions
        inputAction.addAction(UIAlertAction(title: "Edit manually", style: .default) { (action) in
            textField.leftViewMode = UITextFieldViewMode.never
            textField.placeholder = ""
            textField.becomeFirstResponder()
        })
        
        inputAction.addAction(UIAlertAction(title: "Paste from clipboard", style: .default) { (action) in
            textField.leftViewMode = UITextFieldViewMode.never
            textField.placeholder = ""
            textField.text = UIPasteboard.general.string
        })
        
        if textField == dealImageLink_input {
            
            inputAction.addAction(UIAlertAction(title: "Pick from camera", style: .default) { (action) in
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Failed", message: "Camera not available", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            })
            
            inputAction.addAction(UIAlertAction(title: "Pick from library", style: .default) { (action) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            })
            
            inputAction.addAction(UIAlertAction(title: "Search image", style: .default) { (action) in
                self.performSegue(withIdentifier: "searchImage", sender: nil)
            })
            
        } else if textField == dealLink_input {
            
            inputAction.addAction(UIAlertAction(title: "Search deal", style: .default) { (action) in
                self.performSegue(withIdentifier: "searchDeal", sender: nil)
            })
        }
        
        inputAction.addAction(UIAlertAction(title: "cancel", style: .cancel) { (action) in
            textField.leftViewMode = leftViewMode_state
            textField.placeholder = placeholder_state
        })
        
        self.present(inputAction, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage

        dealImageLink_input.text = ""
        dealImageLink_input.leftViewMode = UITextFieldViewMode.always
        
        let leftImageView = UIImageView()
        leftImageView.image = image
        
        let leftView = UIView()
        leftView.addSubview(leftImageView)
        
        leftView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        leftImageView.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        
        dealImageLink_input.leftView = leftView
        dealImageLink_input.placeholder = "Picked image."
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func didSelectImage(_ link: String) {
        
        if !isValidImageUrl(link: link) {
            dealImageLink_input.text = "Invalid image link"
        } else {
            dealImageLink_input.text = link
        }
    }
    
    func didSelectDeal(_ link: String) {
        
        dealLink_input.text = link
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "submitDeal" {
            
            var error: String = String()
            
            if dealTitle_input.text == "" {
                error = "Please enter a deal title."
            } else if dealMerchant_input.text == "" {
                error = "Please enter a merchant."
            } else if dealImageLink_input.text == "" {
                error = "Please enter an image link."
            } else if dealPrice_input.text == "" {
                error = "Please enter a deal price, code, promotion value."
            } else if dealDescription_input.text == "" {
                error = "Please provide a description for your deal."
            }
            
            if !error.isEmpty {
                
                let alert = UIAlertController(title: "Failed to submit", message: error, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "submitDeal" {
            
//            let controller = segue.destination as! MasterViewController
            
            let dealtoSubmit:Deal
            
            if isNewDeal == false, let dealObject = deal {
                print(dealTitle_input.text! + " will be updated !")
                dealtoSubmit = dealObject
            } else {
                print(dealTitle_input.text! + " is a new deal !")
                dealtoSubmit = NSEntityDescription.insertNewObject(forEntityName: "Deal", into: DatabaseController.getContext()) as! Deal
            }

            dealtoSubmit.title = dealTitle_input.text!
            dealtoSubmit.merchant = "@" + dealMerchant_input.text!
            dealtoSubmit.desc = "<p>" + dealDescription_input.text.replacingOccurrences(of: "\n", with: "<br>") + "</p>"
            dealtoSubmit.price = dealPrice_input.text
            dealtoSubmit.imageLink = dealImageLink_input.text!
            dealtoSubmit.link = dealLink_input.text!
            
            DatabaseController.saveContext()
            
            if isNewDeal == true {
                dealtoSubmit.isEditable = true
                Deals.sharedInstance.deals[INDEX_MY_DEALS].insert(dealtoSubmit, at: 0)
            }
            
        } else if segue.identifier == "searchImage" {
            
            let controller = segue.destination as! WebView
            controller.identifier = "searchImage"
            controller.delegate = self
            controller.link = "https://images.google.com/"
            controller.searchEngine = "http://www.google.com/images?q="
        } else if segue.identifier == "searchDeal" {
            
            let controller = segue.destination as! WebView
            controller.identifier = "searchDeal"
            controller.delegate = self
        }
    }
    
    func submitDeal() {
        
        if self.shouldPerformSegue(withIdentifier: "submitDeal", sender: nil) {
            self.performSegue(withIdentifier: "submitDeal", sender: nil)
        }
    }
    
    func endEditting() {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        animateViewMoving(up: true, moveValue: 100)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 100)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    
}
