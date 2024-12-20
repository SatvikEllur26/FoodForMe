// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AllergiesViewController: UIViewController {

    // connect outlets for each toggle for each allergy
    @IBOutlet weak var nutsToggle: UISwitch!
    @IBOutlet weak var milkToggle: UISwitch!
    @IBOutlet weak var glutenToggle: UISwitch!
    @IBOutlet weak var soybeanToggle: UISwitch!
    @IBOutlet weak var eggToggle: UISwitch!
    @IBOutlet weak var fishToggle: UISwitch!
    @IBOutlet weak var peanutsToggle: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // get allergies from the database and update toggles
        loadAllergiesFromDatabase()
    }
    
    // determines if the switches changed their value
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 0:
            print("Nuts switch toggled: \(sender.isOn)")
        case 1:
            print("Milk switch toggled: \(sender.isOn)")
        case 2:
            print("Gluten switch toggled: \(sender.isOn)")
        case 3:
            print("Soybean switch toggled: \(sender.isOn)")
        case 4:
            print("Egg switch toggled: \(sender.isOn)")
        case 5:
            print("Fish switch toggled: \(sender.isOn)")
        case 6:
            print("Peanuts switch toggled: \(sender.isOn)")
        default:
            break
        }
        // saves all the switches data to the firestore database
        saveAllergiesToDatabase()
    }
    
    // function to get all the allergies current states
    func getAllergiesSelection() -> [String: Bool] {
        return [
            "Nuts": nutsToggle.isOn,
            "Milk": milkToggle.isOn,
            "Gluten": glutenToggle.isOn,
            "Soybean": soybeanToggle.isOn,
            "Egg": eggToggle.isOn,
            "Fish": fishToggle.isOn,
            "Peanuts": peanutsToggle.isOn
        ]
    }
    
    // stores all the allergies to the database
    func saveAllergiesToDatabase() {
        // makes sure all the users are logged in before saving
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        // get all the switches current state
        let allergies = getAllergiesSelection()
        let db = Firestore.firestore()
        // stores the switches current state in firestore database
        db.collection("users").document(userID).setData(["allergies": allergies], merge: true) { error in
            if let error = error {
                print("Error saving allergies: \(error.localizedDescription)")
            } else {
                print("Allergies saved successfully!")
            }
        }
    }

    // gets the allergies from firestore
    func loadAllergiesFromDatabase() {
        // makes sure all the users are logged in before saving
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        
        let db = Firestore.firestore()
        // gets the data from the users data
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            // if error getting data, print error
            if let error = error {
                print("Error fetching allergies: \(error.localizedDescription)")
                return
            }
            // if the data is fetches, update the toggles with the allergy data
            if let data = document?.data(), let allergies = data["allergies"] as? [String: Bool] {
                print("Fetched allergies: \(allergies)")
                self.updateToggles(with: allergies)
            } else {
                print("No allergies found in the database.")
            }
        }
    }
    
    // updates each toggle based on the fetched data from database when the user enters the screen
    func updateToggles(with allergies: [String: Bool]) {
        nutsToggle.isOn = allergies["Nuts"] ?? false
        milkToggle.isOn = allergies["Milk"] ?? false
        glutenToggle.isOn = allergies["Gluten"] ?? false
        soybeanToggle.isOn = allergies["Soybean"] ?? false
        eggToggle.isOn = allergies["Egg"] ?? false
        fishToggle.isOn = allergies["Fish"] ?? false
        peanutsToggle.isOn = allergies["Peanuts"] ?? false
    }
}
