//
//  ResetPassword.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 11/12/21.
//

import UIKit
import NVActivityIndicatorView

class ResetPassword: UIViewController {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var passwordChangedLabel: UILabel!
    
    
    private let indicatorView: NVActivityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 185, y: 425, width: 50, height: 50),
        type: NVActivityIndicatorType.ballBeat,
        color: .black,
        padding: 0.5
    )
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backbutton = UIBarButtonItem(image: UIImage(named: "ic_arrow_back"), style: .plain, target: navigationController, action: #selector(UINavigationController.popViewController(animated:)))
        backbutton.tintColor = .black
        navigationItem.leftBarButtonItem = backbutton
        
        passwordChangedLabel.text = "Password changed."
        passwordChangedLabel.isHidden = true
        
        logoImage.image = UIImage(named: "logoMain")
    }
    
    // MARK: ViewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        passwordChangedLabel.isHidden = true
    }
    
    // MARK: ViewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let colorShade1 = UIColor(red: 249/255, green: 202/255, blue: 100/255, alpha: 0.98).cgColor
        let colorShade4 = UIColor(red: 249/255, green: 121/255, blue: 100/255, alpha: 0.98).cgColor
        
        // create the gradient layer
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.startPoint = CGPoint(x:0.0, y:0.0)
        gradient.endPoint = CGPoint(x:1.0, y:1.0)
        gradient.colors = [colorShade1, colorShade4]
        gradient.locations =  [-0.5, 1.5]
        
        self.view.addSubview(indicatorView)
        
        // add the gradient to the view
        self.view.layer.insertSublayer(gradient, at: 0)
        
        resetPasswordButton.layer.masksToBounds = true
        resetPasswordButton.titleLabel?.font = UIFont.robotoBold(size: 20)
        resetPasswordButton.applyGradient(isVertical: false, colorArray: [.orange1Color, .orange2Color])
        resetPasswordButton.tintColor = .white
        resetPasswordButton.layer.cornerRadius = 25
        resetPasswordButton.layer.cornerCurve = .continuous
    }
    
    // hide keyboard when pressing on the outside screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func indexElement(element: String, array: [Users]) -> Int {
        return array.firstIndex(where: { $0.email == element } ) ?? 0
    }
    
    func containsElement(element: String, array: [Users]) -> Bool {
        return array.contains(where: { $0.email == element } )
    }
    
    // MARK: Reset Password Button
    
    @IBAction func resetPassword(_ sender: Any) {
        resetPasswordButton.isEnabled = false
        
        let email = emailTextField.text
        let newPassword = newPasswordTextField.text
        let confirmPassword = confirmPasswordTextField.text
        
        var users = [Users]()
        
        // retrieve all users stored in User defaults
        if let data = UserDefaults.standard.data(forKey: "users") {
            do {
                users = try JSONDecoder().decode([Users].self, from: data)
            }
            catch {
                print("Unable to decode saved users (\(error))")
            }
        }
        print("Current users: \(users.count)")
        
        // check if email entered exists in users array and return the index of the user in the array
        if containsElement(element: email!, array: users) {
            // if two password fields match, change the password
            if newPassword == confirmPassword {
                let userIndex = indexElement(element: email!, array: users)
                // change password at the index and update password at the User defaults
                users[userIndex].password = newPassword!
                do {
                    let data = try JSONEncoder().encode(users)
                    UserDefaults.standard.set(data, forKey: "users")
                    UserDefaults.standard.synchronize()
                }
                catch {
                    print("Unable to encode (\(error))")
                }
            }
            // wrong password fields
            else {
                displayAlert(message: "Passwords do not match")
                resetPasswordButton.isEnabled = true
                return
            }
            
        }
        // wrong email
        else {
            displayAlert(message: "Email is incorrect")
            resetPasswordButton.isEnabled = true
            return
        }
        
        // Function that displays alert messages
        func displayAlert(message: String) {
            let alertMessage = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            
            alertMessage.addAction(okAction)
            self.present(alertMessage, animated: true, completion: nil)
        }
        
        // animation for logging in
        UIView.animate(withDuration: 2.5, animations: animation) { _ in
            self.indicatorView.stopAnimating()
        }
    }
    
    func animation() {
        self.indicatorView.startAnimating()
        self.passwordChangedLabel.isHidden = false
        self.passwordChangedLabel.layer.opacity = 0
        self.passwordChangedLabel.transform = CGAffineTransform(translationX: 0,
                                                                y: self.passwordChangedLabel.bounds.origin.y - 15)
        self.passwordChangedLabel.layer.opacity = 0.9
    }
    
}



