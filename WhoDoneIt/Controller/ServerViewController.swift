
import UIKit
import SwiftSocket
import Foundation
import CoreData

class ViewController2: ViewController {
    @IBOutlet weak var playerCount: UILabel!
    @IBOutlet weak var ipAddlbl: UILabel!
    @IBOutlet weak var minplayerstxt: UILabel!
    var test: String? = ""
    
    
    @IBAction func returnHome(_ sender: Any) {
        let items = try? playerCoreData.fetch(Player.fetchRequest())
        let playerData = items![0]
        playerData.home = true
        try? playerCoreData.save()
        sleep(1)

    }
    
    
    
    @IBAction func refreshPlayerCount(_ sender: Any) {
        do{
           let items = try playerCoreData.fetch(Player.fetchRequest())
            for i in items{
                test = String(i.playercount)
                    playerCount.text = ("\(test ?? "1")/8 Players")
            }
        }catch{
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        if sharedFunctions().getIpAddress() != nil {
            ipAddlbl.text = (sharedFunctions().getIpAddress())
        }

    }
    
    @IBAction func gameStart(_ sender: Any) {
     
        refreshPlayerCount(0)
        
       
        let items = try? playerCoreData.fetch(Player.fetchRequest())
            let playerData = items![0]
          
      
        
        if playerCount.text == "0/8 Players" {
            self.performSegue(withIdentifier: "failed", sender: nil)
            playerData.gamestarted = true

        }else if playerData.playercount > 2 && playerData.playercount < 9 {
            self.performSegue(withIdentifier: "servertrue", sender: nil)
            playerData.gamestarted = true

        }else{
            minplayerstxt.isHidden = false
        }
        
        
        
    }
        
        
    
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Client().defaultInfo()
        Client().startGameLoop(ip: sharedFunctions().getIpAddress()!)

        sleep(1)
        refreshPlayerCount(0)
        if playerCount.text == "0/10 Players" {
            self.performSegue(withIdentifier: "failed", sender: nil)

        }}

    
    
}

    
