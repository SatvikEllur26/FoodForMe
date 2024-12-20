// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    // connected outlets from storyboard
    @IBOutlet weak var statusLabel1: UILabel!
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // status label is empty at the beginning
        self.statusLabel1.text = ""
        // to dismiss the keyboard anytime tapped outside of screen
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // when login button is pressed, makes sure the user is correctly logged in and is in firebase
    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: userIDTextField.text!, password: passwordTextField.text!) {
            (authResult,error) in
            // if there is an error with signing in then displays the error in the status label
            if let error = error as NSError? {
                self.statusLabel1.text = "\(error.localizedDescription)"
            } else {
                // make the status text empty and segue to the main vc
                self.statusLabel1.text = ""
                self.performSegue(withIdentifier: "LoginIdentifier", sender: nil)
            }
        }
    }
    
    // segue to the create account screen
    @IBAction func createAccountPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "NewAccountIdentifier", sender: nil)
    }
    
    // function to dismiss keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
