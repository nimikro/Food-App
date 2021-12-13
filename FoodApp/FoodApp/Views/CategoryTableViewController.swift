//
//  CategoryTableViewController.swift
//  FoodApp
//
//  Created by Panagiota on 30/11/21.
//

import UIKit

class CategoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let options = ["BISCUITS AND COOKIES", "BREAD", "CEREALS", "CONDIMENTS AND SAUCES", "DESSERTS", "DRINKS", "MAIN COURSE", "PANCAKE", "PREPS", "PRESERVE", "SALAD", "SANDWICHES", "SIDE DISH", "SOUP", "STARTER", "SWEETS"]
    
    private var index: Int?
    
    @IBOutlet weak var customTableView: UITableView!
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "CATEGORIES"
        self.view.backgroundColor = .offWhite
        customTableView.delegate = self
        customTableView.dataSource = self
    }
    
    // MARK: Prepare for segue
    
    // segue to next controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategorySegue" {
            let nextVC = segue.destination as! CategoryViewController
            // if segue is correct, transfer category label to nextVC
            guard let index = index else { return }
            nextVC.typeSearched = options[index]
        }
    }
    
    // MARK: Table functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = customTableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        cell.categoryCell.text = options[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // the category we select is at index
        index = indexPath.row
        // go to category VC
        performSegue(withIdentifier: "CategorySegue", sender: nil)
    }
}
