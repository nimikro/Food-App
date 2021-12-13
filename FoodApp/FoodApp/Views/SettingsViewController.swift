//
//  Settings.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 28/11/21.
//

import UIKit
import NVActivityIndicatorView
// shows user settings
class SettingsViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var loggingOutLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerFrame: UIImageView!
    
    private let indicatorView: NVActivityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 185, y: 725, width: 50, height: 50),
        type: NVActivityIndicatorType.ballBeat,
        color: .black,
        padding: 0.5
    )
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SETTINGS"
        
        loggingOutLabel.text = "Logging you out..."
        loggingOutLabel.isHidden = true
        // Retrieve user data from user defaults
        let nameStored = Users.currentUser.username
        let emailStored = Users.currentUser.email
        let isLoggedIn = Users.currentUser.isLoggedIn
        
        if isLoggedIn {
            self.userNameLabel.text = nameStored
            self.userEmailLabel.text = emailStored
            actionButton.setTitle("Log out", for: .normal)
        } else {
            self.userNameLabel.text = "-"
            self.userEmailLabel.text = "-"
            actionButton.setTitle("Log in", for: .normal)
        }
    }
    
    let userDefaults = UserDefaults.standard
    
    // MARK: ViewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Retrieve user data from user defaults
        let nameStored = Users.currentUser.username
        let emailStored = Users.currentUser.email
        let isLoggedIn = Users.currentUser.isLoggedIn
        
        // If a user is logged in, their name and email appears, as well as the option to logout
        // otherwise, they can only login
        if isLoggedIn {
            self.userNameLabel.text = nameStored
            self.userEmailLabel.text = emailStored
            actionButton.setTitle("Log out", for: .normal)
        } else {
            self.userNameLabel.text = "-"
            self.userEmailLabel.text = "-"
            actionButton.setTitle("Log in", for: .normal)
        }
    }
    
    // MARK: ViewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(indicatorView)
        actionButton.layer.masksToBounds = true
        actionButton.titleLabel?.font = UIFont.robotoBold(size: 20)
        actionButton.applyGradient(isVertical: false, colorArray: [.orange1Color, .orange2Color])
        actionButton.tintColor = .white
        actionButton.layer.cornerRadius = 25
        actionButton.layer.cornerCurve = .continuous
        
        containerView.layer.cornerRadius = 25
        containerView.backgroundColor = .white
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        containerView.layer.shadowOpacity = 0.7
        containerView.layer.shadowRadius = 25
        containerView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        
        innerFrame.clipsToBounds = true
        innerFrame.layer.cornerRadius = 25
        innerFrame.applyGradient(isVertical: true, colorArray: [.orange1Color, .orange2Color])
    }
    
    // MARK: Logout Button
    
    @IBAction func logoutAction(_ sender: UIButton) {
        actionButton.isEnabled = false
        
        let isLoggedIn = Users.currentUser.isLoggedIn
        // if user is logged in, set log in state to false
        if isLoggedIn {
            Users.currentUser.isLoggedIn = false
            // animation for logging out
            UIView.animate(withDuration: 2.5, animations: animation) { _ in
                self.indicatorView.stopAnimating()
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TestingView")
                self.view.window?.rootViewController = viewController
                self.view.window?.makeKeyAndVisible()
            }
        }
        // else simply take him to starting controller to log in
        else {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TestingView")
            self.view.window?.rootViewController = viewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    func animation() {
        self.indicatorView.startAnimating()
        self.loggingOutLabel.isHidden = false
        self.loggingOutLabel.layer.opacity = 0
        self.loggingOutLabel.transform = CGAffineTransform(translationX: 0,
                                                           y: self.loggingOutLabel.bounds.origin.y - 15)
        self.loggingOutLabel.layer.opacity = 1
    }
}
