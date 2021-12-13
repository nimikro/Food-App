//
//  SignUpViewController.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 4/12/21.
//

import UIKit
import NVActivityIndicatorView

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
    private let indicatorView: NVActivityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 185, y: 350, width: 50, height: 50),
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
        
        logoImage.image = UIImage(named: "logoMain")
        
        registrationLabel.text =
        """
        Your registration was successful.
        Thank you!
        """
        registrationLabel.isHidden = true
        registrationLabel.textColor = UIColor(red: 37/255, green: 184/255, blue: 0/255, alpha: 0.72)
        
        nameTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
    }
    
    // MARK: ViewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no

        UIView.animate(withDuration: 1) {
            self.greetingLabel.text = "Nice to meet you"
            self.greetingLabel.layer.opacity = 0
            self.greetingLabel.layer.opacity = 1
        }
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
        
        // add the gradient to the view
        self.view.layer.insertSublayer(gradient, at: 0)
        
        self.view.addSubview(indicatorView)
        
        signUpButton.layer.masksToBounds = true
        signUpButton.titleLabel?.font = UIFont.robotoBold(size: 20)
        signUpButton.applyGradient(isVertical: false, colorArray: [.orange1Color, .orange2Color])
        signUpButton.tintColor = .white
        signUpButton.layer.cornerRadius = 25
        signUpButton.layer.cornerCurve = .continuous
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
    
    
    // MARK: Sign Up Button
    
    @IBAction func signUp(_ sender: Any) {
        signUpButton.isEnabled = false
        
        let userName = nameTextField.text
        let userEmail = emailTextField.text
        let userPassword = passwordTextField.text
        
        var users = [Users]()
        
        print("Current users: \(users.count)")
        
        // Check if any of the fields is empty
        if (userName?.isEmpty ?? true || userEmail?.isEmpty
            ?? true || userPassword?.isEmpty ?? true) {
            displayAlert(message: "All fields are required")
            signUpButton.isEnabled = true
            return
        }
        
        // retrieve all users stored in User defaults
        if let data = UserDefaults.standard.data(forKey: "users") {
            do {
                users = try JSONDecoder().decode([Users].self, from: data)
            }
            catch {
                print("Unable to decode saved users (\(error))")
            }
        }
        
        // check if email already exists
        if containsElement(element: userEmail!, array: users) {
            displayAlert(message: "Email already exists. Please choose a different one.")
            signUpButton.isEnabled = true
            return
        }
        // if email doesn't exist, create and store new user
        // users singleton now contains current User that signed up and can be used to retrieve or store recipes
        else {
            let newUser = Users()
            Users.currentUser.email = userEmail!
            Users.currentUser.password = userPassword!
            Users.currentUser.username = userName!
            Users.currentUser.savedRecipes = []
            newUser.email = userEmail!
            newUser.password = userPassword!
            newUser.username = userName!
            users.append(newUser)
            let userIndex = indexElement(element: newUser.email, array: users)
            Users.currentUser.isLoggedIn = true
            Users.currentUser.index = userIndex
            do {
                let data = try JSONEncoder().encode(users)
                UserDefaults.standard.set(data, forKey: "users")
                UserDefaults.standard.synchronize()
            }
            catch {
                print("Unable to encode (\(error))")
            }
        }
        
        // animation at successful registration
        UIView.animate(withDuration: 2.5, animations: animation) { _ in
            self.indicatorView.stopAnimating()
            self.registrationLabel.isHidden = true
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.view.window?.rootViewController = viewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    // Display alert message function if email exists
    func displayAlert(message: String) {
        let alertMessage = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertMessage.addAction(okAction)
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    func animation() {
        self.indicatorView.startAnimating()
        self.registrationLabel.isHidden = false
        self.registrationLabel.layer.opacity = 0.7
        self.registrationLabel.transform = CGAffineTransform(translationX: 0,
                                                             y: self.registrationLabel.bounds.origin.y - 13)
        self.registrationLabel.layer.opacity = 0.9
    }
    
}

