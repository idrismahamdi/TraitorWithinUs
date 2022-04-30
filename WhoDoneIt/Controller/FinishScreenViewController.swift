import UIKit
import SwiftSocket
import Foundation
import CoreData



class finishViewController: ViewController {

    @IBOutlet weak var winnerlbl: UILabel!
    @IBOutlet weak var finishimage: UIImageView!
    
    /* when the view loads dsiplay the result of the game*/
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        let items = try? playerCoreData.fetch(ClientData.fetchRequest())
        let clientData = items![0]
        
        if (clientData.disconnectdata == true){
            winnerlbl.text = "Issues with the connection to the server... Please check your WiFi status"

        }else if (clientData.didcrewwin == true){
            winnerlbl.text = "The Crewmembers have completed all of their tasks and have won the game"
            finishimage.isHidden = false
        } else {
            winnerlbl.text = "The Traitor has killed all Crewmembers and has won the game"
            finishimage.isHidden = false

        }
    
    }
    
    
}
