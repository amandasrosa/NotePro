//
//  SubjectVC.swift
//  NotePro
//
//  Created by Araceli Teixeira on 28/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class SubjectVC: UIViewController, UITextFieldDelegate, HSBColorPickerDelegate {
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorPicker: HSBColorPicker!
    @IBOutlet weak var btnSave: UIButton!
    
    public var subject: Subject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        subjectTextField.delegate = self
        colorPicker.delegate = self
        
        if let subject = subject {
            subjectTextField.text = subject.subject
            colorView.backgroundColor = subject.color
        }
        
        btnSave.isEnabled = false
    }

    private func updateSaveButtonState() {
        if let text = subjectTextField.text {
            btnSave.isEnabled = !text.isEmpty
        }
    }
    
    // MARK: Delegates
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateSaveButtonState()
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        if let text = textView.text as NSString? {
            let resultString = text.replacingCharacters(in: range, with: text as String)
            if resultString != "" {
                btnSave.isEnabled = true
            }
        }
        
        return true
    }
    
    func HSBColorColorPickerTouched(sender: HSBColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizerState) {
        colorView.backgroundColor = color
        updateSaveButtonState()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let button = sender as? UIButton {
            if button === btnSave {
                subjectTextField.resignFirstResponder()
                
                guard let subjectField = subjectTextField, let txtSubject = subjectField.text, let colorV = colorView,
                    let color = colorV.backgroundColor else {
                        print("Invalid input")
                        return
                }
                
                if let subject = subject {
                    subject.setSubject(txtSubject)
                    subject.setColor(color)
                } else {
                    subject = Subject(txtSubject, color)
                }
                
                CoreFacade.shared.saveSubject(subject)
            }
        }
    }
}

extension UIViewController {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

