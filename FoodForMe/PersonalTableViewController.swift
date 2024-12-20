// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import UIKit

// array to determine what the rows of the tableview will be
public let tableitems = ["My Allergies", "Calendar", "Settings"]

class PersonalTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // outlet for tableview
    @IBOutlet weak var personalTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personalTableView.delegate = self
        personalTableView.dataSource = self
    }
    
    // tableview has number of rows as tableItems
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableitems.count
    }

    // the text of each row is each item in tableitems
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = personalTableView.dequeueReusableCell(withIdentifier: "PersonalCell", for: indexPath)
        cell.textLabel?.text = tableitems[indexPath.row]
        return cell
    }
    
    // for each row that is selected, perform the segue necessary
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = tableitems[indexPath.row]
        if selectedItem == "Settings" {
            performSegue(withIdentifier: "SettingsIdentifier", sender: self)
        } else if selectedItem == "My Allergies" {
            performSegue(withIdentifier: "AllergiesIdentifier", sender: self)
        } else if selectedItem == "Calendar" {
            performSegue(withIdentifier: "TableToCalendarIdentifier", sender: self)
        }
    }
}
