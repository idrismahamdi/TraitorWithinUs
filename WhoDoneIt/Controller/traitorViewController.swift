import UIKit
import CoreData
import CoreNFC
import AVKit

class traitorViewController: ViewController, NFCNDEFReaderSessionDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let capture = AVCaptureSession()
    let reuseIdentifier = "reuseIdentifier"
    var detectedMessages = [NFCNDEFMessage]()
    var session: NFCNDEFReaderSession?

    @IBOutlet weak var infolbl: UILabel!
    @IBOutlet weak var playernumberlbl: UITextField!
    @IBOutlet weak var confirmbtn: UIButton!
    @IBOutlet weak var vwRecordVideo : UIView!

    /* when view loads start camera back camera and display on the view */
    override func viewDidLoad() {
        super.viewDidLoad()
        // stop the phone going to sleep
        UIApplication.shared.isIdleTimerDisabled = true
        
        // start backcamera and display this on the screen
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        let inputDevice = try? AVCaptureDeviceInput(device: videoDevice!)
        capture.addInput(inputDevice!)
        capture.startRunning()
        let preview = AVCaptureVideoPreviewLayer(session: capture)
        
        // fill the screen with the camera
        preview.videoGravity = .resizeAspectFill

        // add the label and button ontop of the camera view
        view.layer.addSublayer(preview)

        view.addSubview(confirmbtn)
        view.addSubview(infolbl)

        // capture output of camera and display this to the view every frame
        preview.frame = view.frame
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video"))
        capture.addOutput(output)
     
        
    }
    
    // when view appears
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//            let items = try? playerCoreData.fetch(ClientData.fetchRequest())
//            let clientData = items![0]
//        clientData.killedPlayer = "0"
//            try? playerCoreData.save()
//
//}
  
    // read in data from nfc once line at a time and call the model client class
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            // for each object in nfc call call the model class
            self.detectedMessages.append(contentsOf: messages)
            for msg in messages {
                for result in msg.records{
                    if let results = String(data: result.payload, encoding: .utf8){
                        // refer nfc result from view to the model
                        Client().playerDead(player: results)

                    }
                }
            }
           }
        session.invalidate()

    }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    }
    
    /* if kill player button is showed display nfc reader */
    @IBAction func killPlayer(_ sender: Any) {
        guard NFCNDEFReaderSession.readingAvailable else {
//                let alertController = UIAlertController(
//                    title: "Scanning Not Supported",
//                    message: "This device doesn't support tag scanning.",
//                    preferredStyle: .alert
//                )
//                self.present(alertController, animated: true, completion: nil)
//                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                return
            }
            /* display to player to tap their phone against the nfc tag to kill player */
            session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            session?.alertMessage = "Tap your phone against a players tag to kill them"
            session?.begin()
        
    }
    
  
        /* when view disappears stop running */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        capture.stopRunning()
    }
    
    /* every time the frame updates update view if the game has ended */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            let items = try? self.playerCoreData.fetch(ClientData.fetchRequest())
    let clientData = items![0]
    if clientData.gamefinished == true{
        self.performSegue(withIdentifier: "gameDone", sender: nil)
    }
    }}
    
}
