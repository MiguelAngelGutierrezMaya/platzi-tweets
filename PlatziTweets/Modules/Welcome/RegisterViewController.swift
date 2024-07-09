//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Keybe on 25/03/23.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var namesTextField: UITextField!
    @IBOutlet weak var lastnamesTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func registerButtonAction() {
        view.endEditing(true)
        self.performRegister()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        registerButton.layer.cornerRadius = 25
    }
    
    private func performRegister() {
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
        guard let names = namesTextField.text, !names.isEmpty else {
            NotificationBanner(
                title: "Error",
                subtitle: "Debes especificar tu nombre",
                style: .danger
            ).show()
            return
        }
        guard let lastnames = lastnamesTextField.text, !lastnames.isEmpty else {
            NotificationBanner(
                title: "Error",
                subtitle: "Debes especificar tu apellido",
                style: .danger
            ).show()
            return
        }
        guard let nickname = nickNameTextField.text, !nickname.isEmpty else {
            NotificationBanner(
                title: "Error",
                subtitle: "Debes especificar tu apodo",
                style: .danger
            ).show()
            return
        }
        
        // Create request
        let request = RegisterRequest(
            email: email,
            password: password,
            names: names,
            lastnames: lastnames,
            nickname: nickname
        )
        
        // Indicate User loading
        SVProgressHUD.show()
        
        // Call network library
        SN.post(endpoint: Endpoints.register,
                model: request) { (response: SNResultWithEntity<RegisterResponse, ErrorApiResponse>) in
            
            // Close user loading
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
