// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import Foundation
import UIKit

class CalendarCell: UICollectionViewCell {
    
    // outlet for day label
    @IBOutlet weak var dayLabel: UILabel!
    
    override func awakeFromNib() {
        // calls objects that are being archived in nib files
        super.awakeFromNib()
        // sets the text color to black
        dayLabel.textColor = .black
    }
}
