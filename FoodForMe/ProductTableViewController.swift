// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import UIKit

class ProductTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // connect tableview from storyboard
    @IBOutlet weak var productTableView: UITableView!
    
    // stores all the products from openfoodfacts api into an array
    var products: [OpenFoodFactsAPI.Product] = [] // Stores fetched product data
    var isAlertShown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // checks to see if no alert is shown, if not then show the alert
        if !isAlertShown {
            isAlertShown = true
            showSearchAlert()
        }
    }

    // number of the row for table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    // displays the product name search and those closest to it in each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = product.name
        return cell
    }

    // shows alert to get user to enter in product they want
    func showSearchAlert() {
        // describes alert details
        let alert = UIAlertController(title: "Search Products", message: "Enter the name of the product you want to search for:", preferredStyle: .alert)
        // example of a product to enter
        alert.addTextField { textField in
            textField.placeholder = "e.g., Goldfish"
        }
        // creats alert action and makes sure whatever the user types in is a valid product name
        let searchAction = UIAlertAction(title: "Search", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let searchText = alert.textFields?.first?.text, !searchText.isEmpty {
                self.fetchProducts(searchText: searchText)
            } else {
                self.showErrorAlert(message: "Please enter a valid product name.")
            }
        }
        // cancel button in alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(searchAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    // grabs the products from the openfoodfacts api
    func fetchProducts(searchText: String) {
        // searches products based on keywords of the user input in the api
        OpenFoodFactsAPI.searchProducts(keywords: searchText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    // if product list is empty, show alert for no product found
                    if products.isEmpty {
                        self.showErrorAlert(message: "No products found for '\(searchText)'. Please try another search.")
                    } else {
                        // show the products
                        self.products = products
                        self.productTableView.reloadData()
                    }
                // in case of failure show an error message
                case .failure(let error):
                    self.showErrorAlert(message: "Could not fetch products. Please try again.")
                }
            }
        }
    }

    // error alert message for when there is an error with fetching the api products
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if the next view controller is to be called, send off the information from the row the user selected
        if segue.identifier == "ProductInfoIdentifier",
           let destination = segue.destination as? ProductInformationViewController,
           let indexPath = productTableView.indexPathForSelectedRow {
            let selectedProduct = products[indexPath.row]
            destination.productNameText = selectedProduct.name
            destination.allergenList = selectedProduct.allergens
        }
    }
}
