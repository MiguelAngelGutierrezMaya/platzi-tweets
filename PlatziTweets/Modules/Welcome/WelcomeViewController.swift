//
//  WelcomeViewController.swift
//  PlatziTweets
//
//  Created by Keybe on 25/03/23.
//

import UIKit

class WelcomeViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    

    private func setupUI() {
        loginButton.layer.cornerRadius = 25
    }

}
