//
//  ViewController.swift
//  FinalProject
//
//  Created by Ying-Kai Huang on 12/25/14.
//  Copyright (c) 2014 NTUST. All rights reserved.
//

import UIKit

class BrowserViewController: UITableViewController {

    @IBOutlet weak var label_acceleration_level: UILabel!
    @IBOutlet weak var stepper_acceleration: UIStepper!
//  button and switch
    var service = NSMutableArray()
    var server:  Server?
    var selectedSpotIndex: Int?
    var userLocationSwitch = UISwitch()
    var userLocationLabel = UILabel()
    var locationDescriptionSwitch = UISwitch()
    let locationDescriptionLabel = UILabel()
    var routeOrientationSwitch = UISwitch()
    let routeOrientationLabel = UILabel()
    var northDependentSwitch = UISwitch()
    let northDependentLabel = UILabel()
    var intersectionAwaredSwitch = UISwitch()
    let intersectionAwaredLabel = UILabel()
    var drivingAccelerationStepper = UIStepper()
    var drivingAccelerationLevelLabel = UILabel()
    let pitchPreferenceLabel = UILabel()
    let startButton = UIButton()
    let pitchPreferenceSegmentedControl = UISegmentedControl(items: ["Velocity ","Position"])
    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let firstFooterView:UIView?

    
    
// ---------------------
    
    
    var items: [String] = ["test"]
    var spotName:[NSString]=[
    "NCTU (front gate), Hsinchu, Taiwan",
    "Hsinchu Train Station",
    "National Palace Museum (inside), Taipei, Taiwan",
    "Chiang Kai-Shek Memorial Hall, Taipei, Taiwan",
    "Sendai Train Station (Front Gate), Sendai, Japan",
    "Taichung Train Station (Front Gate), Taichung, Taiwan",
    "Harajuku Train Station (Front Gate), Tokyo, Japan",
    "Ximen MRT Station (Exit 3), Taipei, Taiwan"
    ]
    
    var spotPosition=[
        NSValue(CGPoint: CGPoint(x: 24.789426, y: 121.000081)),
        NSValue(CGPoint: CGPoint(x:24.801643, y:120.971696)),
        NSValue(CGPoint: CGPoint(x:25.102205, y:121.548571)),
        NSValue(CGPoint: CGPoint(x:25.035447, y:121.520226)),
        NSValue(CGPoint: CGPoint(x:38.261447,y:140.881637)),
        NSValue(CGPoint: CGPoint(x:24.136973,y:120.684836)),
        NSValue(CGPoint: CGPoint(x:35.670264,y:139.702863)),
        NSValue(CGPoint: CGPoint(x:25.041982,y:121.508749))
    ]
    
    
override func viewDidLoad() {
        super.viewDidLoad()
//        stepper_acceleration.minimumValue=1
//        stepper_acceleration.maximumValue=6
//        stepper_acceleration.stepValue=1
//        stepper_acceleration.value=2
//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.title = "MapXplorer Setting"
       
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        var bounds: CGRect = UIScreen.mainScreen().bounds
        var width:CGFloat = bounds.size.width
        var height:CGFloat = bounds.size.height
        
        var xleft: CGFloat
        var xright: CGFloat
        var ytop: CGFloat
        
        if(UIDevice.currentDevice().userInterfaceIdiom == .Phone){
            xleft = 14
            xright = width-92
            ytop = 0
            print("phone2")
            startButton.frame = CGRectMake(14, 340, tableView.frame.size.width-30, 44)
            startButton.titleLabel?.font = UIFont.boldSystemFontOfSize(20)
        }else {
            xleft = 60
            xright = 895
            ytop = 40
            print("pad2")
            startButton.frame = CGRectMake(60, 380, tableView.frame.size.width-120, 44)
            startButton.titleLabel?.font = UIFont.boldSystemFontOfSize(20)
            
        }
        
        userLocationSwitch.frame = CGRectMake(xright, 40+ytop, 0, 0)
        userLocationLabel.frame = CGRectMake(xleft, 40+ytop, 600, 29)
        locationDescriptionSwitch.frame = CGRectMake(xright, 80+ytop, 0, 0)
        locationDescriptionLabel.frame = CGRectMake(xleft, 80+ytop, 600, 29)
        routeOrientationSwitch.frame = CGRectMake(xright, 120+ytop, 0, 0)
        routeOrientationLabel.frame = CGRectMake(xleft, 120+ytop, 600, 29)
        northDependentSwitch.frame = CGRectMake(xright, 160+ytop, 0, 0)
        northDependentLabel.frame = CGRectMake(xleft, 160+ytop, 600, 29)
        intersectionAwaredSwitch.frame = CGRectMake(xright, 200+ytop, 0, 0)
        intersectionAwaredLabel.frame = CGRectMake(xleft, 200+ytop, 600, 29)
        drivingAccelerationStepper.frame = CGRectMake(xright-40, 240+ytop, 0, 0)
        drivingAccelerationLevelLabel.frame = CGRectMake(xleft, 240+ytop, 600, 29)
        pitchPreferenceLabel.frame = CGRectMake(xleft, 280+ytop, 500, 29)
        pitchPreferenceSegmentedControl.frame = CGRectMake(xright-120, 280+ytop, 200, 30)
        drivingAccelerationStepper.maximumValue=6
        drivingAccelerationStepper.minimumValue=1
        drivingAccelerationStepper.addTarget(self, action: "stepperValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        

    
    
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        selectedSpotIndex = -1
        self.startButton.setTitle("Click Here to Go Back to the Map", forState: UIControlState.Normal)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
//    -----------------------------------
    
    func services() -> NSMutableArray{
        
        return self.service
        
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView)-> Int
    {
            return 2
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        var section_title:NSString?
        if (section == 0){

            if(self.service.count>0){
                println("count:\(self.service.count)")
                section_title="Select Available Services:"
            }else{
                section_title="- None of Service is Available -"
            }
            
        }
        else if(section==1 && self.appDelegate.isConnectedToServer()){
            
            section_title = "Select Initial Location:"
        }
        println(section_title)

        return section_title
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section==0){
            return service.count
        }else if(section==1 && self.appDelegate.isConnectedToServer()){
            return spotName.count
        }else{
            return 0
        }
    }
    override func tableView(tableView: UITableView,
        heightForFooterInSection section: Int) -> CGFloat{
            if(section==0){
                return 410
            }else{
                return 0
            }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        if(indexPath.section==0){
            cell.textLabel?.text = self.service[indexPath.row].name
            
        }else if(indexPath.section==1 && self.appDelegate.isConnectedToServer()){
            cell.textLabel?.text = self.spotName[indexPath.row]
            
        }
        
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section==0){
            self.server?.connectToRemoteService(self.service.objectAtIndex(indexPath.row) as NSNetService)
        }else if(indexPath.section==1 && self.appDelegate.isConnectedToServer()){
            selectedSpotIndex=indexPath.row
            //self.appDelegate.setLatitude(latitude:self.spotPosition[indexPath.row].CGPointValue().x, longitude: self.spotPosition[indexPath.row].CGPointValue().y)
        }
    }
    override func tableView(tableView: UITableView,
        viewForFooterInSection section: Int) -> UIView?{
            if(section==0){
                if(firstFooterView==nil){
                    
                    // START BUTTON
                    
                    var activeImage = UIImage(named: "button_green.png")?.stretchableImageWithLeftCapWidth(8, topCapHeight: 8)
                    
                    self.startButton.setBackgroundImage(activeImage, forState: .Normal)
                    self.startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    self.startButton.setTitle("Click Here to Start the Map", forState: .Normal)
                    
                    var clickImage = UIImage(named: "button_grey_dark.png")?.stretchableImageWithLeftCapWidth(8, topCapHeight: 8)
                    self.startButton.setBackgroundImage(clickImage, forState: .Highlighted)
                    self.startButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
                    self.startButton.setTitle("Now is Loading the Map ...", forState: .Highlighted)
                    
                    var inactiveImage = UIImage(named: "button_grey_light.png")?.stretchableImageWithLeftCapWidth(8, topCapHeight: 8)
                    
                    self.startButton.setBackgroundImage(inactiveImage, forState: .Disabled)
                    self.startButton.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
                    self.startButton.setTitle("None of Service is Selected", forState: .Disabled)
                    self.startButton.addTarget(self, action: "startMap:", forControlEvents: .TouchUpInside)
                    self.startButton.enabled = true//self.appDelegate.isConnectedToServer()
                    self.startButton.addTarget(self, action: "showMapView", forControlEvents: .TouchUpInside)
                    
                    
                    // LOCATION DESCRIPTION LABEL
                    self.locationDescriptionLabel.text = "Show Street Location Description"
                    self.locationDescriptionLabel.font = UIFont.boldSystemFontOfSize(18.0)
                    self.locationDescriptionLabel.textAlignment = .Left
                    self.locationDescriptionLabel.backgroundColor = UIColor.clearColor()
                    self.locationDescriptionLabel.layer.shadowColor = UIColor.whiteColor().CGColor
                    self.locationDescriptionLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0)
                    self.locationDescriptionLabel.layer.shadowOpacity = 1.0
                    self.locationDescriptionLabel.layer.shadowRadius = 0.0
                    //        [self.firstFooterView addSubview:self.locationDescriptionLabel];
                    
                    // USER LOCATION LABEL
                    self.userLocationLabel.text = "Show Real Current Location";
                    self.userLocationLabel.font = UIFont.boldSystemFontOfSize(18.0)
                    self.userLocationLabel.textAlignment = .Left
                    self.userLocationLabel.backgroundColor = UIColor.clearColor()
                    self.userLocationLabel.layer.shadowColor = UIColor.whiteColor().CGColor
                    self.userLocationLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0)
                    self.userLocationLabel.layer.shadowOpacity = 1.0
                    self.userLocationLabel.layer.shadowRadius = 0.0
                    //        [self.firstFooterView addSubview:self.userLocationLabel];
                    
                    
                    
                    //         ROUTE ORIENTED LABEL
                    if(UIDevice.currentDevice().userInterfaceIdiom == .Phone){
                        self.routeOrientationLabel.text = "Route-based Orientation"
                    } else {
                        self.routeOrientationLabel.text = "Adjust Street View Orientation Based on The Driving Route"
                    }
                    self.routeOrientationLabel.font = UIFont.boldSystemFontOfSize(18.0)
                    self.routeOrientationLabel.textAlignment = .Left
                    self.routeOrientationLabel.backgroundColor = UIColor.clearColor()
                    self.routeOrientationLabel.layer.shadowColor = UIColor.whiteColor().CGColor
                    self.routeOrientationLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0)
                    self.routeOrientationLabel.layer.shadowOpacity = 1.0
                    self.routeOrientationLabel.layer.shadowRadius = 0.0
                    //        [self.firstFooterView addSubview:self.routeOrientedLabel];
                    
                    
                    // NORTH DEPENDENT LABEL
                    if(UIDevice.currentDevice().userInterfaceIdiom == .Phone){
                        self.northDependentLabel.text = "North Orientation Priority"
                    } else {
                        self.northDependentLabel.text = "Once Location is Updated Rotate Orientation to North"
                    }
                    
                    self.northDependentLabel.font = UIFont.boldSystemFontOfSize(18.0)
                    self.northDependentLabel.textAlignment = .Left;
                    self.northDependentLabel.backgroundColor = UIColor.clearColor()
                    self.northDependentLabel.layer.shadowColor = UIColor.whiteColor().CGColor
                    self.northDependentLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0)
                    self.northDependentLabel.layer.shadowOpacity = 1.0
                    self.northDependentLabel.layer.shadowRadius = 0.0
                    //        [self.firstFooterView addSubview:self.northDependentLabel];
                    
                    
                    // INTERSECTION AWARE LABEL
                    if(UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
                        println("phone3")
                        self.intersectionAwaredLabel.text = "Intersection Aware Driving"
                    } else {
                        println("phone4")
                        self.intersectionAwaredLabel.text = "Always Stop by at Intersection During The Drive"
                    }
                    self.intersectionAwaredLabel.font = UIFont.boldSystemFontOfSize(18.0)
                    self.intersectionAwaredLabel.textAlignment = .Left
                    self.intersectionAwaredLabel.backgroundColor = UIColor.clearColor()
                    self.intersectionAwaredLabel.layer.shadowColor = UIColor.whiteColor().CGColor
                    self.intersectionAwaredLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0)
                    self.intersectionAwaredLabel.layer.shadowOpacity = 1.0
                    self.intersectionAwaredLabel.layer.shadowRadius = 0.0
                    //        [self.firstFooterView addSubview:self.intersectionAwaredLabel];
                    
                    
                    // PITCH PREFERENCE LABEL
                    self.pitchPreferenceLabel.text = "Pitch Street View Based On "
                    self.pitchPreferenceLabel.font = UIFont.boldSystemFontOfSize(18.0)
                    self.pitchPreferenceLabel.textAlignment = .Left
                    self.pitchPreferenceLabel.backgroundColor = UIColor.clearColor()
                    self.pitchPreferenceLabel.layer.shadowColor = UIColor.whiteColor().CGColor
                    self.pitchPreferenceLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0)
                    self.pitchPreferenceLabel.layer.shadowOpacity = 1.0
                    self.pitchPreferenceLabel.layer.shadowRadius = 0.0
                    //        [self.firstFooterView addSubview:self.pitchPreferenceLabel];
                    
                    // DRIVING ACCELERATION LEVEL LABEL
                    self.drivingAccelerationLevelLabel.text = "Driving Acceleration Level = 0"
                    self.drivingAccelerationLevelLabel.font = UIFont.boldSystemFontOfSize(18.0)
                    self.drivingAccelerationLevelLabel.textAlignment = .Left
                    self.drivingAccelerationLevelLabel.backgroundColor = UIColor.clearColor()
                    self.drivingAccelerationLevelLabel.layer.shadowColor = UIColor.whiteColor().CGColor
                    self.drivingAccelerationLevelLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0)
                    self.drivingAccelerationLevelLabel.layer.shadowOpacity = 1.0
                    self.drivingAccelerationLevelLabel.layer.shadowRadius = 0.0
                    //        [self.firstFooterView addSubview:self.drivingAccelerationLevelLabel];
                    
    //                    location description switch
                    self.locationDescriptionSwitch.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
                    self.locationDescriptionSwitch.addTarget(self, action: "didChangeLocationDescriptionSwitch:", forControlEvents: .ValueChanged)
                    self.locationDescriptionSwitch.on = false
                    self.appDelegate.toggleLocationDescription(false)
                    
                    
//                  user location switch
                    self.userLocationSwitch.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
                    self.userLocationSwitch.addTarget(self, action: "didChangeUserLocationSwitch:", forControlEvents: .ValueChanged)
                    self.userLocationSwitch.on = false
                    self.appDelegate.toggleUserLocation(false)
                    
//                    route oriented switch
                    
                    self.routeOrientationSwitch.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
                    self.routeOrientationSwitch.addTarget(self, action: "didChangeRouteOrientedSwitch:", forControlEvents: .ValueChanged)
                    self.routeOrientationSwitch.on = false
                    self.appDelegate.toggleRouteOriented(false)
                    
//                    north dependent switch
                    self.northDependentSwitch.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
                    self.northDependentSwitch.addTarget(self, action: "didChangeNorthDependentSwitch:", forControlEvents: .ValueChanged)
                    self.northDependentSwitch.on = false
                    self.appDelegate.toggleNorthDependent(false)
                    
//                  intersection aware switch
                    
                    self.intersectionAwaredSwitch.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
                    self.intersectionAwaredSwitch.addTarget(self, action: "didChangeIntersectionAwaredSwitch:", forControlEvents: .ValueChanged)
                    self.intersectionAwaredSwitch.on = false
                    self.appDelegate.toggleIntersectionAwared(false)

                    
                    
                    
                    self.view.addSubview(startButton)
                    self.view.addSubview(userLocationLabel)
                    self.view.addSubview(userLocationSwitch)
                    self.view.addSubview(locationDescriptionSwitch)
                    self.view.addSubview(locationDescriptionLabel)
                    self.view.addSubview(routeOrientationSwitch)
                    self.view.addSubview(routeOrientationLabel)
                    self.view.addSubview(northDependentSwitch)
                    self.view.addSubview(northDependentLabel)
                    self.view.addSubview(intersectionAwaredSwitch)
                    self.view.addSubview(intersectionAwaredLabel)
                    self.view.addSubview(drivingAccelerationLevelLabel)
                    self.view.addSubview(drivingAccelerationStepper)
                    self.view.addSubview(pitchPreferenceLabel)
                    self.view.addSubview(pitchPreferenceSegmentedControl)
                    

                    
                }
            }
            return firstFooterView
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
//    UI handler ------------------------------------
    
    func startMap(sender: AnyObject){
        
        self.startButton.setTitle("Now is Loading the Map ...", forState: UIControlState.Normal)
        self.appDelegate.startMap()
        
    }
    func stepperValueChanged(stepper: UIStepper){
        self.drivingAccelerationLevelLabel.text = "Driving Acceleration Level = \(Int(stepper.value))"
        
    }
    func enableStartButton(sender: AnyObject){
        self.startButton.enabled = true
    }
    
    func disableStartButton(sender: AnyObject){
        self.startButton.enabled = false
    }
    func didChangeUserLocationSwitch(sender: AnyObject){
        self.appDelegate.toggleUserLocation(self.userLocationSwitch.on)
    }
    func didChangeLocationDescriptionSwitch(sender: AnyObject){
        self.appDelegate.toggleLocationDescription(self.userLocationSwitch.on)
    }
    func didChangePitchPreferenceSegmentedControl(sender: AnyObject){
        self.appDelegate.togglePitchPreference(self.pitchPreferenceSegmentedControl.titleForSegmentAtIndex(self.pitchPreferenceSegmentedControl.selectedSegmentIndex)!)
    }
    func didChangeRouteOrientedSwitch(sender: AnyObject){
        self.appDelegate.toggleRouteOriented(self.routeOrientationSwitch.on)
    }
    func didChangeNorthDependentSwitch(sender: AnyObject){
        self.appDelegate.toggleNorthDependent(self.northDependentSwitch.on)
    }
    func didChangeIntersectionAwaredSwitch(sender: AnyObject){
        self.appDelegate.toggleIntersectionAwared(self.intersectionAwaredSwitch.on)
    }
    func drivingAccelerationLevelStepperValueChanged(sender: UIStepper){
        var value = sender.value
        self.drivingAccelerationLevelLabel.text = NSString(format: "Driving Acceleration Level = %d", Int(value))
        self.appDelegate.changeDrivingAccelerationLevel(Int(self.drivingAccelerationStepper.value))
        
    }

    func addService(service: NSNetService, more: Bool){
        
        self.service.addObject(service)
        println("add")
        println(self.service.count)
        if(more == false){
            println("reload")
            dispatch_async(dispatch_get_main_queue(), {
                
               
                self.tableView.reloadData()
                
                // Masquer l'icône de chargement dans la barre de status
            })
        }
    }
    
    func removeService(service: NSNetService, more: Bool){
        
        self.service.removeObject(service)
        if more == false{
            dispatch_async(dispatch_get_main_queue(), {
                
                
                
                self.tableView.reloadData()
                
                // Masquer l'icône de chargement dans la barre de status
            })
        }
    
    }
    func showMapView(){
        
        self.showViewController(self.appDelegate.mapVC, sender: self)
    }
    
 }