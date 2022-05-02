import UIKit
import SwiftSocket
import Foundation
import CoreData

/* client is linked to a player number */
struct player{
    var client: TCPClient
    var playerNumber: Int
}

class Server {
    
    var t = Thread()
    var clientArr: [TCPClient] = []
    var playerArr: [player] = []
    let playerCoreData = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    


/* Ping pong game - keeps connection alive between server and client */
    func ping(client: TCPClient) -> Bool? {
      
        /* send client ping and wait for response, if no response after 2 seconds time out*/
        client.send(string: "ping")
        guard let hold = client.read(4, timeout: 2) else {return false}
        
        /* if the client responds pong then return true else return false */
        let pong = String(bytes: hold, encoding: .utf8)
        if pong == "pong" {
            return true
        }
        
        return false
    }

/* checks with client that they have killed someone */
    func killed(client: TCPClient, wasKilled: Int) -> Int?{
        
        /* send 'kill' to check if player has killed anyone - if no response return 0 */
        client.send(string: "kill")
        guard let hold = client.read(1, timeout: 2) else {return 0}
        
        /* if response and it is not 0 then return the player which was killed*/
        let killed = String(bytes: hold, encoding: .utf8)
        if killed != "0" {
            return Int(killed!)
        }
        
        /* else return wasKilled+0 incase a previous player killed*/
        return wasKilled+0
    }
    
/* checks with player if they are dead */
    func isDead(client: TCPClient) -> Int? {
        
        /* send 'dead' to check if player is dead - if no response return 0 (assume dead) */
        client.send(string: "dead")
        guard let hold = client.read(4, timeout: 2) else {return 0}
        
        /* if the player returns true then return 0 else return 1 */
        let dead = String(bytes: hold, encoding: .utf8)
        if dead == "true" {
            return 0
        }
        return 1
    }
    
/* Checking if each player is the traitor to see if the tratior is still connected */
    func traitorAlive(client: TCPClient) -> Bool?{
        /* If you are the tratior*/
        client.send(string: "areT")
        guard let hold = client.read(4, timeout: 2) else {return false}
        let traitor = String(bytes: hold, encoding: .utf8)
        
        /* If player is tratior then return true else return false */
        if traitor == "true" {
            return true
        }
        return false
    }
    
/* Checking with player if their tasks are done */
    func tasksComplete(client: TCPClient) -> Int? {
        /* Asking player if done and waiting their reply message*/
        client.send(string: "done")
        guard let hold = client.read(4, timeout: 2) else {return 0}
        let tasks = String(bytes: hold, encoding: .utf8)
     
        /* If their tasks are done then return 0 else return 1*/
        if tasks == "true" {
            return 0
        }
        return 1

    }
    
/* Once the game has been start then assign players their player data */
    func gameStarted(client: TCPClient, traitor: Int, playerNumberAssingment: Int) {
        
        /* If the playernumber matches the player number which was a traitor
               Send over to that player that they are the traitor */
        if traitor == (playerNumberAssingment - 1){
            client.send(string: "trai")
        }
        /* Else then send over to the player that they are a crewmember  */
        else {
            client.send(string: "crew")
        }

        /* Send player their player number */
        client.send(string: String(playerNumberAssingment))

        }
    
/* Accepts Connections To The Game */
    func acceptingConnections(serverInfo: Player, server: TCPServer) -> Bool {
       
        var j = 0
       
        /* When the game has not been started accept connections */
        while (serverInfo.gamestarted == false) {
            
        if let client = server.accept(timeout: 1) { /* timeout at 1 second to make sure existing players don't disconnect waiting */
            
            /* If connection accepted then add to array and +1 to the playercount CoreML file and save this */
            self.clientArr.append(client)
            serverInfo.playercount += 1
            try? self.playerCoreData.save()
        } else {
           
            /* If no new client to the server then ping all players
               If ping is unsucesfull, remove client from array of connected players
               then -1 from player count and save this to the coreML data */
            j = 0
            for i in self.clientArr {
                if self.ping(client: i) == false{
                    serverInfo.playercount -= 1
                    self.clientArr.remove(at: j)
                    try? self.playerCoreData.save()}
                j+=1 /* Note: j is used as you are unable to use i to find the position of array in swift*/
                
            }}
            
            /* If the host has has went back home return false to close the server*/
            if serverInfo.home == true{
                return false
            }

        }
        return true
    }
    
    


/* Main Server Function */
func startServer(playerCount: Player) {
    
    /* Setting the server to run on 0.0.0.0 so it can be accessed locally by any device */
    let server = TCPServer(address: "0.0.0.0", port: 8080)
   
    /*Start to listen on the server */
       switch server.listen() {
        /* if sucessful then start */
       case .success:
           t = Thread {
                            
               /* Call function to accept incoming connections
                  if connection fails/player returns home : close server
                  otherwise if game started setup the game */
               if self.acceptingConnections(serverInfo: playerCount, server: server) == false{
                   server.close()
               } else{
               
               var playerNumberAssingment = 0, traitor = 0

               /* If there is at least one player, then randomly assign a player to become a traitor */
               if self.clientArr.count != 0{
                    traitor = Int.random(in: 0..<self.clientArr.count)}
               
               /* For each player that is connected to the server, run the gameStarted function
                  Assings each player a playercount, and the correlating crewmember or traitor */
               for i in self.clientArr {
                   playerNumberAssingment += 1
                   let p = player(client: i, playerNumber: playerNumberAssingment)
                   self.playerArr.append(p)
                   self.gameStarted(client: i, traitor: traitor, playerNumberAssingment: playerNumberAssingment)}
                   
                   
               var traitorWin = 0, crewWin = 0, wasKilled = 0, gameOver = false, count = 0
                   
                   
              /* Start server side game loop until the game has finished */
               while gameOver == false{
                   
              /* Start of game loop */
                   crewWin = 0
                   traitorWin = 0
                   count = 0
            
                   
                   /* For each client that is connected to the server */
                       for i in self.playerArr {
                           
                           if (i.playerNumber-1 != traitor) {

                           /* Check if they have completed their tasks
                              If they have completed their tasks then crewWin adds nothing on
                              If they have not completed their tasks the crewWin adds 1 */
                           crewWin = crewWin + self.tasksComplete(client: i.client)!
                           
                           /* check if they are dead */
                           traitorWin = traitorWin + self.isDead(client: i.client)!
                               
                           }
                           
                           /* checks for the traitor */
                           if (i.playerNumber-1 == traitor) {
                               
                            /* check if the traitor killed someone
                            If a player has been killed then send player that was killed that they were killed*/
                            wasKilled = self.killed(client: i.client, wasKilled: wasKilled)!
                            if (wasKilled > 0) {
                                   for j in self.playerArr{
                                       if j.playerNumber == wasKilled{
                                           j.client.send(string: "die\(wasKilled)")
                                       }}}
                               
                               /* If traitor has disconnected, echo out disconnection to all players and end game loop */
                               if self.traitorAlive(client: i.client) == false{
                                   for j in self.playerArr{
                                       j.client.send(string: "winD")
                                       gameOver = true
                                   }
                               }
                               
                           }
                           
                           
                           /* Ping to keep connection alive if false then remove client from players */
                           if self.ping(client: i.client) == false {
                               self.playerArr.remove(at: count)
                              }
                           count += 1
                           }
                                         
                     
                   /* If no crewmembers have any tasks left, echo out result to all players and end game loop */
                        if (crewWin == 0){
                               for j in self.playerArr{
                                   j.client.send(string: "winC")
                                   gameOver = true
                               }}
                   
                   /* If no crewmembers alive, echo out result to all players and end game loop */
                        if (traitorWin == 0){
                                for j in self.playerArr{
                                    j.client.send(string: "winT")
                                    gameOver = true
                                }}
                       
                   /* End of game loop */
               }
                   
                   /* When game ended (game loop stopped) close the server */
                   server.close()}}
           
           /* starting the server in a new thread */
            t.start()
       
           
         /* If server did not start send debug error */
         case .failure(let error):
           print(error)}
    
    
}
    
    
    
    /* closes server */
    func cancelServer(){
        let items = try? playerCoreData.fetch(ClientData.fetchRequest())
        let clientData = items![0]
        /* game started and finished happen to close the server */
        clientData.gamestarted = true
        clientData.gamefinished = true
        try? playerCoreData.save()
        sleep(5)
        /* set back to default */
        clientData.gamestarted = false
        try? playerCoreData.save()
      
    }
    
    
    /* server data setup */
    func defaultInfo() -> Player?{
    
        /* if first time using the app then set up core data else use the first item in array */
     var x = 0
        var serverInfo: Player?
     do{
        let items = try playerCoreData.fetch(Player.fetchRequest())
         for _ in items{
             x+=1
         }
         if x == 0{
             serverInfo = Player(context: playerCoreData)

        }else{
            serverInfo = items[0]
             
         }
         
         /* set default core data for the server */
         serverInfo!.playercount = 0
         serverInfo!.gamestarted = false
         serverInfo!.home = false
         try? playerCoreData.save()
         return serverInfo
     }catch{}
        return nil
    }
}
