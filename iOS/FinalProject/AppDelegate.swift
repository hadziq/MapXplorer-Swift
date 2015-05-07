//
//  AppDelegate.swift
//  FinalProject
//
//  Created by Ying-Kai Huang on 12/25/14.
//  Copyright (c) 2014 NTUST. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ServerDelegate{
    
    var window: UIWindow?
    var server: Server!
    var serverBrowserVC :BrowserViewController!
    var mapVC : MapViewController!
    var navigationController :  UINavigationController!
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        GMSServices.provideAPIKey("AIzaSyB-40UV3tzfkjR_vQVXhKpBNSxiusYS1Wc")
        // Override point for customization after application launch.
        
        
        let type:NSString = "mapXplorer"
        
        server = Server(protocols: type as String)
        server.delegate = self
        var error: NSError? = nil
        if !server.start(&error){
            NSLog("error = %@", error!)
        }
        
        
        
        serverBrowserVC = storyboard.instantiateViewControllerWithIdentifier("BrowserView") as! BrowserViewController
        mapVC = storyboard.instantiateViewControllerWithIdentifier("MapView") as! MapViewController
        navigationController = storyboard.instantiateViewControllerWithIdentifier("NAV") as! UINavigationController
        
        
        
        println(serverBrowserVC.title)
        println(mapVC.title)
        
        println(navigationController.title)
        serverBrowserVC.server = self.server
        
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.server.stop()
        self.server.stopBrowser()
        
    }
    
    
    
    
    
    
    
    
    
    
    // serverDelegate Protocol
    
    func serverRemoteConnectionComplete( server: Server){
        mapVC.server = server
        serverBrowserVC.enableStartButton(self)
    }
    
    func startMap(){
        
        var stringMessage: NSString = NSString(format: "Location,%f,%f,%f", self.mapVC.latitude, self.mapVC.longitude, self.mapVC.bearing)
        //print("!!!")
        var data = stringMessage.dataUsingEncoding(NSUTF8StringEncoding)
        var error: NSError? = nil
        self.server?.sendData(data, error: &error)
       // self.navigationController.pushViewController(mapVC, animated: true)
    }
    
    func isConnectedToServer() -> Bool{
        return (self.mapVC.server != nil)
    }
    
    func toggleUserLocation(on: Bool){
        self.mapVC.isUserLocationEnabled = on
        println("userlocatonenabled: \(on)")
    }
    
    func toggleLocationDescription(on: Bool){
        
        self.mapVC.isLocationDescriptionEnabled = on
        println("locationDecription: \(on)")
    }
    func toggleRouteOriented(on: Bool){
        self.mapVC.isRouterOriented = on
        println("toggleRouteOriented: \(on)")
    }
    
    func toggleNorthDependent(on: Bool){
        self.mapVC.isNorthDependent = on
        println("toggleNorthDependent: \(on)")
    }
    func toggleIntersectionAwared(on: Bool){
        self.mapVC.isIntersectionAwared = on
        println("toggleIntersectionAwared: \(on)")
    }
    func changeDrivingAccelerationLevel(value: Int){
        self.mapVC.drivingAccelerationLevel = value
        println("changeDrivingAccelerationLevel: \(value)")
    }
    
    func serverStopped(server : Server){
        NSLog("Server Stop")
        serverBrowserVC.disableStartButton(self)
        
    }
    func togglePitchPreference(preference: NSString){
        self.mapVC.pitchPreference = preference
        
    }
    func setLatitude(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        self.mapVC.latitude = latitude
        self.mapVC.longitude = longitude
    }
    
    
    func serviceAdded(service: NSNetService!, moreComing more: Bool) {
        
        serverBrowserVC.addService(service, more: more)
        
    }
    func serviceRemoved(service: NSNetService!, moreComing more: Bool) {
        
        serverBrowserVC.removeService(service, more: more)
        
    }
    func server(server: Server!, lostConnection errorDict: [NSObject : AnyObject]!) {
        
        NSLog("Server lost connection", errorDict)
        
        serverBrowserVC.disableStartButton(self)
        
        self.navigationController.popViewControllerAnimated(true)
        
    }
    func server(server: Server!, didAcceptData data: NSData!) {
        
        
        var localMessage: NSString! = NSString(data: data, encoding: NSUTF8StringEncoding)
        if( nil != localMessage || localMessage.length > 0){
            mapVC.message = localMessage
            println(localMessage)
        }else{
            mapVC.message = "no data received"
        }
        
        var messageData: NSArray = mapVC.message?.componentsSeparatedByString(",") as! [NSString]
        var messageHeader: NSString = NSString(format: "%@", messageData.objectAtIndex(0) as! NSString)
        
        if messageHeader.isEqualToString("Location"){
            var numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .DecimalStyle
            
            if let number = numberFormatter.numberFromString(messageData.objectAtIndex(1) as! String){
                mapVC.latitude = number.doubleValue
            }
            if let number = numberFormatter.numberFromString(messageData.objectAtIndex(2) as! String){
                mapVC.longitude = number.doubleValue
            }
            if let number = numberFormatter.numberFromString(messageData.objectAtIndex(3) as! String){
                mapVC.movingBearing = number.doubleValue
            }
            if let number = numberFormatter.numberFromString(messageData.objectAtIndex(4) as! String){
                mapVC.numberOfPathLinks = number.integerValue
            }
            
            // change location on the map
<<<<<<< HEAD
            
            var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: mapVC.latitude, longitude: mapVC.longitude)
            mapVC.resetLocation(coordinate)
        }else if messageHeader.isEqualToString("Notification"){
            
            mapVC.showNotification(messageData.objectAtIndex(1) as NSString, type: messageData.objectAtIndex(2) as NSString)
=======
            var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: mapVC.latitude, longitude: mapVC.longitude)
            mapVC.resetLocation(coordinate)

            
        }else if messageHeader.isEqualToString("Notification"){
            
            mapVC.showNotification(messageData.objectAtIndex(1) as! NSString, type: messageData.objectAtIndex(2) as! NSString)
            
>>>>>>> 99451ca97743dc716a4237e0f0471178d168abaa
        }
        
    }
    func server(server: Server!, didNotStart errorDict: [NSObject : AnyObject]!) {
        NSLog("Server did not start %@", errorDict)
    }
    
    
}

