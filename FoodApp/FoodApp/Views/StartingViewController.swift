//
//  StartingViewController.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 3/12/21.
//

import UIKit



class StartingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var continueAsGuestButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    
    private var gradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 1) {
            self.logoImage.image = UIImage(named: "logoMain")
            self.logoImage.layer.opacity = 0
            self.logoImage.layer.opacity = 1
        }
        
        // define colors
        let colorShade1 = UIColor(red: 249/255, green: 202/255, blue: 100/255, alpha: 0.98).cgColor
        let colorShade2 = UIColor(red: 219/255, green: 164/255, blue: 88/255, alpha: 0.86).cgColor
        let colorShade3 = UIColor(red: 219/255, green: 126/255, blue: 88/255, alpha: 0.86).cgColor
        let colorShade4 = UIColor(red: 249/255, green: 121/255, blue: 100/255, alpha: 0.98).cgColor
        let colorShade8 = UIColor(red: 222/255, green: 73/255, blue: 114/255, alpha: 0.87).cgColor
        let colorShade10 = UIColor(red: 245/255, green: 103/255, blue: 92/255, alpha: 0.96).cgColor
        
        // create the gradient layer
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.startPoint = CGPoint(x:0.0, y:0.0)
        gradient.endPoint = CGPoint(x:1.0, y:1.0)
        gradient.colors = [colorShade1, colorShade4]
        gradient.locations =  [-0.5, 1.5]
        
        // create animation
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = [colorShade2, colorShade3]
        animation.toValue = [colorShade8, colorShade10]
        animation.duration = 3.0
        animation.fillMode = .forwards
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        // add the animation to the gradient
        gradient.removeAllAnimations()
        gradient.add(animation, forKey: nil)
        
        // add the gradient to the view
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    // MARK: ViewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //view.applyGradient(isVertical: true, colorArray: [.orange1Color,.orange2Color])
        titleLabel.shadowColor = .customTextBlack
        titleLabel.font = UIFont.robotoBold(size: 40)
        titleLabel.shadowOffset = CGSize(width: 2, height: 3)
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowRadius = 25
        
        logInButton.layer.masksToBounds = true
        logInButton.titleLabel?.font = UIFont.robotoBold(size: 20)
        logInButton.applyGradient(isVertical: false, colorArray: [.orange1Color, .orange2Color])
        logInButton.tintColor = .white
        logInButton.layer.cornerRadius = 25
        logInButton.layer.cornerCurve = .continuous
        
        signUpButton.layer.masksToBounds = true
        signUpButton.titleLabel?.font = UIFont.robotoBold(size: 20)
        signUpButton.backgroundColor = .white
        signUpButton.tintColor = .orange1Color
        signUpButton.layer.cornerRadius = 25
        signUpButton.layer.cornerCurve = .continuous
        signUpButton.layer.borderWidth = 2.5
        signUpButton.layer.borderColor = CGColor(red: 255/255, green: 140/255, blue: 43/255, alpha: 1)
        
        continueAsGuestButton.titleLabel?.font = UIFont.montserratRegular(size: 16)
    }
    
    // MARK: Guest Button
    
    @IBAction func guestButton(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
    }
}
