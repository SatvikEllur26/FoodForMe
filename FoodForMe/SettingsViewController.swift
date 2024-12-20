// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E


import UIKit
import FirebaseFirestore
import FirebaseAuth
import Photos

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // outlets for all the storyboard components
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var cameraPreview: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    
    // variable to handle image being picked
    var imagePickerController = UIImagePickerController()
    let db = Firestore.firestore()
    var currentUserID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // checks permission for photo libaray
        checkPermissions()
        // camera profile picture appearance
        cameraPreview.layer.cornerRadius = cameraPreview.frame.size.width / 2
        cameraPreview.clipsToBounds = true
        cameraPreview.layer.borderWidth = 2.0
        cameraPreview.layer.borderColor = UIColor.gray.cgColor
        // makes sure user is logged in
        if let user = Auth.auth().currentUser {
            currentUserID = user.uid
            fetchUserData()
        } else {
            print("No user is logged in.")
        }
    }

    // edits the users first and last name
    @IBAction func editPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Edit Name", message: "Please enter your first and last name", preferredStyle: .alert)
        
        // adds fields for an alert to type in first and last name
        alert.addTextField { textField in
            textField.placeholder = "First Name"
            textField.text = self.firstNameLabel.text
        }
        alert.addTextField { textField in
            textField.placeholder = "Last Name"
            textField.text = self.lastNameLabel.text
        }
        // saves the updated name and prints the the two labels
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            let firstName = alert.textFields?[0].text ?? "No Name"
            let lastName = alert.textFields?[1].text ?? "No Name"
            
            self?.firstNameLabel.text = firstName
            self?.lastNameLabel.text = lastName
            // updates the users data with the updated names
            self?.updateUserData(firstName: firstName, lastName: lastName)
        }
        // adds actions to the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    // get the user data from firestore
    func fetchUserData() {
        guard let userID = currentUserID else {
            print("No user is logged in.")
            return
        }
        // gets the users data from firestore
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            // if the data is retrieived, update the interface with the users data
            if let document = document, document.exists {
                let data = document.data()
                self?.firstNameLabel.text = data?["firstName"] as? String ?? "No First Name"
                self?.lastNameLabel.text = data?["lastName"] as? String ?? "No Last Name"
                print("User data fetched successfully: \(String(describing: data))")
                // load the profile picture
                if let base64String = data?["profilePicture"] as? String {
                    self?.loadProfilePicture(from: base64String)
                }
            } else {
                print("User document does not exist.")
            }
        }
    }

    // update the user data in firestore
    func updateUserData(firstName: String, lastName: String) {
        guard let userID = currentUserID else {
            print("No user ID found.")
            return
        }
        // updates first and last name
        db.collection("users").document(userID).updateData([
            "firstName": firstName,
            "lastName": lastName
        ]) { error in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
            } else {
                print("User data successfully updated in Firestore.")
            }
        }
    }

    // opens the camera to take a paicture
    @IBAction func toggleCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    // method to selecting an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // sets the profile picture based on the source
        if picker.sourceType == .photoLibrary {
            cameraPreview?.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        } else {
            cameraPreview?.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
        // saves the profile picture to firestore
        if let selectedImage = cameraPreview?.image {
            saveProfilePicture(image: selectedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

    // opens the photo library to choose a picture
    @IBAction func tappedLibraryButton(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        self.imagePickerController.delegate = self
        self.present(self.imagePickerController, animated: true, completion: nil)
    }

    // saves the profile picture as base64 in firestore
    func saveProfilePicture(image: UIImage) {
        guard let currentUserID = currentUserID else {
            print("No user ID found.")
            return
        }

        // convert UIImage to Base64
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("Error converting image to data.")
            return
        }
        let base64String = imageData.base64EncodedString()
        print("Image converted to Base64.")

        // saves the converted image to a base64 string in Firestore
        db.collection("users").document(currentUserID).updateData(["profilePicture": base64String]) { error in
            if let error = error {
                print("Error saving profile picture to Firestore: \(error.localizedDescription)")
            } else {
                print("Profile picture saved successfully in Firestore.")
            }
        }
    }

    // load the profile picture from base64 string in firestore
    func loadProfilePicture(from base64String: String) {
        guard let imageData = Data(base64Encoded: base64String), let image = UIImage(data: imageData) else {
            print("Error decoding Base64 string to image.")
            return
        }
        DispatchQueue.main.async {
            self.cameraPreview.image = image
        }
    }

    // checks the photo library permissions
    func checkPermissions() {
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { _ in }
        }
    }
}
