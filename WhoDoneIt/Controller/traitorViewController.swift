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
        UIApplication.shared.isIdleTimerDisabled = true

        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        let inputDevice = try? AVCaptureDeviceInput(device: videoDevice!)
        capture.addInput(inputDevice!)
        capture.startRunning()

        let preview = AVCaptureVideoPreviewLayer(session: capture)
        preview.videoGravity = .resizeAspectFill

        view.layer.addSublayer(preview)

        view.addSubview(confirmbtn)
        view.addSubview(infolbl)

        preview.frame = view.frame
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video"))
        capture.addOutput(output)
     
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            let items = try? playerCoreData.fetch(ClientData.fetchRequest())
            let clientData = items![0]
        clientData.killedPlayer = "0"
            try? playerCoreData.save()
    
}
    func onNFCResult(success: Bool, msg: String) {
      
        Client().playerDead(player: msg)
       
     }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
               // Process detected NFCNDEFMessage objects.
            self.detectedMessages.append(contentsOf: messages)
            for message in messages {
                for record in message.records{
                    if let results = String(data: record.payload, encoding: .utf8){
                        self.onNFCResult(success: true, msg: results)

                    }
                }
            }
           }
        session.invalidate()

    }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    @IBAction func killPlayer(_ sender: Any) {
        

        guard NFCNDEFReaderSession.readingAvailable else {
                let alertController = UIAlertController(
                    title: "Scanning Not Supported",
                    message: "This device doesn't support tag scanning.",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }

            session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            session?.alertMessage = "Tap your phone against a players tag to kill them"
            session?.begin()
        
    }
    
    
  
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        capture.stopRunning()
    }
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            let items = try? self.playerCoreData.fetch(ClientData.fetchRequest())
    let clientData = items![0]
    if clientData.gamefinished == true{
        self.performSegue(withIdentifier: "gameDone", sender: nil)
    }
    }}
    
}
