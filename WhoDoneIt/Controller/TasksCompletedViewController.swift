import UIKit
import SwiftSocket
import Foundation
import CoreData


class TasksViewController: ViewController {
    
    
    @IBOutlet weak var alivetxt: UILabel!
    @IBOutlet weak var deadpng: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        while true {
        let items = try? playerCoreData.fetch(ClientData.fetchRequest())
        let clientData = items![0]
        if (clientData.gamefinished == true)
        {
            performSegue(withIdentifier: "gamefinished", sender: nil)
            break
        }
        if (clientData.dead == true) {
                alivetxt.isHidden = true
                deadpng.isHidden = false
        }
            
            
            
        }

    }
}
