//
//  LogInViewController.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 3/12/21.
//

import UIKit
import NVActivityIndicatorView

class LogInViewController: UIViewController {
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
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
        
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        welcomeLabel.text = "Welcome!"
        welcomeLabel.isHidden = true
        
        logoImage.image = UIImage(named: "logoMain")
    }
    
    // MARK: ViewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        welcomeLabel.isHidden = true
        
        UIView.animate(withDuration: 1) {
            self.greetingLabel.isHidden = false
            self.greetingLabel.text = "Good to see you again"
            self.greetingLabel.layer.opacity = 0
            self.greetingLabel.layer.opacity = 1
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.greetingLabel.isHidden = true
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
        
        logInButton.layer.masksToBounds = true
        logInButton.titleLabel?.font = UIFont.robotoBold(size: 20)
        logInButton.applyGradient(isVertical: false, colorArray: [.orange1Color, .orange2Color])
        logInButton.tintColor = .white
        logInButton.layer.cornerRadius = 25
        logInButton.layer.cornerCurve = .continuous
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
    
    // MARK: Log In Button
    
    @IBAction func logIn(_ sender: Any) {
        logInButton.isEnabled = false
        
        let userEmail = emailTextField.text
        let userPassword = passwordTextField.text
        
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
        if containsElement(element: userEmail!, array: users) {
            let userIndex = indexElement(element: userEmail!, array: users)
            // check if password of user with the above email is correct
            if users[userIndex].password == userPassword {
                // login and update the currentUser singleton to retrieve and store recipes
                Users.currentUser.email = users[userIndex].email
                Users.currentUser.password = users[userIndex].password
                Users.currentUser.username = users[userIndex].username
                Users.currentUser.isLoggedIn = true
                Users.currentUser.index = userIndex
                Users.currentUser.savedRecipes = users[userIndex].savedRecipes
                do {
                    let data = try JSONEncoder().encode(users)
                    UserDefaults.standard.set(data, forKey: "users")
                    UserDefaults.standard.synchronize()
                }
                catch {
                    print("Unable to encode (\(error))")
                }
            }
            // wrong password
            else {
                displayAlert(message: "Password is incorrect")
                logInButton.isEnabled = true
                return
            }
        }
        // wrong email
        else {
            displayAlert(message: "Email is incorrect")
            logInButton.isEnabled = true
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
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.view.window?.rootViewController = viewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    func animation() {
        self.indicatorView.startAnimating()
        self.welcomeLabel.isHidden = false
        self.welcomeLabel.layer.opacity = 0
        self.welcomeLabel.transform = CGAffineTransform(translationX: 0,
                                                        y: self.welcomeLabel.bounds.origin.y - 20)
        self.welcomeLabel.layer.opacity = 0.9
    }
}
