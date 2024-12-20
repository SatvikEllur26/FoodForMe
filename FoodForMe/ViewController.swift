// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {
    // connected all the storyboard elements needed
    @IBOutlet weak var barcodeButton: UIButton!
    @IBOutlet weak var productButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    // initiate firestore database
    let db = Firestore.firestore()
    var currentUserID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // checks if the user is logged in
        if let user = Auth.auth().currentUser {
            currentUserID = user.uid
        } else {
            print("No user is logged in.")
        }
    }

    // sign out of the application
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true)
        } catch {
            print("Sign out error")
        }
    }
    
    // segue for barcode button
    @IBAction func barcodePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "BarcodeIdentifier", sender: nil)
    }
    
    // segue for search product button
    @IBAction func searchProductPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "SearchProductIdentifier", sender: nil)
    }
    
    // segue for profile button
    @IBAction func profileButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ProfileIdentifier", sender: nil)
    }
}
