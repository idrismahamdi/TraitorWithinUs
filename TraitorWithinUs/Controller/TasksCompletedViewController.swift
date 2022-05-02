import UIKit
import CoreData


class TasksViewController: ViewController {
    
    
    @IBOutlet weak var alivetxt: UILabel!
    @IBOutlet weak var deadpng: UIImageView!
    
    /* when view appears, loop until game is finished*/
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* keep looping until game is finished */
        while true {
        let items = try? playerCoreData.fetch(ClientData.fetchRequest())
        let clientData = items![0]
        /* when game is finished then move to game finished view*/
        if (clientData.gamefinished == true)
        {
            performSegue(withIdentifier: "gamefinished", sender: nil)
            break
        }
            
            
            
        }

    }
}
