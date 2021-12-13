//
//  RecipeDetailsViewController.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 28/11/21.
//

import UIKit
import SafariServices

// connects to RecipeDetailsViewController on Main storyboard. Shows details for each recipe clicked
class RecipeDetails: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var darkImage: UIImageView!
    @IBOutlet weak var recipeType: UILabel!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var ingredientsTitleLabel: UILabel!
    @IBOutlet weak var instructionsButton: UIButton!
    @IBOutlet weak var shareLink: UIButton!
    @IBOutlet weak var ingredientsTable: UITableView!
    
    var recipeDetails: [FoodTableViewCellViewModel] = []
    let gradientLayer = CAGradientLayer()
    private var users = [Users]()
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // custom back button
        let backbutton = UIBarButtonItem(image: UIImage(named: "ic_arrow_back"), style: .plain, target: navigationController, action: #selector(UINavigationController.popViewController(animated:)))
        backbutton.tintColor = .white
        navigationItem.leftBarButtonItem = backbutton
        
        // favorite button
        let favoriteButton = UIBarButtonItem(image: UIImage(named: "like"), style: .plain, target: self, action: #selector(makeFavorite))
        favoriteButton.tintColor = .white
        
        navigationItem.rightBarButtonItem = favoriteButton
        
        self.navigationController?.isNavigationBarHidden = false
        
        let logInState = Users.currentUser.isLoggedIn
        
        // retrieve all users stored in User defaults
        if let data = UserDefaults.standard.data(forKey: "users") {
            do {
                users = try JSONDecoder().decode([Users].self, from: data)
            }
            catch {
                print("Unable to decode saved users (\(error))")
            }
        }
        
        // if user is logged in the makeFavorite button exists
        if logInState {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        // if user in NOT logged in the makeFavorite button disappears
        else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        // fill labels and image
        ingredientsTable.dataSource = self
        ingredientsTable.delegate = self
        recipeTitle.text = recipeDetails[0].title
        recipeImage.image = UIImage(data: recipeDetails[0].imageData!)
        darkImage.backgroundColor = .black
        darkImage.layer.opacity = 0.25
        recipeType.text = recipeDetails[0].subtitle.uppercased()
        timeLabel.text = String(Int(recipeDetails[0].time)) + " minutes"
        caloriesLabel.text = String(Int(recipeDetails[0].calories)/(recipeDetails[0].servings))
        servingsLabel.text = String(recipeDetails[0].servings) + " people"
        ingredientsTitleLabel.text = "INGREDIENTS"
        ingredientsTable.reloadData()
        
        // define gradient
        let color1 = UIColor(red: 222/255, green: 187/255, blue: 151/255, alpha: 0.2).cgColor
        let color2 = UIColor(red: 222/255, green: 203/255, blue: 151/255, alpha: 0.2).cgColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0, 1]
        
        // add gradient
        self.view.layer.addSublayer(gradientLayer)
        
        // icons
        let clockView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        clockView.image = UIImage(named: "time_icon")
        clockView.contentMode = .scaleAspectFill
        clockView.translatesAutoresizingMaskIntoConstraints = false
        let calorieView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        calorieView.image = UIImage(named: "calories_icon")
        calorieView.translatesAutoresizingMaskIntoConstraints = false
        calorieView.contentMode = .scaleAspectFill
        calorieView.tintColor = .customGray
        let servingsView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        servingsView.image = UIImage(named: "servings_icon")
        servingsView.contentMode = .scaleAspectFill
        servingsView.translatesAutoresizingMaskIntoConstraints = false
        
        caloriesLabel.addSubview(calorieView)
        calorieView.centerYAnchor.constraint(equalTo: caloriesLabel.centerYAnchor, constant: 0).isActive = true
        calorieView.rightAnchor.constraint(equalTo: caloriesLabel.leftAnchor, constant: 34).isActive = true
        timeLabel.addSubview(clockView)
        clockView.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor, constant: 0).isActive = true
        clockView.rightAnchor.constraint(equalTo: timeLabel.leftAnchor, constant: -5).isActive = true
        servingsLabel.addSubview(servingsView)
        servingsView.centerYAnchor.constraint(equalTo: servingsLabel.centerYAnchor, constant: 0).isActive = true
        servingsView.rightAnchor.constraint(equalTo: servingsLabel.leftAnchor, constant: 10).isActive = true
        
    }
    
    // MARK: ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // make favorite persist:
        // every time we enter the details page, we must check if the item exists in favorites array
        // and change the heart color accordingly
        if containsElement(element: recipeDetails[0], array: Users.currentUser.savedRecipes) {
            self.navigationItem.rightBarButtonItem?.tintColor = .red
        }
        else {
            self.navigationItem.rightBarButtonItem?.tintColor = .white
        }
    }
    
    // MARK: ViewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: MakeFavorite Button
    
    // triggers when we tap on the heart icon
    @objc func makeFavorite() {
        // changes heart icon and isFavorite bool in recipe
        changeFavoriteState()
        // if the recipe is favorite, get the favorites array from User defaults, add the item to the array
        // and save the new array back to User defaults
        if recipeDetails[0].isFavorite &&  !containsElement(element: recipeDetails[0], array: Users.currentUser.savedRecipes) {
            Users.currentUser.savedRecipes.append(recipeDetails[0])
            let userIndex = Users.currentUser.index
            users[userIndex].savedRecipes = Users.currentUser.savedRecipes
                do {
                    let data = try JSONEncoder().encode(users)
                    UserDefaults.standard.set(data, forKey: "users")
                    UserDefaults.standard.synchronize()
                }
                catch {
                    print("Unable to encode (\(error))")
                }
            
        }
        // if the recipe is not a favorite, get the favorites array from User defaults, remove the item from the array
        // and save the new array back to User defaults
        else {
            Users.currentUser.savedRecipes.remove(at: indexElement(element: recipeDetails[0], array: Users.currentUser.savedRecipes))
            let userIndex = Users.currentUser.index
            users[userIndex].savedRecipes = Users.currentUser.savedRecipes
            do {
                let data = try JSONEncoder().encode(users)
                UserDefaults.standard.set(data, forKey: "users")
                UserDefaults.standard.synchronize()
            }
            catch {
                print("Unable to encode (\(error))")
            }
        }
    }
    
    func indexElement(element: FoodTableViewCellViewModel, array: [FoodTableViewCellViewModel]) -> Int {
        return array.firstIndex(where: { $0.uri == element.uri } ) ?? 0
    }
    
    func containsElement(element: FoodTableViewCellViewModel, array: [FoodTableViewCellViewModel]) -> Bool {
        return array.contains(where: { $0.uri == element.uri } )
    }
    
    func changeFavoriteState() {
        let hasFavorite = recipeDetails[0].isFavorite
        recipeDetails[0].isFavorite = !hasFavorite
        self.navigationItem.rightBarButtonItem?.tintColor = recipeDetails[0].isFavorite ? UIColor.red : .white
    }
    
    // MARK: Table functions
    
    // table view shows ingredient list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeDetails[0].ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as! IngredientCell
        // show image and a single ingredient for each cell
        cell.ingredientIcon.image = UIImage(named: "ic_circle")
        cell.ingredientLabel.text = recipeDetails[0].ingredients[indexPath.row]
        
        return cell
    }
    
    // MARK: View Instructions Button
    
    // when hitting the "View instructions" button go to the recipe website
    @IBAction func viewInstructions(_ sender: UIButton) {
        
        let recipeWebsitePath = recipeDetails[0].recipeURL
        
        guard let url = URL(string: recipeWebsitePath) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    // MARK: Share Recipe Button
    
    // when hitting the "Share this recipe" button, show toolbar for sharing
    @IBAction func shareRecipe(_ sender: UIButton) {
        let text = recipeTitle.text
        let image = recipeImage
        let myWebsite = "\nShare this recipe at: \(recipeDetails[0].recipeURL)"
        let shareAll = [text! , image! , myWebsite] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
