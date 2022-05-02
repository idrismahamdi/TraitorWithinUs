import UIKit
import CoreData


class ViewController: UIViewController {
    @IBOutlet weak var iplbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var couldNotConnectlbl: UILabel!
    @IBOutlet weak var loadingJoin: UIActivityIndicatorView!
    @IBOutlet weak var joinServerTxt: UITextField!
    
    /* once the acceessibility button is pressed take them to the accessibility settings*/
    @IBAction func accessibilitybtn(_ sender: Any) {
        UIApplication.shared.open(URL(string: "App-prefs:ACCESSIBILITY")!)
    }
    let playerCoreData = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /* when player presses join, set up default info and start client game loop */
    @IBAction func join(_ sender: Any) {
            Client().defaultInfo()
            Client().startGameLoop(ip: (joinServerTxt.text!))}

    /* when player starts server, setup server default info and start server (and game loop) */
    @IBAction func startServer_btn(_ sender: Any) {
        let serverInfo = Server().defaultInfo()!
        Server().startServer(playerCount: serverInfo)}
    
   
    override func viewDidLoad() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        super.viewDidLoad()}}




    


