// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    // connected outlets from storyboard
    @IBOutlet weak var statusLabel2: UILabel!
    @IBOutlet weak var newUserIDTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // status label is empty in the beginning
        self.statusLabel2.text = ""
        // to dismiss keyboard when tapped outside of the screen
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // creates a new user in firebase and gives default values in firestore
    @IBAction func createPressed(_ sender: Any) {
        // creates a new user in firebase authentication
        Auth.auth().createUser(withEmail: newUserIDTextField.text!, password: newPasswordTextField.text!) { (authResult, error) in
            if let error = error as NSError? {
                // if error with creating a user, status label will show the error
                self.statusLabel2.text = "\(error.localizedDescription)"
                return
            }
            // creates document in firestore for each user with specific values
            if let user = authResult?.user {
                // sets variable for first and last name
                let firstName = "None"
                let lastName = "None"
                let db = Firestore.firestore()
                
                // stores profile picture
                // this is a default profile when user is first created
                let defaultImage = UIImage(systemName: "person.crop.circle.fill")
                let base64Placeholder: String
                // compress data the profile pic selected into jpeg
                if let imageData = defaultImage?.jpegData(compressionQuality: 0.75) {
                    // converts the jpeg into base64 string
                    base64Placeholder = imageData.base64EncodedString()
                } else {
                    // if conversion fails then set to empty string
                    base64Placeholder = ""
                }
                // sets the users data in a document in firestore
                db.collection("users").document(user.uid).setData([
                    "email": user.email ?? "",
                    "firstName": firstName,
                    "lastName": lastName,
                    "profilePicture": base64Placeholder,
                    "allergies": [
                        "Nuts": false,
                        "Milk": false,
                        "Gluten": false,
                        "Soybean": false,
                        "Egg": false,
                        "Fish": false,
                        "Peanuts": false
                    ]
                ]) { error in
                    if let error = error {
                        self.statusLabel2.text = "Error saving user data: \(error.localizedDescription)"
                    } else {
                        for day in 1...31 {
                            let date = String(format: "2024-12-%02d", day)
                            db.collection("users")
                                .document(user.uid)
                                .collection("calendar")
                                .document(String(format: "2024-12-%02d", day))
                                .setData([
                                    "foods": [] // Start with an empty list of foods
                                ]) { error in
                                    if let error = error {
                                        print("Error creating calendar document for \(date): \(error.localizedDescription)")
                                    } else {
                                        print("Initialized calendar for \(date)")
                                    }
                                }
                        }
                        // status label is empty
                        self.statusLabel2.text = ""
                        // perform segue to go to main vc
                        self.performSegue(withIdentifier: "CreateAccountIdentifier", sender: nil)
                    }
                }
            }
        }
    }

    // function to dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
