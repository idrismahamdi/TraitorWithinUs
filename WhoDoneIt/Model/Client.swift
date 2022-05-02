import UIKit
import SwiftSocket
import Foundation

class Client {
    let host = "127.0.0.1"
    let port = 8080
    var client: TCPClient?
    let response = ""
    var playerNumber = ""
    let playerCoreData = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    /* If player is a traitor the server will check if they have killed any players, if so check what player number they killed */
    func killPlayer(client: TCPClient, hold: [Byte], clientInfo: ClientData){
        /* checking if recieved data = 'kill' */
        if ((String(bytes: hold, encoding: .utf8)) == "kill"){
        /* if yes, check if player has killed anyone (reading from coreML local database) if so send the killed player to the server, reset killed player to 0 */
            if Int(clientInfo.killedPlayer)! > 0 {
                client.send(string: "\(clientInfo.killedPlayer)")
                clientInfo.killedPlayer = "0"
                try? playerCoreData.save()
            }else{
         /* else respond 0 */
                client.send(string: "0")
            }}}
    
    /* If player is a crewmember the server will check if they are dead */
    func isDead(client: TCPClient, hold: [Byte], clientInfo: ClientData){
        /* if server sent "dead" respond true if dead or fail if still alive*/
        if ((String(bytes: hold, encoding: .utf8)) == "dead"){
            if (clientInfo.dead == true || clientInfo.traitor == true)  {
                client.send(string: "true")
            }else{
                client.send(string: "fail")
            }
        
        }

    }
    
    /* crewmembers are sent this if they have been killed */
    func dead(client: TCPClient, hold: [Byte], clientInfo: ClientData, playerNumber: String){
        /* check if die + playernumber is true, if so save the information that the player has been killed (controller updates UI) */
        if ((String(bytes: hold, encoding: .utf8)) == "die\(playerNumber)"){
            clientInfo.dead = true
            try? playerCoreData.save()
        }}

    
    /* If client recieves ping then respond pong - to keep connection alive */
    func pong(client: TCPClient, hold: [Byte]) {
        if ((String(bytes: hold, encoding: .utf8)) == "ping"){
            client.send(string: "pong")
        }
      
    }
    
    /* If player is a crewmember this command will sent, to check if all tasks have been completed
     If so reply true/fail*/
    func tasksDone(client: TCPClient, hold: [Byte], clientInfo: ClientData) {
        if ((String(bytes: hold, encoding: .utf8)) == "done"){
            if (clientInfo.tasksCompleted == true || clientInfo.traitor) {
                client.send(string: "true")
            }else{
                client.send(string: "fail")
            }
        }
    }
    
    /* Server sends this to the traitor to make sure the traitor is still connected, a reply from true is sent if the traitor still is */
    func areTraitor(client: TCPClient, hold: [Byte], clientInfo: ClientData){
        if ((String(bytes: hold, encoding: .utf8)) == "areT"){
            if clientInfo.traitor == true{
                client.send(string: "true")
            }

        }}
        
    /* if game is over, the view controller updates the views when the coreML data is updated */
        func gameOver(hold: [Byte], clientInfo: ClientData){
            /* If client has recieved the command winT then save the traitors have won*/
            if ((String(bytes: hold, encoding: .utf8)) == "winT"){
                clientInfo.gamefinished = true
                clientInfo.didcrewwin = false
                try? playerCoreData.save()
            /* If client has recieved the command winC then save the Crew members have won*/
            }else if ((String(bytes: hold, encoding: .utf8)) == "winC"){
                clientInfo.gamefinished = true
                clientInfo.didcrewwin = true
                try? playerCoreData.save()
            /* If client has recieved the command winD then disconnection error */
            } else if ((String(bytes: hold, encoding: .utf8)) == "winD"){
                clientInfo.gamefinished = true
                clientInfo.disconnectdata = true
                try? playerCoreData.save()
            }
        
        
    }
    
    /**/
    
    func assignment(client: TCPClient, hold: [Byte], clientInfo: ClientData) -> String {
        
        if ((String(bytes: hold, encoding: .utf8)) == "crew"){
            guard let hold = client.read(1, timeout: 30) else {return ""}
            playerNumber = String(bytes: hold, encoding: .utf8)!
            clientInfo.traitor = false
            clientInfo.playernumber = playerNumber
            clientInfo.gamestarted = true
            try? playerCoreData.save()
        }else if ((String(bytes: hold, encoding: .utf8)) == "trai") {
            guard let hold = client.read(1, timeout: 30) else {return ""}
            playerNumber = String(bytes: hold, encoding: .utf8)!
            clientInfo.traitor = true
            clientInfo.playernumber = playerNumber
            clientInfo.gamestarted = true

            try? playerCoreData.save()}
    
        return playerNumber

    }
    
    
    func startGameLoop(ip: String){
        
        /* Start of thread - Concurrent Work Design Pattern */
        let t = Thread{ [self] in
   
            let items = try? self.playerCoreData.fetch(ClientData.fetchRequest())
            var clientInfo = items![0]
    
        
        /* Setting the client socket to the hosts information, which will be the host to */
        let client = TCPClient(address: ip, port: 8080)
        var playerNumber = ""
            
        /* Try and connect to server, with 10 seconds timeout */
        switch client.connect(timeout: 10) {
            case .success:
            /* If the connection is successfull start game loop until game is finished */
            while clientInfo.gamefinished == false{
                
                
                /* Fetch local data to keep data up to date every loop*/
               let items = try? self.playerCoreData.fetch(ClientData.fetchRequest())
               clientInfo = items![0]
                
            /* Read in 4 bytes of data, if no data is read in for 10 seconds exit game loop */
              guard let hold = client.read(4, timeout: 10) else {
                  clientInfo.gamefinished = true
                  clientInfo.disconnectdata = true
                  try? playerCoreData.save()
                  return
              }
        
              /* check if been pinged, if so ping back */
              self.pong(client: client, hold: hold)
              /* check if assinged traitor, and playernumber */
              playerNumber = self.assignment(client: client, hold: hold, clientInfo: clientInfo)
              /* only traitor recieves this from the server - check if the traitor has killed anyone */
              self.killPlayer(client: client, hold: hold, clientInfo: clientInfo)
              /* only crewmembers recieves this from the server - checking if the current player has just been killed */
              self.dead(client: client, hold: hold, clientInfo: clientInfo, playerNumber: playerNumber)
              /* only crewmembers recieves this from the server - check if player is dead (keeps server up to date) */
              self.isDead(client: client, hold: hold, clientInfo: clientInfo)
              /* only traitor recieves this from the server - checking if player is not disconnected from the game */
              self.areTraitor(client: client, hold: hold, clientInfo: clientInfo)
              /* only crewmembers are sent this from the server - checks if the player has completed all of their tasks*/
              self.tasksDone(client: client, hold: hold, clientInfo: clientInfo)
              /* check if game has ended */
              self.gameOver(hold: hold, clientInfo: clientInfo)
          }
            /* once while loop, connection is closed*/
            client.close()
          
            /* if connecting to server failed then save been disconnected*/
            case .failure:
                clientInfo.disconnectdata = true
                try? playerCoreData.save()
          
      }
      
           
            
        }
        
        /* starting thread -  Concurrent Work Design Pattern  */
        t.start()

    
    
    
    
    
    
    
}
    /* when a player is dead then save this information */
    func playerDead(player: String){
                let items = try? playerCoreData.fetch(ClientData.fetchRequest())
                let clientData = items![0]
                clientData.killedPlayer = player
                try? playerCoreData.save()

    }
    
    /* setting up client information */
    func defaultInfo(){
    /* if first install of app create new coreml data, else use [0] in array of existing data */
     var x = 0
        var clientData: ClientData?
     do{
        let items = try playerCoreData.fetch(ClientData.fetchRequest())
         for _ in items{
             x+=1
         }
         if x == 0{
             clientData = ClientData(context: playerCoreData)

        }else{
             clientData = items[0]
             
         }
         /* set coreML default values for the client*/
         clientData!.gamestarted = false
         clientData!.traitor = false
         clientData!.playernumber = ""
         clientData!.gamefinished = false
         clientData!.tasksCompleted = false
         clientData!.dead = false
         clientData!.killedPlayer = "0"
         clientData!.disconnectdata = false
         try? playerCoreData.save()
     }catch{}
    }
    }
