
import UIKit
import CoreData

class ViewController2: ViewController {
    @IBOutlet weak var playerCount: UILabel!
    @IBOutlet weak var ipAddlbl: UILabel!
    @IBOutlet weak var minplayerstxt: UILabel!
    var playerC: String? = ""
    
    /* if cancel server is pressed then return home and update data that game is closed - to allow the model to know to shut the server */
    @IBAction func returnHome(_ sender: Any) {
        let items = try? playerCoreData.fetch(Player.fetchRequest())
        let playerData = items![0]
        playerData.home = true
        try? playerCoreData.save()
        sleep(1)

    }
    
    
    /* When refresh player count button is pressed, fetch data and update the view with amount of players*/
    @IBAction func refreshPlayerCount(_ sender: Any) {
        do{
           let items = try playerCoreData.fetch(Player.fetchRequest())
            for i in items{
                playerC = String(i.playercount)
                    playerCount.text = ("\(playerC ?? "1")/8 Players")
            }
        }catch{
        }
        
    }
    
    /* when view loads display screen idling and update ip text with player ip */
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        if sharedFunctions().getIpAddress() != nil {
            ipAddlbl.text = (sharedFunctions().getIpAddress())
        }

    }
    
    /* when player starts game refresh player count and update view depending on how many players there are */
    @IBAction func gameStart(_ sender: Any) {
     
        refreshPlayerCount(0)
        
       
        let items = try? playerCoreData.fetch(Player.fetchRequest())
            let playerData = items![0]
          
      
        /* if 0 players show server failed to start*/
        if playerCount.text == "0/8 Players" {
            self.performSegue(withIdentifier: "failed", sender: nil)
            playerData.gamestarted = true
        /* if 3-8 players update view to start game*/

        }else if playerData.playercount > 2 && playerData.playercount < 9 {
            self.performSegue(withIdentifier: "servertrue", sender: nil)
            playerData.gamestarted = true
        /* show there needs to be at least 3-8 players*/
        }else{
            minplayerstxt.isHidden = false
        }
        
        
        
    }
        
        /* when view appears, call client game loop, then check if the connection was sucessful
         to know if the server is working*/
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* call of client setup and connection */
        Client().defaultInfo()
        Client().startGameLoop(ip: sharedFunctions().getIpAddress()!)

        sleep(1)
        /* refresh player count and if there are no players display server failed. */
        refreshPlayerCount(0)
        if playerCount.text == "0/8 Players" {
            self.performSegue(withIdentifier: "failed", sender: nil)

        }}

    
    
}

    
