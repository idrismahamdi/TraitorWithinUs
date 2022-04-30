import UIKit
import SwiftSocket
import Foundation
import CoreData
import Vision
import AVKit

class ObjectDetectionViewControler: ViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var taskcompletetxt: UILabel!
    @IBOutlet weak var taskcompleteimg: UIImageView!
    @IBOutlet weak var currentTasklbl: UILabel!
    @IBOutlet weak var tasklbl: UILabel!
    @IBOutlet weak var displayItemlbl: UILabel!
    @IBOutlet weak var killedpng: UIImageView!
    @IBOutlet weak var deadlbl: UILabel!
    
    var tasks = ["computer", "toilet tissue", "switch", "wallet", "lighter", "remote", "plastic bag"]
    var countTasks = 0
    var taskcomplete = false
    var randomTask = 0
    var countframes = 0
    let capture = AVCaptureSession()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        
        randomTask = Int.random(in: 0 ..< (tasks.count))
        currentTasklbl.text = ("Find this item in the room: \(tasks[randomTask])")

        
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        let inputDevice = try? AVCaptureDeviceInput(device: videoDevice!)
        capture.addInput(inputDevice!)
        capture.startRunning()

        let preview = AVCaptureVideoPreviewLayer(session: capture)
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        view.addSubview(taskcompleteimg)
        view.addSubview(currentTasklbl)
        view.addSubview(killedpng)
        view.addSubview(tasklbl)
        view.addSubview(deadlbl)

        preview.frame = view.bounds
        
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video"))
        capture.addOutput(output)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        capture.stopRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let model = try? VNCoreMLModel(for: SqueezeNet(configuration: MLModelConfiguration()).model) else {return}

        let request = VNCoreMLRequest(model: model) { finishedReq, err in
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            guard let first = results.first else {return}

            
            DispatchQueue.main.async {
                self.checkIfDead()
                if (first.confidence * 100) > 20{
                
               // self.displayItemlbl.text = "\(first.identifier) \(first.confidence * 100)"
                    if (self.tasksComplete(first: first.identifier)){
                        return
                    }
                   
                }
                self.countframes += 1
                if self.countframes == 30{
                    self.taskcompleteimg.isHidden = true
                    self.taskcompletetxt.isHidden = true
                    self.taskcomplete = false
                }
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: buffer, options: [:]).perform([request])
    }
    
    func checkIfDead(){
        let items = try? playerCoreData.fetch(ClientData.fetchRequest())
        let clientData = items![0]
        if clientData.dead == true{
            //view.backgroundColor = .red
            killedpng.isHidden = false
            deadlbl.textColor = .red
            deadlbl.isHidden = false
            

        }
        
        if clientData.gamefinished == true{
            self.performSegue(withIdentifier: "AllTasksDone", sender: nil)

        }
    }

    
    
    func tasksComplete(first: String) -> Bool{
     
        if (first.contains(tasks[randomTask]))
        {
            countTasks+=1
            countframes = 0
            taskcomplete = true
            
            self.tasklbl.text = ("Tasks Completed: \(countTasks)/5")
            tasks.remove(at: randomTask)
            randomTask = Int.random(in: 0..<(tasks.count))
            currentTasklbl.text = ("Find this item in the room: \(tasks[randomTask])")
            taskcompleteimg.isHidden = false
            taskcompletetxt.isHidden = false
    
        }
        if countTasks == 5 {
            
            let items = try? playerCoreData.fetch(ClientData.fetchRequest())
            let clientData = items![0]
            clientData.tasksCompleted = true
            try? playerCoreData.save()
            self.performSegue(withIdentifier: "AllTasksDone", sender: nil)
            
            
            return true
        }
        return false

        
    }
    }
