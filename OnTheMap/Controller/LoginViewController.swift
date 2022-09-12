//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by minhdat on 06/09/2022.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var actionGuide: UIActivityIndicatorView!
        
    var isEmptyEmail = true
    var isEmptyPassword = true

    override func viewDidLoad() {
        super.viewDidLoad()
        mail.text = ""
        pwd.text = ""
        mail.delegate = self
        pwd.delegate = self
        buttonEnabled(false, button: login)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mail.text = UdacityService.shared().userName
        pwd.text = UdacityService.shared().password
        buttonEnabled(true, button: login)
    }
    
    @IBAction func login(_ sender: UIButton) {
        setLoggingIn(true)
        UdacityService.shared().userName = self.mail.text
        UdacityService.shared().password = self.pwd.text
        UdacityService.shared().login(email: self.mail.text ?? "", password: self.pwd.text ?? "", completion: handleLoginResponse(success:error:))
    }

    @IBAction func signUp(_ sender: Any) {
        setLoggingIn(true)
        guard let url = URL(string: API.authUrl) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            DispatchQueue.main.async {
                self.actionGuide.startAnimating()
                self.buttonEnabled(false, button: self.login)
            }
        } else {
            DispatchQueue.main.async {
                self.actionGuide.stopAnimating()
                self.buttonEnabled(true, button: self.login)
            }
        }
        DispatchQueue.main.async {
            self.mail.isEnabled = !loggingIn
            self.pwd.isEnabled = !loggingIn
            self.login.isEnabled = !loggingIn
            self.signUp.isEnabled = !loggingIn
        }
    }

    func handleLoginResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        DispatchQueue.main.async {
            if success {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                guard let tabbar = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "UITabBarController") as? UITabBarController else {
                    return
                }
                
                appDelegate.window?.rootViewController = tabbar
                appDelegate.window?.makeKeyAndVisible()
            } else {
                self.showAlert(message: error?.localizedDescription ?? "", title: "Login Error")
            }
        }
    }
    
  
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == mail {
            let currenText = mail.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                isEmptyEmail = true
            } else {
                isEmptyEmail = false
            }
        }
        
        if textField == pwd {
            let currenText = pwd.text ?? ""
            guard let stringRange = Range(range, in: currenText) else { return false }
            let updatedText = currenText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty && updatedText == "" {
                isEmptyPassword = true
            } else {
                isEmptyPassword = false
            }
        }
        
        if isEmptyEmail == false && isEmptyPassword == false {
            buttonEnabled(true, button: login)
        } else {
            buttonEnabled(false, button: login)
        }
        
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        buttonEnabled(false, button: login)
        if textField == mail {
            isEmptyEmail = true
        }
        if textField == pwd {
            isEmptyPassword = true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            login(login)
        }
        return true
    }
}


