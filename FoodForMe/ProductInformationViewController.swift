// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProductInformationViewController: UIViewController {

    // connected all the outlets from storyboard
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var allergenInfo: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    // variable for product name text
    var productNameText: String?
    // array of all the allergens in the product
    var allergenList: [String] = []
    // constant for firestore database
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // set product name
        self.productName.text = productNameText
        // clean the allergen list and make it look readable to user
        let cleanedAllergens = allergenList.map { $0.replacingOccurrences(of: "en:", with: "") }
        // if the allergen info is empty, write label as no allergens reported, otherwise list the allergens
        allergenInfo.text = cleanedAllergens.isEmpty
            ? "No allergens reported."
            : cleanedAllergens.joined(separator: "\n")
        // get the allergies from Firestore
        fetchAllergies { [weak self] userAllergies in
            guard let self = self else { return }
            self.checkForConflicts(cleanedAllergens, userAllergies: userAllergies)
        }
    }

    // function to get all the allergies from firestore
    func fetchAllergies(completion: @escaping ([String: Bool]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            completion([:])
            return
        }
        // gets the listed allergies of the user from firestore
        db.collection("users").document(userID).getDocument { document, error in
            // if there is an error, print the error
            if let error = error {
                print("Error fetching allergies: \(error.localizedDescription)")
                completion([:])
                return
            }
            // if the allergies are there add the allergies to the array parameter
            if let data = document?.data(), let allergies = data["allergies"] as? [String: Bool] {
                completion(allergies)
            } else {
                completion([:])
            }
        }
    }

    // checks if the user's allergies laps with the allergies from the product
    func checkForConflicts(_ cleanedAllergens: [String], userAllergies: [String: Bool]) {
        // converts the user allergies to lowercase
        let normalizedAllergies = userAllergies.reduce(into: [String: Bool]()) { result, pair in
            result[pair.key.lowercased()] = pair.value
        }
        // converts the products allergens to lowercase
        let normalizedAllergens = cleanedAllergens.map { $0.lowercased() }
        // finds allergens in the product that conflict with user allergies
        let conflictingAllergens = normalizedAllergens.filter { allergen in
            normalizedAllergies[allergen] == true
        }
        // update the result label based on conflicts
        if conflictingAllergens.isEmpty {
            resultLabel.text = "You can eat this product."
            resultLabel.textColor = .systemGreen
        } else {
            resultLabel.text = "Contains allergens. Do not consume."
            resultLabel.textColor = .systemRed
        }
    }
    
    // go to calendar view controller when it button is pressed
    @IBAction func calendarPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ProductToCalendarIdentifier", sender: nil)
    }
}
