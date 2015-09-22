//
//  AppDelegate.swift
//  BlockDrawing
//
//  Created by Tanmay Bakshi on 2015-08-22.
//  Copyright © 2015 Tanmay Bakshi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSSpeechRecognizerDelegate {

    var sr = NSSpeechRecognizer()
    var commands = ["up", "upleft", "upright", "down", "downleft", "downright", "left", "right", "stop", "place", "clear"]
    
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet var upBtn: NSButton!
    @IBOutlet var dnBtn: NSButton!
    @IBOutlet var ltBtn: NSButton!
    @IBOutlet var rtBtn: NSButton!
    @IBOutlet var spBtn: NSButton!
    
    @IBOutlet var blocksTextview: NSTextView!
    @IBOutlet var playersTextview: NSTextView!
    
    var players: [NSImageView] = []
    
    var blocks: [NSImageView] = []
    
    var playersData = NSArray()
    
    var blocksData = NSArray()
    
    var thisPlayer = NSImageView()
    
    var x = 0
    var y = 0
    
    var playerID = 1
    
    let PLAYERS_GET_URL = "http://www.tanmaybakshi.com/getplayers.php"
    
    var PLAYERS_SET_URL: String {
        get {
            return "http://www.tanmaybakshi.com/setplayer.php?" + "&x=\(x)&y=\(y)&pid=\(playerID)"
        }
    }
    
    let BLOCKS_GET_URL = "http://www.tanmaybakshi.com/getblocks.php"
    
    var BLOCKS_SET_URL: String {
        get {
            return "http://www.tanmaybakshi.com/setblock.php?" + "x=\(x)&y=\(y)"
        }
    }
    
    var PLAYER_REMOVE: String {
        get {
            return "http://www.tanmaybakshi.com/deleteplayer.php?" + "pid=\(playerID)"
        }
    }
    
    var BLOCKS_REMOVE: String = "http://www.tanmaybakshi.com/deleteBlocks.php"
    
    var gameTimer = NSTimer()

    func dataOfURL(url: String) -> NSData {
        return NSData(contentsOfURL: NSURL(string: url)!)!
    }
    
    func dataToJSON(data: NSData) -> AnyObject {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        } catch {
            print(error)
        }
        return []
    }
    
    @IBAction func upClicked(sender: NSButton!) {
        y += 50
    }
    
    @IBAction func upLeft(sender: NSButton!) {
        upClicked(sender)
        leftClicked(sender)
    }
    
    @IBAction func upRight(sender: NSButton!) {
        upClicked(sender)
        rightClicked(sender)
    }
    
    @IBAction func downClicked(sender: NSButton!) {
        y -= 50
    }
    
    @IBAction func downLeft(sender: NSButton!) {
        downClicked(sender)
        leftClicked(sender)
    }
    
    @IBAction func downRight(sender: NSButton!) {
        downClicked(sender)
        rightClicked(sender)
    }
    
    @IBAction func leftClicked(sender: NSButton!) {
        x -= 50
    }
    
    @IBAction func rightClicked(sender: NSButton!) {
        x += 50
    }
    
    @IBAction func spaceClicked(sender: NSButton!) {
        placeBlockAtPos()
    }
    
    @IBAction func deleteBlocks(sender: NSButton!) {
        dataOfURL(BLOCKS_REMOVE)
    }
    
    @IBAction func commandIt(sender: NSButton!) {
        sr!.delegate = self
        sr!.commands = commands
        sr!.startListening()
    }
    
    func speechRecognizer(sender: NSSpeechRecognizer, didRecognizeCommand command: String) {
        if command == "stop" {
            sender.stopListening()
        } else {
            if command.containsString("up") {
                upClicked(nil)
            }
            if command.containsString("down") {
                downClicked(nil)
            }
            if command.containsString("left") {
                leftClicked(nil)
            }
            if command.containsString("right") {
                rightClicked(nil)
            }
            if command == "place" {
                placeBlockAtPos()
            }
            if command == "clear" {
                deleteBlocks(nil)
            }
        }
    }
    
    func placeBlockAtPos() {
        dataOfURL(BLOCKS_SET_URL) //This one line will upload the x and y of our block to the database
    }
    
    func update() {
        playersTextview.string = ""
        blocksTextview.string = ""
        dataOfURL(PLAYERS_SET_URL)
        self.window.contentView!.subviews.map() { if $0.isKindOfClass(NSImageView) { $0.removeFromSuperview() } }
        thisPlayer = NSImageView(frame: NSRect(x: x, y: y, width: 50, height: 50))
        players = []
        playersData = dataToJSON(dataOfURL(PLAYERS_GET_URL)) as! NSArray
        for i in playersData {
            let finalDat = i as! NSDictionary
            let finalX = Int(finalDat["x"] as! String)!
            let finalY = Int(finalDat["y"] as! String)!
            let finalPid = Int(finalDat["pid"] as! String)!
            playersTextview.string! += "X: \(finalX) | Y: \(finalY) | PID: \(finalPid)\n"
            players.append(NSImageView(frame: NSRect(x: finalX, y: finalY, width: 50, height: 50)))
        }
        players.append(thisPlayer)
        players.map() { ($0 as! NSImageView).wantsLayer = true; ($0 as! NSImageView).layer!.backgroundColor = $0 == thisPlayer ? NSColor.redColor().CGColor : NSColor.blackColor().CGColor }
        for i in players {
            self.window.contentView!.addSubview(i)
        }
        blocksData = dataToJSON(dataOfURL(BLOCKS_GET_URL)) as! NSArray
        blocks = []
        for i in blocksData {
            let finalDat = i as! NSDictionary
            let finalX = Int(finalDat["x"] as! String)!
            let finalY = Int(finalDat["y"] as! String)!
            blocksTextview.string! += "X: \(finalX) | Y: \(finalY)\n"
            blocks.append(NSImageView(frame: NSRect(x: finalX, y: finalY, width: 50, height: 50)))
        }
        blocks.map() { ($0 as! NSImageView).wantsLayer = true; ($0 as! NSImageView).layer!.backgroundColor = NSColor.blueColor().CGColor }
        for i in blocks {
            self.window.contentView!.addSubview(i)
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        dataOfURL(PLAYERS_SET_URL)
        for i in dataToJSON(dataOfURL(PLAYERS_GET_URL)) as! NSArray {
            playerID++
            var val = Int((i as! NSDictionary)["pid"] as! String)!
            dataOfURL("http://www.tanmaybakshi.com/deleteplayer.php?" + "pid=\(val)")
        }
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: true)
        dataOfURL(PLAYER_REMOVE)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        dataOfURL(PLAYER_REMOVE)
    }


}

