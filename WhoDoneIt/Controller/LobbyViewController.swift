import UIKit
import CoreData



class lobbyViewController: ViewController {
    
    /* when view appears check constantly if game has started by fetching data from model */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do{
            let items = try playerCoreData.fetch(ClientData.fetchRequest())
            let clientData = items[0]
        /* while the game has not started keep checking if the game is still connected*/
       while clientData.gamestarted == false {
           if clientData.disconnectdata == true{
               performSegue(withIdentifier: "failedconnection", sender: nil)
               break
           }
       }
            /* if the client has not disconnect and game has started the move them to gameplay view*/
            if clientData.disconnectdata == false{
                self.performSegue(withIdentifier: "gamestartedclient", sender: nil)}
        }catch{}

    
}
    
    
    
}
