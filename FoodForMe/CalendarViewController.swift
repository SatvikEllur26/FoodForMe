// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E


import UIKit
import FirebaseFirestore
import FirebaseAuth

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // outlets from storyboard
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var storedLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    
    // 31 days in december
    let daysInMonth = 31
    // dictionary to store food products for each dat
    var dailyValues: [Int: [String]] = [:]
    let db = Firestore.firestore()
    var userID: String?
    var selectedDay: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // makes sure the user is logged in
        if let user = Auth.auth().currentUser {
            userID = user.uid
            fetchDailyValues()
        } else {
            print("User not logged in!")
        }
        storedLabel.text = ""
        collectionView.dataSource = self
        collectionView.delegate = self
        // initially hide button
        storeButton.isHidden = true
        // load stored food items from Firestore
        fetchDailyValues()
    }
    
    // function to get the values stored for each day
    func fetchDailyValues() {
        guard let userID = userID else {
            print("User ID is nil. Cannot fetch daily values.")
            return
        }
        // gets the food storeed for each day from firestore
        db.collection("users").document(userID).collection("calendar").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching daily values: \(error.localizedDescription)")
                return
            }
            // clears local cache
            self.dailyValues = [:]
            // gets all the documents returned by the query as an array
            snapshot?.documents.forEach { document in
                // makes sure data exists and then retrieves it
                if let foods = document.data()["foods"] as? [String] {
                    let dayString = document.documentID
                    if let day = Int(dayString.suffix(2)) {
                        print("Fetched foods for day \(day): \(foods)")
                        // stores foods array in the dailyValues dictionary with the day as the key
                        self.dailyValues[day] = foods
                    }
                }
            }
            // reload the collection view to update the users screen
            self.collectionView.reloadData()
        }
    }

    // collection view has the number of items based on how many days in the month there are
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth
    }

    // sets each cell in the collection view with the number of the day
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! CalendarCell
        let day = indexPath.item + 1
        cell.dayLabel.text = "\(day)"
        return cell
    }

    // when the cell in collection view is selected, take the selected day and update the stored label
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = indexPath.item + 1
        selectedDay = day
        // update the storedLabel with the stored food
        updateStoredLabel(for: day)
        // show the storeButton
        storeButton.isHidden = false
    }

    // when the store button is tapped
    @IBAction func storeButtonTapped(_ sender: UIButton) {
        guard let day = selectedDay else { return }
        // shows an alert to input what the user ate
        let alert = UIAlertController(title: "Add Item", message: "Add what you ate on December \(day)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "E.g., Goldfish"
        }
        // the actions the user has on the alert
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let value = alert.textFields?.first?.text, !value.isEmpty else { return }
            // add the new value to the local dictionary
            if self.dailyValues[day] != nil {
                self.dailyValues[day]?.append(value)
            } else {
                self.dailyValues[day] = [value]
            }
            // save to firestore
            self.saveDailyValueToFirestore(day: day, values: self.dailyValues[day] ?? [])
            // update the storedLabel
            self.updateStoredLabel(for: day)
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }

    // save data to firestore
    func saveDailyValueToFirestore(day: Int, values: [String]) {
        guard let userID = userID else { return }
        db.collection("users").document(userID).collection("calendar").document(String(format: "2024-12-%02d", day)).setData(["foods": values])
    }

    // update the stored label
    func updateStoredLabel(for day: Int) {
        if let values = dailyValues[day], !values.isEmpty {
            storedLabel.text = "December \(day): \(values.joined(separator: ", ")) \n"
        } else {
            storedLabel.text = "December \(day): None"
        }
    }
}
