//
//  ViewController.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 23/11/21.
//

import UIKit
import SafariServices
import NVActivityIndicatorView

// MARK: Data and search functions
// shows home screen
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITableViewDataSourcePrefetching {
    
    private let searchVC = UISearchController(searchResultsController: nil)
    private let scrollToTopButton = UIButton(type: .custom)
    private var viewModels = [FoodTableViewCellViewModel]()
    private var index : Int?
    private var totalNumber : Int?
    private var goingForwards = false
    private var query: String? {
        didSet {
            tableView.isHidden = true
            indicatorView.startAnimating()
            viewModels.removeAll()
        }
    }
    
    private var urlConst: String = ""
    private var isFetchInProgress : Bool = false
    private let indicatorView: NVActivityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: 190, y: 200, width: 40, height: 40),
        type: NVActivityIndicatorType.ballClipRotate,
        color: .black,
        padding: 0.5
    )
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        // setup the view
        super.viewDidLoad()
        self.navigationItem.title = "FLAVOR"
        view.addSubview(tableView)
        view.addSubview(indicatorView)
        
        // create scroll to top button
        scrollToTopButton.frame = CGRect(x: 350, y: 770, width: 40, height: 40)
        scrollToTopButton.layer.cornerRadius = 0.5 * scrollToTopButton.bounds.size.width
        scrollToTopButton.clipsToBounds = true
        scrollToTopButton.setBackgroundImage(UIImage(named: "scrollToTopButton"), for: .normal)
        scrollToTopButton.backgroundColor = .white
        scrollToTopButton.addTarget(self, action: #selector(scrollToTopButtonPressed), for: .touchUpInside)
        view.addSubview(scrollToTopButton)
        
        // hide navigation contoller when scrolling
        self.navigationController?.hidesBarsOnSwipe = true
        
        indicatorView.startAnimating()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.separatorStyle = .none
        
        createSearchBar()
        query = "Christmas"
        // Default search when launching app
        getData(query!, checkIfConst: false, urlConst: "")
    }
    
    // MARK: ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: ViewDidAppear
    // reload cell selected to show updated heart
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if goingForwards == true {
            goingForwards = false
            guard let index = index else {
                return
            }
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    // MARK: Scroll Button + Search Bar
    
    @objc func scrollToTopButtonPressed() {
        UIButton.animate(withDuration: 0.5) {
            self.scrollToTopButton.backgroundColor = .systemOrange
            self.scrollToTopButton.backgroundColor = .white
        }
        let topRow = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: topRow,at: .top, animated: true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    // show the search bar as a navigation bar item
    private func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }
    
    // when the search button is clicked, perform an API call
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // make sure text is not empty
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        // trim white spaces and new lines in input text
        query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Fill the viewModels with data
        getData(query!, checkIfConst: false, urlConst: "")
        // test lines
    }
    
    // MARK: Data Network Call
    
    // use the API caller to tranfer data into the cell view model
    func getData(_ query: String, checkIfConst: Bool, urlConst: String) {
        // if a fetch request is already in progress bail out (prevents multiple requests from happening)
        guard !isFetchInProgress else {
            return
        }
        // if a fetch request is not in progress, send the request in
        isFetchInProgress = true
        
        APICaller.shared.getRecipes(searchTerm: query, type: "", hasType: false,
                                    const: checkIfConst, urlConst: urlConst) { [weak self] result in
            switch result {
                // if the request is successful append the new item (20 recipes per response) in the viewModels array
            case.success(let response):
                DispatchQueue.main.async { [self] in
                    self?.isFetchInProgress = false
                    self?.urlConst = response._links.next?.href ?? ""
                    self?.viewModels += response.hits.compactMap({
                        FoodTableViewCellViewModel(
                            uri: $0.recipe.uri,
                            title: $0.recipe.label,
                            subtitle: $0.recipe.dishType?[0] ?? "no dish type",
                            imageURL: URL(string: $0.recipe.image),
                            time: $0.recipe.totalTime == 0 ? 30 : $0.recipe.totalTime ?? 30,
                            calories: $0.recipe.calories,
                            servings: $0.recipe.yield,
                            ingredients: $0.recipe.ingredientLines,
                            recipeURL: $0.recipe.url,
                            shareAs: $0.recipe.shareAs,
                            isFavorite: false
                        )
                    })
                    // if this isn't the first page calculate the indexPaths to update the table view
                    // else store the totalNumber of recipes to create cell rows (only gets called once)
                    if response.from > 1 {
                        let indexPathsToReload = self?.calculateIndexPathsToReload(from: response.hits)
                        self?.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self?.totalNumber = response.count
                        self?.onFetchCompleted(with: .none)
                    }
                }
                // if the request fails, show an error
            case.failure(let error):
                DispatchQueue.main.async {
                    self?.isFetchInProgress = false
                    self?.indicatorView.stopAnimating()
                    print(error)
                }
            }
        }
    }
    
    // MARK: Table helper functions
    
    // calculate the index paths for the last page of viewModels received
    // this path will be used to refresh only the changed content instead of reloading the full table
    private func calculateIndexPathsToReload(from newViewModels: [RecipeLinks]) -> [IndexPath] {
        let startIndex = viewModels.count - newViewModels.count
        let endIndex = startIndex + newViewModels.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    // determine if cell at indexPath is beyond the count of viewModels
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModels.count
    }
    
    // calculate the cells that need to be reloaded (without reloading the cells that are not currently visible)
    private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) ->  [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    // if newIndexPathsToReload is nil (first page) hide the indicator, make the table view visible and reload it
    // else (next pages) find the visible cells than need reloading and let the table reload only them
    private func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            indicatorView.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    // MARK: Prepare for segue
    
    // segue to next controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecipeDetails" {
            let nextVC = segue.destination as! RecipeDetails
            // if segue is correct transfer recipe details to nextVC
            guard let index = index else { return }
            nextVC.recipeDetails.append(viewModels[index])
        }
    }
    
    // MARK: Table functions
    
    // Table frame equal to the entire view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // anonymous closure pattern for table
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(FoodTableViewCell.self, forCellReuseIdentifier: FoodTableViewCell.identifier)
        return table
    }()
    
    // number of table rows is equal to the total number of recipes we will receive (even if the table is not full yet)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalNumber ?? viewModels.count
    }
    
    // create a cell and configure it using the FoodTableViewCell class
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodTableViewCell.identifier, for: indexPath) as? FoodTableViewCell else {
            fatalError()
        }
        // if the cell hasn't received a view model, configure it with an empty value (show spinning indicator)
        // else pass the viewModel in the cell
        if isLoadingCell(for: indexPath) {
            cell.configure(with: .none)
        }
        else {
            cell.configure(with: viewModels[indexPath.row])
        }
        
        return cell
    }
    
    // when selecting a recipe, transfer user to recipe details
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // the recipe we select is at index
        index = indexPath.row
        // go to custom details page
        goingForwards = true
        performSegue(withIdentifier: "RecipeDetails", sender: nil)
    }
    
    // cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 550
    }
    
    // check if any index paths are not loaded yet and then fetch next page of data
    // using the isFetchInProgress Bool this function can be called multiple times
    // however it will be ignored until the request is finished
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            getData(query!, checkIfConst: true, urlConst: urlConst)
        }
    }
}

