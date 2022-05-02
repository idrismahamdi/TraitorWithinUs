import UIKit
import CoreData


class gameViewController: ViewController {
    
    
    @IBOutlet weak var playertagtxt: UITextView!
    @IBOutlet weak var exampleimg: UIImageView!
    @IBOutlet weak var taskexampleimg: UIImageView!
    @IBOutlet weak var killplayerimg: UIImageView!
    @IBOutlet weak var instruct2txt: UITextView!
    @IBOutlet weak var instruct1txt: UITextView!
    @IBOutlet weak var assingmenttxt: UILabel!
    @IBOutlet weak var playernumbertxt: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var confirmbtn: UIButton!
    
    /* when view appears */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        sleep(1)
  
        /* display to view by fetching the data if the player was assinged traitor or crewmemeber along with relevant instructions*/
        do{
            let items = try playerCoreData.fetch(ClientData.fetchRequest())
            let clientData = items[0]

            
            if (clientData.traitor == true) {
                assingmenttxt.text = "You have been assigned as a traitor"
                killplayerimg.isHidden = false
            }else{
                assingmenttxt.text = "You have been assigned as a crewmember"
                instruct1txt.text = "To win you and the other Crew Memebers must complete all of your own tasks before the Traitor kills you all"
                instruct1txt.text = "Look at your task at the top of your screen, when item is found point your camera at it to move on"
                taskexampleimg.isHidden = false

            }
            /*unhide all of the information to do with the data the player was assinged with*/
            
            playernumbertxt.text = ("You are player number: \(clientData.playernumber)")
            loading.stopAnimating()
            playertagtxt.isHidden = false
            exampleimg.isHidden = false
            assingmenttxt.isHidden = false
            instruct1txt.isHidden = false
            instruct2txt.isHidden = false
            playernumbertxt.isHidden = false
            confirmbtn.isHidden = false

        }catch{}
    }
    
    /* take player to relevant view */
   @IBAction func viewcontrollerpath(_ sender: Any) {
        let items = try? playerCoreData.fetch(ClientData.fetchRequest())
        let clientData = items![0]
        /* if player was traitor when they press confirm take them to traitor view
         else take them to the crewmember view*/
        if (clientData.traitor == true) {
        self.performSegue(withIdentifier: "traitor", sender: nil)
        } else{
        self.performSegue(withIdentifier: "crew", sender: nil)

        }
    }
}
