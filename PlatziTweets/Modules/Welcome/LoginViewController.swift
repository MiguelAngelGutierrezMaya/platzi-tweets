//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Keybe on 25/03/23.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

// Create our own color for dark mode
extension UIColor {
    static let customGreen: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (trait: UITraitCollection) -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    // Dark mode
                    return .white
                } else {
                    // Light mode
                    return .green
                }
            }
        } else {
            // Return a fallback color for iOS 12 and lower
            return .green
        }
    }()
}

class LoginViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func loginButtonAction() {
        view.endEditing(true)
        self.performLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        loginButton.layer.cornerRadius = 25
        loginButton.backgroundColor = UIColor.customGreen
        
//        if #available(iOS 13.0, *) {
//            // overrideUserInterfaceStyle = .light
//        }
    }
    
    private func performLogin() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(
                title: "Error",
                subtitle: "Debes especificar un correo",
                style: .danger
            ).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(
                title: "Error",
                subtitle: "Debes especificar una contraseña",
                style: .danger
            ).show()
            return
        }
        
        // Create Request
        let request = LoginRequest(email: email, password: password)
        
        // Init loading
        SVProgressHUD.show()
        
        // Call network library
        SN.post(endpoint: Endpoints.login,
                model: request) { (response: SNResultWithEntity<LoginResponse, ErrorApiResponse>) in
            
            SVProgressHUD.dismiss()
            
            switch response {
            case .success(let response):
                self.performSegue(withIdentifier: "showHome", sender: response)
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: "Bearer \(response.token)")
            case .error(let error):
                NotificationBanner(
                    subtitle: "Error = \(error.localizedDescription)",
                    style: .danger
                ).show()
            case .errorResult(let errorResponse):
                NotificationBanner(
                    subtitle: "Error = \(errorResponse.errorType.message)",
                    style: .danger
                ).show()
            }
        }
    }
    
}
