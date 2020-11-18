//
//  AppDelegate.swift
//  AndroidBattery
//
//  Created by Nimish Santosh on 17/11/20.
//

import Cocoa
import CocoaAsyncSocket

@main
class AppDelegate: NSObject, NSApplicationDelegate, GCDAsyncUdpSocketDelegate {

    // SOCKET
    var socket : GCDAsyncUdpSocket?
    let PORT : UInt16 = 1737
    
    // MENU
    var statusItem: NSStatusItem?
    var menu: NSMenu?
    // BATTERY MENU ITEM
    var batteryMenuItem: NSMenuItem?
    var batteryString = "Battery                   "
    var chargingMenuItem: NSMenuItem?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // SOCKET INIT
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue:DispatchQueue.main)
        do {
            try socket?.bind(toPort: PORT)
            try socket?.enableBroadcast(true)
            try socket?.beginReceiving()
        } catch _ as NSError { print("Issue with setting up listener") }
        
        
        // MENU INIT
        menu = NSMenu()
        statusItem  = NSStatusBar.system.statusItem(withLength: -1)
        statusItem?.menu = menu
        
        // check space for button
        guard let button = statusItem?.button else {
            print("Status bar item failed. Try removing some menu bar item.")
            NSApp.terminate(nil)
            return
        }
        
        // set default icon
        button.image = NSImage(named: "NIL")
        button.target = self
        //button.action = #selector(test)
    
        // CREATE MENU
//        // debug items >>>
//        menu?.addItem(NSMenuItem(title: "Test", action: #selector(test), keyEquivalent: ""))
//        menu?.addItem(NSMenuItem(title: "Change15", action: #selector(change15), keyEquivalent: ""))
//        menu?.addItem(NSMenuItem(title: "Change20", action: #selector(change20), keyEquivalent: ""))
//        menu?.addItem(NSMenuItem.separator())
//        // debug items <<<
        
        batteryMenuItem = NSMenuItem(title: batteryString+"NIL", action: nil, keyEquivalent: "")
        menu?.addItem(batteryMenuItem ?? NSMenuItem(title: "ERROR", action: nil, keyEquivalent: ""))
        chargingMenuItem = NSMenuItem(title: "Not Available", action: nil, keyEquivalent: "")
        menu?.addItem(chargingMenuItem ?? NSMenuItem(title: "ERROR", action: nil, keyEquivalent: ""))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared.terminate), keyEquivalent: ""))
    }

    // ON DATA LISTENER
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        // received data
        let datastring = String(decoding: data, as: UTF8.self)
        //print("[DEBUG]   "+datastring)
        handleData(datastring: datastring)
    }
    
    // CHANGE IMAGE
    func handleData(datastring: String){
        // CHANGE DISCRETE IMAGES (NIL,15,20,40,60,80,100)
        guard let button = statusItem?.button else {return}
        
        //nil
        if (datastring=="NIL") {
            button.image = NSImage(named: "NIL")
            batteryMenuItem?.title = batteryString+datastring
            chargingMenuItem?.title = "Not Available"
            return
        }
        //all other numbers (format example: 15C or 15D)
        let prefixcount = (datastring.count==3 ? 2 : 3)
        let charge = Int(String(datastring.prefix(prefixcount)))
        let status = String(datastring.suffix(1))
        
        if (charge!<20) {
            if(status=="C") {
                button.image = NSImage(named: "15C")
            }
            else if(status=="D") {
                button.image = NSImage(named: "15D")
            }
        }
        else if (charge!>=20 && charge!<35) {
            if(status=="C") {
                button.image = NSImage(named: "20C")
            }
            else if(status=="D") {
                button.image = NSImage(named: "20D")
            }
        }
        else if (charge!>=35 && charge!<55) {
            if(status=="C") {
                button.image = NSImage(named: "40C")
            }
            else if(status=="D") {
                button.image = NSImage(named: "40D")
            }
        }
        else if (charge!>=55 && charge!<75) {
            if(status=="C") {
                button.image = NSImage(named: "60C")
            }
            else if(status=="D") {
                button.image = NSImage(named: "60D")
            }
        }
        else if (charge!>=75 && charge!<95) {
            if(status=="C") {
                button.image = NSImage(named: "80C")
            }
            else if(status=="D") {
                button.image = NSImage(named: "80D")
            }
        }
        else if (charge!>=95) {
            if(status=="C") {
                button.image = NSImage(named: "100C")
            }
            else if(status=="D") {
                button.image = NSImage(named: "100D")
            }
        }
        // SET BATTERY VALUE (menu)
        batteryMenuItem?.title = batteryString+String(datastring.prefix(prefixcount))+"%"
        // SET CHARGING STATUS (menu)
        if(status=="C") {
            chargingMenuItem?.title = "Charging"
        }
        else if (status=="D") {
            chargingMenuItem?.title = "Not Charging"
        }
        
    }
    
//    // DEBUG FUNCTIONS >>>
//    // toggle 15
//    @objc func change15(sender: NSStatusBarButton) {
//        guard let button = statusItem?.button else {return}
//        button.image = NSImage(named: "15")
//        batteryMenuItem?.title = batteryString+"15%"
//    }
//    // toggle 20
//    @objc func change20(sender: NSStatusBarButton) {
//        guard let button = statusItem?.button else {return}
//        button.image = NSImage(named: "20")
//        batteryMenuItem?.title = batteryString+"20%"
//    }
//    // test
//    @objc func test(sender: NSStatusBarButton) {
//        print("[DEBUG]   Testing...")
//    }
//    // DEBUG FUNCTIONS <<<
    
    func applicationWillTerminate(_ aNotification: Notification) {
        socket?.close()
    }
}
