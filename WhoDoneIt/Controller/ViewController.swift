import UIKit
import SwiftSocket
import Foundation
import CoreData


class ViewController: UIViewController {
    @IBOutlet weak var iplbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var couldNotConnectlbl: UILabel!
    @IBOutlet weak var loadingJoin: UIActivityIndicatorView!
    @IBOutlet weak var joinServerTxt: UITextField!
    
    @IBAction func accessibilitybtn(_ sender: Any) {
        UIApplication.shared.open(URL(string: "App-prefs:ACCESSIBILITY")!)
    }
    let playerCoreData = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func join(_ sender: Any) {
            Client().defaultInfo()
            Client().startGameLoop(ip: (joinServerTxt.text!))}

    @IBAction func startServer_btn(_ sender: Any) {
        let serverInfo = Server().defaultInfo()!
        Server().startServer(playerCount: serverInfo)}
    
   
    override func viewDidLoad() {
        UIApplication.shared.isIdleTimerDisabled = true
        super.viewDidLoad()}}




    


