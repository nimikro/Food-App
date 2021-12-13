//
//  CategoryTableViewController.swift
//  FoodApp
//
//  Created by Panagiota on 30/11/21.
//

import UIKit




class CategoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let options = ["Biscuits and cookies", "Bread", "Cereals", "Condiments and sauces", "Desserts", "Drinks", "Main course", "Panacake", "Preps", "Preserve", "Salad"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
        return options.count
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
        return 1
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CellCategory

        cell.CategoryLabel.text = options[indexPath.row]

        return cell

    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }

//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

//    }
    
}
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

