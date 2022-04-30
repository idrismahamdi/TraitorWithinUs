import UIKit
import SwiftSocket
import Foundation
import CoreData



class lobbyViewController: ViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do{
            let items = try playerCoreData.fetch(ClientData.fetchRequest())
            let clientData = items[0]
        

       while clientData.gamestarted == false {
           //check if still connected
           if clientData.disconnectdata == true{
               performSegue(withIdentifier: "failedconnection", sender: nil)
               break
           }
       }
            if clientData.disconnectdata == false{
                self.performSegue(withIdentifier: "gamestartedclient", sender: nil)}
        }catch{}

    
}
    
    
    
}
