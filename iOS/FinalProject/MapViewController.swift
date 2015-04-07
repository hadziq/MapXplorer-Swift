//
//  MapViewController.swift
//  FinalProject
//
//  Created by Ying-Kai Huang on 12/29/14.
//  Copyright (c) 2014 NTUST. All rights reserved.
//

import UIKit
import CoreMotion
let kShakingThreshold = 1.2


class MapViewController: UIViewController, CLLocationManagerDelegate ,UIGestureRecognizerDelegate,GMSMapViewDelegate{
    
    
    var mapView = GMSMapView()
    
    let locationManager = CLLocationManager()
    var server: Server!
    var justInitiated: Bool = false
    var isRouterOriented: Bool = false
    var isNorthDependent: Bool = false
    var isIntersectionAwared: Bool?
    var drivingAccelerationLevel: Int = 2
    var isInAutoRotationMode: Bool = false
    var isDeviceLaying: Bool = false
    var isInDriving: Bool = false
    var isInJumping: Bool = false
    var isInPitching: Bool = false
    var pitchTimer: NSTimer = NSTimer()
    var movingTimer: NSTimer = NSTimer()
    var rotationTimer: NSTimer = NSTimer()
    var autoRotationTimer = NSTimer()
    var message: NSString?
    var isUserLocationEnabled: Bool = false
    var isLocationDescriptionEnabled: Bool = true
    var pitchPreference = NSString()
    var bearing: CLLocationDirection = 0.0
    var movingBearing: CLLocationDirection = 0.0
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0
    var numberOfPathLinks: Int = 0
    var pitch: CGFloat = 0.0
    var motionManager = CMMotionManager()
    var currentMarker: GMSMarker!
    var compassMarker: GMSMarker!
    var headingMarker: GMSMarker!
    var steerlocation_left = CGPoint(x: 0, y: 0)
    var steerlocation_right = CGPoint(x: 0, y: 0)
    var leftView = UIView(frame: CGRectMake(0, 68, 108, 708))
    var rightView = UIView(frame: CGRectMake(916, 68, 108, 708))
    let steer = UIImage(named: "mapXplorer_steer~ipad.png")
    var leftSteer = UIImageView(frame: CGRectMake(5, 286, 100, 100))
    var rightSteer = UIImageView(frame: CGRectMake(5, 286, 100, 100))
    var leftPanTranslationY:CGFloat = 0
    var rightPanTranslationY:CGFloat = 0
    var autoRotateStreetViewButton: UIBarButtonItem?
    var bearingAddingValue: Float = 0
    var xAccelerationBasis: Double?
    var yAccelerationBasis: Double?
    var zAccelerationBasis: Double?
    var locationDescription = NSString()
    var rightDrivePan:UIPanGestureRecognizer!
    var leftDrivePan:UIPanGestureRecognizer!
    var steerTouch_left=0
    var steerTouch_right=0
    var left_trans:CGFloat=0
    var right_trans:CGFloat=0
    var press=false
    var move_f:CGFloat=0
    var pitch_f:CGFloat=0
    func viewkk(){}
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        
        self.latitude = 25.014496
        self.longitude = 121.541238
        self.bearing = 0
        
        
        self.mapView.myLocationEnabled = self.isUserLocationEnabled
        var selectedLocation = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        self.mapView.animateToLocation(selectedLocation)
        
        
        println("latitude: \(latitude)\nlongitude: \(longitude) ")
        var camera = GMSCameraPosition.cameraWithLatitude(self.latitude,
            longitude:self.longitude, zoom:16)
        self.mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        self.mapView.delegate = self
        
        self.view = self.mapView
        
        self.sendMessage(NSString(format: "Location,%f,%f,%f", self.latitude, self.longitude, self.bearing))
        
        self.mapView.clear()
        
        self.title="MapXplorer Map View"
        //self.motionManager = CMMotionManager()
        self.motionManager.accelerometerUpdateInterval = 0.2
        
        // AUTO ROTATION BUTTON
        autoRotateStreetViewButton = UIBarButtonItem(title: "Start Auto Rotate",  style: .Plain, target: self, action: "toggleAutoRotateStreetView")
        self.navigationItem.rightBarButtonItem = autoRotateStreetViewButton
        
        
        
        
        currentMarker = GMSMarker()
        // LOCATION DESCRIPTION IS ON
        if((self.isLocationDescriptionEnabled) == true){
            //reverse Geocoding
            var error: NSError? = nil
            var currentLocation = CLLocation(latitude: camera.target.latitude, longitude: camera.target.longitude)
            
            var currentGeocoder = CLGeocoder()
            
            currentGeocoder.reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks,error) in
                if (error == nil) {
                    
                    
                    for placemark in placemarks{
                        self.locationDescription = NSString(format: "%@", placemark.name)
                        self.currentMarker.title = NSString(format: "%@", self.locationDescription)
                        self.currentMarker.position = CLLocationCoordinate2DMake(camera.target.latitude, camera.target.longitude)
                        self.currentMarker.snippet =  NSString(format: "%f, %f", camera.target.latitude, camera.target.longitude)
                        self.currentMarker.icon = UIImage(named:"mapXplorer_marker.png")
                        self.currentMarker.map = self.mapView
                        self.mapView.selectedMarker = self.currentMarker
                    }
                    
                }
                else{
                    NSLog("There was a reverse geocoding error\n %@", error.localizedDescription)
                }
            })
            
        }else{
            // location description is off
            self.currentMarker.title = "Current Street Position"
            self.currentMarker.position = CLLocationCoordinate2DMake(camera.target.latitude, camera.target.longitude)
            self.currentMarker.snippet = NSString(format:" %f %f", camera.target.latitude, camera.target.longitude)
            self.currentMarker.icon = UIImage(named:"mapXplorer_marker.png")
            self.currentMarker.map = self.mapView
        }
        
        compassMarker = GMSMarker()
        compassMarker.position = camera.target
        compassMarker.icon = UIImage(named: "mapXplorer_compass.png")
        compassMarker.flat = true
        compassMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        compassMarker.map = mapView
        
        headingMarker = GMSMarker()
        headingMarker.position = camera.target
        headingMarker.icon = UIImage(named: "mapXplorer_heading.png")
        headingMarker.flat = true
        headingMarker.groundAnchor = CGPoint(x: 0.5,y: 0.5)
        headingMarker.map = mapView
        
        leftView.backgroundColor=UIColor.lightGrayColor()
        leftView.layer.cornerRadius=25
        leftView.layer.borderWidth=2
        leftView.alpha=0.2
        mapView.addSubview(leftView)
        rightView.backgroundColor=UIColor.lightGrayColor()
        rightView.layer.cornerRadius=25
        rightView.layer.borderWidth=2
        rightView.alpha=0.2
        mapView.addSubview(rightView)
        leftSteer.image=steer
        leftView.addSubview(leftSteer)
        rightSteer.image=steer
        rightView.addSubview(rightSteer)
        leftDrivePan=UIPanGestureRecognizer(target:self, action: "handleLeftPitchPan:")
        rightDrivePan=UIPanGestureRecognizer(target:self, action: "handleRightPitchPan:")
        rightDrivePan.delegate=self
        leftDrivePan.delegate=self
        
        self.leftView.addGestureRecognizer(leftDrivePan)
        self.rightView.addGestureRecognizer(rightDrivePan)
        
        
        
        func resetLocation(coordinate:CLLocationCoordinate2D){
            
            //currentLocation:CLLocation
            var currentLocation=CLLocation(latitude: coordinate.latitude,longitude: coordinate.longitude)
            var currentGeocoder=CLGeocoder()
            // currentGeocoder.reverseGeocodeLocation(currentLocation, completionHandler: completionHandler)
            
        }
        
        func didLongPressAtCoordinate(mapView:GMSMapView , coordinate:CLLocationCoordinate2D){
            //self.resetLocation(coordinate)
        }
        //heading marker
        // street and pinch gesture area view
        
        
        
        // not yet finish
        
        
        // Do any additional setup after loading the view.
    }
    func gestureRecognizer(leftDrivePan: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer rightDrivePan: UIGestureRecognizer) -> Bool{
            return true
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch:UITouch!=touches.anyObject() as UITouch
        if(touch.view==self.leftView){
            steerTouch_left=1
            steerlocation_left=touch.locationInView(leftView)
            leftSteer.center.y=steerlocation_left.y
            println("left touch")
            if(steerTouch_right==1){
                if (self.isInAutoRotationMode) {
                    self.toggleAutoRotateStreetView()    // Turn off auto rotation when user press both buttons
                }
                justInitiated=true
                self.sendMessage("OnPanTouchBegan")
                left_trans=leftSteer.center.y-336
                right_trans=rightSteer.center.y-336
                self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {
                    (accelData: CMAccelerometerData!, error: NSError!) in
                    self.doAcceleration(accelData.acceleration)
                })
                self.doMove()
                self.doPitch()
                
            }
        }else if(touch.view==self.rightView){
            steerTouch_right=1
            steerlocation_right=touch.locationInView(rightView)
            rightSteer.center.y=steerlocation_right.y
            println("right touch")
            
            if(steerTouch_left==1){
                if (self.isInAutoRotationMode) {
                    self.toggleAutoRotateStreetView()    // Turn off auto rotation when user press both buttons
                }
                justInitiated=true
                self.sendMessage("OnPanTouchBegan")
                left_trans=leftSteer.center.y-336
                right_trans=rightSteer.center.y-336
                
                self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {
                    (accelData: CMAccelerometerData!, error: NSError!) in
                    self.doAcceleration(accelData.acceleration)
                })
                self.doMove()
                self.doPitch()
            }
        }else{
            self.sendMessage("OnMapTouchBegan")
        }
        /*if((steerTouch_left+steerTouch_right)==2){
        self.domove()
        }*/
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var touch:UITouch!=touches.anyObject() as UITouch
        if(touch.view==self.leftView || touch.view==self.rightView){
            self.sendMessage("OnPanTouchEnd")
            left_trans=0
            right_trans=0
            self.motionManager.stopAccelerometerUpdates()
            self.rotationTimer.invalidate()
            self.movingTimer.invalidate()
            self.pitchTimer.invalidate()
            self.sendMessage("ResetPitch")
            self.pitch=0
            self.isInDriving=false
            self.isInPitching=false
            if(touch.view==self.leftView){
                steerTouch_left=0
                leftSteer.center.y=336
            }else if(touch.view==self.rightView){
                steerTouch_right=0
                rightSteer.center.y=336
            }
            
        }else{
            self.sendMessage("OnMapTouchEnd")
        }
    }
    func handleLeftPitchPan(event:UIPanGestureRecognizer){
        
        //var translation=event.translationInView(self.leftView)
        /*if(event.state == UIGestureRecognizerState.Ended){
        steerTouch_left=0
        println("left end")
        }
        
        
        
        if(event.state == UIGestureRecognizerState.Began){
        self.steerTouch_left=1
        println("left began")
        if(self.rightDrivePan.state == UIGestureRecognizerState.Began ||
        self.rightDrivePan.state==UIGestureRecognizerState.Changed){
        //leftSteer.center.y+=translation.y
        self.domove()
        self.dopitch()
        println("Left first")
        }
        }
        
        
        if(event.state == UIGestureRecognizerState.Cancelled ||
        event.state == UIGestureRecognizerState.Ended ||
        event.state == UIGestureRecognizerState.Failed){
        leftPanTranslationY=0
        leftSteer.center.y=336
        }*/
    }
    func handleRightPitchPan(event:UIPanGestureRecognizer){
        
        /*  if(event.state == UIGestureRecognizerState.Ended){
        steerTouch_right=0
        }
        
        
        //var translation=event.translationInView(self.rightView)
        if(event.state == UIGestureRecognizerState.Began){
        self.steerTouch_right=1
        
        if(self.leftDrivePan.state == UIGestureRecognizerState.Began ||
        self.leftDrivePan.state == UIGestureRecognizerState.Changed){
        self.domove()
        self.dopitch()
        println("Right first")
        }
        }
        
        
        if(event.state == UIGestureRecognizerState.Cancelled ||
        event.state == UIGestureRecognizerState.Ended ||
        event.state == UIGestureRecognizerState.Failed){
        rightPanTranslationY=0
        rightSteer.center.y=336
        
        }*/
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        self.prefersStatusBarHidden()
        //        googleMap.myLocationEnabled = self.isUserLocationEnabled
        self.justInitiated = false
        self.isInDriving = false
        self.isInPitching = false
        
        //      var selectedLocation = CLLocationCoordinate2D(latitude: self.latitude,longitude: self.longitude)
        
        //      googleMap.animateToLocation(selectedLocation)
        //  self.navigationItem.rightBarButtonItem
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        if((self.isInAutoRotationMode) == true){
            self.toggleAutoRotateStreetView()
        }
    }
    
    
    //  mark - GMSMapViewDelegate
    
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.resetLocation(coordinate)
        if self.isNorthDependent == true{
            self.bearing = 0
            mapView.animateToBearing(self.bearing)
        }
        // Sending location over bonjour network
        
        self.sendMessage(NSString(format: "Location,%f,%f,%f", coordinate.latitude,
            coordinate.longitude,
            self.bearing))
        
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        
        if self.bearing != position.bearing{
            self.bearing = position.bearing
            headingMarker.rotation = self.bearing
            self.sendMessage(NSString(format: "Bearing,%f", self.bearing))
        }
        
    }
    
    
    func resetLocation(coordinate: CLLocationCoordinate2D){
        
        if self.isLocationDescriptionEnabled == true{
            // Reverse Geocoding
            var currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            var currentGeocoder = CLGeocoder()
            
            currentGeocoder.reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) in
                if error == nil{
                    for placemark in placemarks{
                        self.locationDescription = NSString(format: "%@", placemark.name)
                        self.currentMarker.title = NSString(format: "%@", self.locationDescription)
                        self.currentMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
                        self.currentMarker.snippet =  NSString(format: "%f, %f", coordinate.latitude, coordinate.longitude)
                        self.currentMarker.icon = UIImage(named: "mapXplorer_marker.png")
                        self.currentMarker.map = self.mapView
                        self.mapView.selectedMarker = self.currentMarker
                    }
                }else{
                    NSLog("There was a reverse geocoding error\n%@",error.localizedDescription)
                }
            })
        }else{
            
            self.currentMarker.title = "Current Street Position"
            self.currentMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
            self.currentMarker.snippet = NSString(format: "%f, %f", coordinate.latitude, coordinate.longitude)
            self.currentMarker.icon = UIImage(named: "mapXplorer_marker.png")
            self.currentMarker.map = mapView
        }
        //        heading marker
        headingMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        
        //        compass marker
        compassMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        
        if (self.isInDriving == true && self.isRouterOriented == true) || self.isInJumping == true{
            
            mapView.animateToLocation(coordinate)
            mapView.animateToBearing(self.movingBearing)
        }
        // Terminate jump when intersection is found
        if self.isInJumping == true && self.numberOfPathLinks > 2{
            self.isInJumping = false
        }
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    //     end of reset location-----------------------------------------
    
    
    //   Messaging Protocol ----------------------------------------------
    func sendMessage(stringMessage: NSString){
        var data = stringMessage.dataUsingEncoding(NSUTF8StringEncoding)
        var error: NSError?
        self.server?.sendData(data, error:&error)
        
    }
    
    //   protocol complete------------------------------------------
    
    func doAcceleration(acceleration: CMAcceleration){
        // FOR WHETHER MOVING OR PITCHING
        print(acceleration.z)
        if self.isInDriving == false && self.isInPitching == false{
            
            if acceleration.z < 0.7{
                print("acc_move")
                self.isDeviceLaying = true
                self.leftSteer.image = UIImage(named: "mapXplorer_steer~ipad.png")
                self.rightSteer.image = UIImage(named: "mapXplorer_steer~ipad.png")
                
            }else{
                print("acc_pitch")
                self.isDeviceLaying = false
                self.leftSteer.image = UIImage(named: "mapXplorer_steerPitch~ipad.png")
                self.rightSteer.image = UIImage(named: "mapXplorer_steerPitch~ipad.png")
            }
        }
        if fabs(acceleration.z) > kShakingThreshold{
            
            self.sendMessage("Jump")
            self.showNotification("Moving forward to next intersection", type: "info")
            self.isInJumping = true
            right_trans = 0
            self.rightSteer.image = nil
            left_trans = 0
            self.rightSteer.image = nil
            self.sendMessage("ResetPitch")
            self.pitch = 0
            self.rotationTimer.invalidate()
            self.movingTimer.invalidate()
            self.pitchTimer.invalidate()
            self.motionManager.stopAccelerometerUpdates()
            
        }
        if justInitiated == true{
            justInitiated = false
            xAccelerationBasis = acceleration.x
            yAccelerationBasis = acceleration.y
            zAccelerationBasis = acceleration.z
            //             SET SIDE VIEW AREA PICTURES
            
            //   self.leftSteer.frame = CGRectMake(self.leftSteer.frame.origin.x, lef, <#width: CGFloat#>, <#height: CGFloat#>)
            //            right image view ...
            self.leftSteer.image = UIImage(named: "mapXplorer_steer~ipad.png")
            self.rightSteer.image = UIImage(named: "mapXplorer_steer~ipad.png")
            
        }
        
        //        For Rotation
        var cosinusXY: Double = (xAccelerationBasis!*acceleration.x+yAccelerationBasis!*acceleration.y)/(sqrt(xAccelerationBasis!*xAccelerationBasis!+yAccelerationBasis!*yAccelerationBasis!)*sqrt(acceleration.x*acceleration.x+acceleration.y*acceleration.y))
        
        var angleXY = acosf(Float(cosinusXY))
        // Turn off auto rotation if it is ON
        
        
        if self.isInAutoRotationMode == true{
            self.toggleAutoRotateStreetView()
        }
        if angleXY > 0.2{
            if (acceleration.y > 0) {
                // RIGHT ROTATION
                bearingAddingValue = angleXY*10; // We put a constant of 10,
                // So the lowest speed will be 1.5 degree/0.2 seconds
                // Or in the other word: 7.5 degree/second
                self.doRotation()
            }
            else if (acceleration.y < 0) {
                // LEFT ROTATION
                bearingAddingValue = -(angleXY*10);  // We put a constant of 10,
                // So the lowest speed will be 1.5 degree/0.2 seconds
                // Or in the other word: 7.5 degree/second
                self.doRotation()
            }
        }else {
            rotationTimer.invalidate()
        }
    }
    //    end of doAcceleration---------------------------------
    
 
    func doMove(){
        
        var movingTranslation: CGFloat
        self.left_trans=leftSteer.center.y-336
        self.right_trans=rightSteer.center.y-336
        //println("domove!")
        
        if(left_trans > right_trans){
            movingTranslation = left_trans
        }else{
            movingTranslation = right_trans
        }
        
        
        if(left_trans * right_trans > 0 &&
            fabs(left_trans) > self.view.bounds.height/10 &&
            fabs(right_trans) > self.view.bounds.height/10 &&
            self.isDeviceLaying == true &&
            self.isInPitching == false){
                //println("domove!!")
                
                //            intersection checking
                if(self.numberOfPathLinks > 2 && self.isIntersectionAwared == true){
                    self.leftSteer.image = UIImage(named: "mapXplorer_steer~ipad.png")
                    self.rightSteer.image = UIImage(named: "mapXplorer_steer~ipad.png")
                    left_trans = 0
                    right_trans=0
                    leftSteer.center.y=336
                    rightSteer.center.y=336
                    
                    
                    
                    
                    //           about gesture .............
                    
                    
                    self.motionManager.stopAccelerometerUpdates()
                    self.rotationTimer.invalidate()
                    self.pitchTimer.invalidate()
                    self.movingTimer.invalidate()
                    self.sendMessage("ResetPitch")
                    self.pitch = 0
                    self.isInDriving = false
                    self.isInPitching = false
                    self.numberOfPathLinks = -1
                    self.showNotification("Arrived on an intersection", type: "info")
                    
                }else{
                    if(self.pitch != 0){
                        self.pitch = 0
                        self.sendMessage("ResetPitch")
                    }
                    
                    self.isInDriving = true
                    if(movingTranslation < 0){
                        self.sendMessage("Forward")
                    }else if(movingTranslation > 0){
                        self.sendMessage("Backward")
                    }
                    
                     //move_f = self.view.bounds.size.height/fabs(movingTranslation)/CGFloat(self.drivingAccelerationLevel)
                    
                    move_f=CGFloat(1/self.drivingAccelerationLevel)
                    NSLog("interval = %f", Float(move_f))
                    
                    
                    //self.movingTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval:f, target: self, selector: "doMove", userInfo: nil, repeats: false)
                    //self.movingTimer = NSTimer(timeInterval:0.5, target: self, selector: "domove", userInfo: nil, repeats: false)
                    self.movingTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "doMove", userInfo: nil, repeats: false)

                    
                }
        }else{
            self.isInDriving = false
            // DEFAULT SPEED FOR NEXT TIMER CHECKING = 0.5 second
            self.movingTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "doMove", userInfo: nil, repeats: false)
        }
    }
    //    end of doMove___________________________________
    func doPitch(){
        print("dopitch!")
        var pitchTranslation = CGFloat()
        if(left_trans > right_trans){
            pitchTranslation = left_trans
        }else if(left_trans < right_trans){
            pitchTranslation = right_trans
        }
        
        if(self.pitchPreference.isEqualToString("Velocity")){
            
            if(left_trans * right_trans > 0 &&
                self.isDeviceLaying == false &&
                self.isInDriving == false &&
                fabs(left_trans) > self.view.bounds.height/10 &&
                fabs(right_trans) > self.view.bounds.height/10){
                    print("dopitch_velo")

                    self.isInPitching = true
                    
                    if pitchTranslation < 0 && self.pitch < -89.8{
                        self.pitch += 0.2
                    }else if pitchTranslation > 0 && self.pitch > 39.8{
                        self.pitch -= 0.2
                    }
                    
                    self.sendMessage(NSString(format: "Pitch,%f", self.pitch))
                    pitch_f = self.view.bounds.size.height/fabs(pitchTranslation)/300
                    self.pitchTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "doPitch", userInfo: nil, repeats: false)
                    
            }else{
                
                // DEFAULT SPEED FOR NEXT TIMER CHECKING = 0.5 second
                self.isInPitching = false
                self.pitchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "doPitch", userInfo: nil, repeats: false)
            }
        }else if self.pitchPreference.isEqualToString("Position"){
            print("dopitch_pos")

            if self.isDeviceLaying == false && self.isInDriving == false{
                
                if left_trans * right_trans > 0{
                    //                    remain incompelte
                    self.sendMessage(NSString(format: "Pitch, %f", self.pitch))
                }
                if fabs(left_trans) > self.view.bounds.size.height/10 &&
                    fabs(right_trans) > self.view.bounds.size.height/10 {
                        self.isInPitching = true
                }
                else {
                    self.isInPitching = false
                }
                
                self.pitchTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "doPitch", userInfo: nil, repeats: false)
            }
        }else{
            print("dopitch_nothing")

        }
    }
    //    end of doPitch
    func doRotation(){
        
        if(self.isInDriving == false){
            self.bearing += CLLocationDirection(bearingAddingValue)
        }
        mapView.animateToBearing(self.bearing)
        
    }
    
    
    //    pragma mark Additional Features   ------------------------------        finished!!
    func toggleAutoRotateStreetView(){
        
        println("this is sparta")
        if (self.isInAutoRotationMode) {
            self.isInAutoRotationMode = false
        }else{
            self.isInAutoRotationMode = true
        }
        
        if(self.isInAutoRotationMode){
            self.autoRotateStreetViewButton?.title = "Stop Auto Rotate"
            self.bearingAddingValue = 1.5
            self.autoRotationTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("doRotation"), userInfo: nil, repeats: true)
        }else{
            self.autoRotateStreetViewButton?.title = "Start Auto Rotate"
            self.autoRotationTimer.invalidate()
        }
    }
    
    func showNotification(notification: NSString, type: NSString){
        if(type.isEqualToString("info")){
            self.view.makeToast(message: notification, duration: 2.0, position: "bottom", image: UIImage(named: "info.png")!)
        }
        
        self.sendMessage(NSString(format: "Notification,%@",notification))
        
    }
    //--------------------------------------------------------------------
    
    
    
    
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 2
        if status == .AuthorizedWhenInUse {
            
            // 3
            locationManager.startUpdatingLocation()
            
            //4
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    // 5
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            
            // 6
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // 7
            locationManager.stopUpdatingLocation()
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    //    pragma mark - GMSMapViewDelegate
    
    
    
    
    
    
}
