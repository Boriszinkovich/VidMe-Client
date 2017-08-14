//
//  FeedVC.swift
//  VidMeClient
//
//  Created by User on 13.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit

class FeedVC: UIViewController
{
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createUI()
    }
    
    func createUI()
    {
        let cornerRadius: CGFloat = 4
        signInButton.layer.cornerRadius = cornerRadius
        usernameTextField.layer.cornerRadius = cornerRadius
        passwordTextField.layer.cornerRadius = cornerRadius
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        let fontSize: CGFloat = 17
        passwordTextField.font = UIFont.getAppStyleFont(size: fontSize)
        usernameTextField.font = UIFont.getAppStyleFont(size: fontSize)
        signInButton.titleLabel?.font = UIFont.getAppStyleFont(size: fontSize)
        // TODO:
//        let centeredParagraphStyle = NSMutableParagraphStyle()
//        centeredParagraphStyle.alignment = .center
//        usernameTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Username", comment: ""), attributes: [NSParagraphStyleAttributeName: centeredParagraphStyle])
//        passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: ""), attributes: [NSParagraphStyleAttributeName: centeredParagraphStyle])
    }
}

extension FeedVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField.isEqual(self.usernameTextField)
        {
            self.passwordTextField.becomeFirstResponder()
        }
    }
}





























