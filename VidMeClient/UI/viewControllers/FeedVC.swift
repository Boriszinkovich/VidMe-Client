//
//  FeedVC.swift
//  VidMeClient
//
//  Created by User on 13.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit
import JGProgressHUD

class FeedVC: VideoListVC
{
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    {
        didSet
        {
            self.logOutButton.addTarget(self, action: #selector(logOutTapped(_:)), for: .touchUpInside)
        }
    }
    private var progressHud: JGProgressHUD?
    fileprivate var isUserAuthorized: Bool! = ((WebService.sharedInstance.user != nil) && (WebService.sharedInstance.user?.accessToken.isValid() == true))
    {
        didSet
        {
            self.updateUIAuthState(needAuth: !self.isUserAuthorized)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createFeedUI()
        self.updateUIAuthState(needAuth: !self.isUserAuthorized)
    }
    
    func createFeedUI()
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
        signInButton.addTarget(self, action: #selector(signInTapped(_:)), for: .touchUpInside)
    }
    
    func logOutTapped(_ button: UIButton)
    {
        WebService.sharedInstance.deleteAuth()
        self.isUserAuthorized = false
        self.updateUIAuthState(needAuth: true)
    }
    
    func signInTapped(_ button: UIButton)
    {
        self.passwordTextField.resignFirstResponder()
        self.usernameTextField.resignFirstResponder()
        if self.internetReachability.isReachable == false
        {
            return
        }
        else if self.passwordTextField.text?.isEmpty == true || self.usernameTextField.text?.isEmpty == true
        {
            self.updateErrorLabel(errorText: NSLocalizedString("Invalid login or password", comment: ""))
            return;
        }
        else
        {
            self.startAuth(login: self.usernameTextField.text!, password: self.passwordTextField.text!)
        }
    }
    
    func startAuth(login: String, password: String)
    {
        if self.internetReachability.isReachable == false
        {
            return
        }
        WebService.sharedInstance.authListener = self
        _ = WebService.sharedInstance.authUser(username: login, password: password)
    }
    
    func updateErrorLabel(errorText text:String)
    {
        self.errorLabel.alpha = 1
        self.errorLabel.text = text
    }
    
    func showAuthAlert()
    {
        self.buildProgressHud()
        progressHud?.textLabel.text = NSLocalizedString("Authenticating..", comment: "")
        progressHud?.detailTextLabel.text = nil
        self.progressHud?.show(in: self.view)
    }
    
    func showSuccessAlert()
    {
        self.buildProgressHud()
        self.progressHud?.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.progressHud?.textLabel.text = NSLocalizedString("Success", comment: "")
        self.progressHud?.layoutChangeAnimationDuration = 0.3
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime)
        {
            self.progressHud?.dismiss()
            self.progressHud = nil
        }
    }
    
    func showFailureAlert(string: String)
    {
        self.buildProgressHud()
        self.progressHud?.indicatorView = JGProgressHUDErrorIndicatorView()
        self.progressHud?.textLabel.text = NSLocalizedString("Error", comment: "")
        self.progressHud?.detailTextLabel.text = string
        self.progressHud?.layoutChangeAnimationDuration = 0.3
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime)
        {
            self.progressHud?.dismiss()
            self.progressHud = nil
        }
    }
    
    func buildProgressHud()
    {
        if self.progressHud != nil
        {
            return
        }
        let progressHud = JGProgressHUD(style: .extraLight)
        self.progressHud = progressHud
        progressHud?.interactionType = .blockAllTouches
        progressHud?.animation = JGProgressHUDFadeZoomAnimation()
        progressHud?.backgroundColor = UIColor.init(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.4)
        progressHud?.layoutChangeAnimationDuration = 0
    }
    
    func updateUIAuthState(needAuth: Bool)
    {
        if needAuth == true
        {
            self.currentPlayingVideo?.isVideoPlaying = false
            self.videosArray.removeAll()
            self.collView.reloadData()
            authView.alpha = 1
            logOutButton.alpha = 0
            self.view.bringSubview(toFront: authView)
            self.view.bringSubview(toFront: self.errorView)
        }
        else
        {
            authView.alpha = 0
            logOutButton.alpha = 1
            self.view.bringSubview(toFront: self.logOutButton)
        }
    }
    
    override func methodLoadVideos(offset:UInt)
    {
        if self.isUserAuthorized == false
        {
            return
        }
        _ = WebService.sharedInstance.getFeedVideosList(offset: offset, success: {(response) in
            self.handleNewVideos(videos: response, refreshing:offset == 0)
        }, failure: { (error) in
            self.handleErrorVideos(refreshing: offset == 0, error: error)
        })
    }
}

extension FeedVC: AuthListener
{
    func authStarted()
    {
        self.showAuthAlert()
    }
    
    func authorizeFailed(error: Error)
    {
        let errorString = "Invalid login or password"
        self.updateErrorLabel(errorText: errorString)
        self.showFailureAlert(string: errorString)
    }
    
    func authorizeSuccess(user: User)
    {
        self.passwordTextField.text = ""
        self.usernameTextField.text = ""
        self.isUserAuthorized = true
        self.showSuccessAlert()
        self.isRefreshing = false
        self.refreshVideos()
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





























