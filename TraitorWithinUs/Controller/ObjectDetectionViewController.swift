import UIKit
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
    /* the tasks that can happen during the game - this is very common items in a indoor place.
     In the rules the player is told they need these items. */
    var tasks = ["keyboard", "switch", "wallet", "clock", "remote", "plastic bag", "toilet tissue"]
    var countTasks = 0, taskcomplete = false, randomTask = 0, countframes = 0
    let capture = AVCaptureSession()
    
    /* When view loads display back camera on the screen */
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        /* assign a random task and display this*/
        randomTask = Int.random(in: 0 ..< (tasks.count))
        currentTasklbl.text = ("Find this item in the room: \(tasks[randomTask])")

        /* Choose back camera to be displayed on screen*/
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        let inputDevice = try? AVCaptureDeviceInput(device: videoDevice!)
        capture.addInput(inputDevice!)
        capture.startRunning()
        let preview = AVCaptureVideoPreviewLayer(session: capture)
        /* Make camera full screen and add the text and images above the camera on the view*/
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        view.addSubview(taskcompleteimg)
        view.addSubview(currentTasklbl)
        view.addSubview(killedpng)
        view.addSubview(tasklbl)
        view.addSubview(deadlbl)
        preview.frame = view.bounds
        
        /* output to the view of the camera is the output of the backcamera*/
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video"))
        capture.addOutput(output)
        
    }
        /*once the view has gone stop taking input from the back camera*/
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        capture.stopRunning()
    }
    
    /* when a frame is captaured */
    /* this function mainly updates the view and can only be recieved on the view controller class */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        /* add image to the buffer and analyse the image compared to the squeezenet model*/
        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        guard let model = try? VNCoreMLModel(for: SqueezeNet(configuration: MLModelConfiguration()).model) else {return}
        let request = VNCoreMLRequest(model: model) { finishedReq, err in
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            guard let first = results.first else {return}

            DispatchQueue.main.async {
                /*if dead call this function to update view*/
                self.ifDead()
                /*if condfidence is above 20% call the view to update task is completed */
                if (first.confidence * 100) > 20{
                
               // self.displayItemlbl.text = "\(first.identifier) \(first.confidence * 100)"
                    if (self.tasksComplete(first: first.identifier)){
                        return
                    }
                   
                }
                /* counting frames as a time to update the view after task is completed with green tick */
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
    
    /* if player is dead update their view letting them know their dead */
    func ifDead(){
        let items = try? playerCoreData.fetch(ClientData.fetchRequest())
        let clientData = items![0]
        if clientData.dead == true{
            //view.backgroundColor = .red
            killedpng.isHidden = false
            deadlbl.textColor = .red
            deadlbl.isHidden = false
            

        }
        /*if game end update the view to alltasksdone view*/
        if clientData.gamefinished == true{
            self.performSegue(withIdentifier: "AllTasksDone", sender: nil)

        }
    }

    
    /* if all task is complete update view */
    func tasksComplete(first: String) -> Bool{
     
        if (first.contains(tasks[randomTask]))
        {
            /* update task completed if the task matched the view */
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
        /*if tasks complete = 5 then display allTaskDone view*/
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
