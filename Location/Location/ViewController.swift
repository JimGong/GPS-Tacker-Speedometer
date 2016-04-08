//
//  ViewController.swift
//  Location
//
//  Created by JiaMin Gong on 4/5/16.
//  Copyright © 2016 JiaMin Gong. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
import AVFoundation

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var myButtom: UIButton!
    
    @IBOutlet weak var myGPS: UILabel!
    let locationManager=CLLocationManager()
    let motionManager = CMMotionManager()
    
    var firstTime=true;
    var audioPlayer: AVAudioPlayer!
    
    var prevSpeed: Double=0.0
    var maxSpeed: Double=0.0
    var avgSpeed: Double=0.0
    var curG: Double=0.0
    var maxG: Double=0.0
    
    var prevSound:String = "";
    
    var startLocation: CLLocation!
    var endLocation: CLLocation!
    
    var startTime = NSDate()
    var endTime = NSDate()
    
    @IBAction func startOrStop(sender: UIButton) {
        if(myButtom.titleLabel!.text==("Start")){
            playSound("EngineStart-music")
            
            myButtom.setTitle("Counting Down...Get Ready...", forState: UIControlState.Normal);
            maxSpeed=0.0
            avgSpeed=0.0
            curG=0.0
            maxG=0.0;
            myLabel.text = String(format: "Cur Speed: %.2f mph\n\nMax Speed: %.2f mph\n\nAvg Speed: %.2f mph\n\nCur G value: %.2f\n\nMax G value: %.2f", 0, 0, 0,0, 0);
            
            self.callForWait(9)
        }else{
            //stop tracking location.
            
            audioPlayer.stop();
            
            firstTime=true;
            
            locationManager.stopUpdatingLocation()
            
            motionManager.stopAccelerometerUpdates()
            
            //            print("just stopped tracking location")
            
            endTime = NSDate();
            
            //            print("end time: ",endTime);
            
            let duration: Double = endTime.timeIntervalSinceDate(startTime);
            //            print("duriation: ",duration);
            
            endLocation=locationManager.location
            
            var totalDistance=0.0;
            if(endLocation != nil){
                totalDistance = endLocation.distanceFromLocation(startLocation)
            }
            
            myLabel.text = String(format: "Max Speed: %.2f mph\n\nAvg Speed: %.2f mph\n\nMax G value: %.2f\n\nDuration: %.2f s\n\nTotal Distance: %.2f miles", maxSpeed*2.237, avgSpeed*2.237,maxG, duration, totalDistance/1000*0.6213)
            
            myButtom.setTitle("Start", forState: UIControlState.Normal)
            
        }
    }
    
    func callForWait(seconds: Double){
        //setting the delay time 60secs.
        let delay = seconds * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            //call the method which have the steps after delay.
            self.stepsAfterDelay()
        }
    }
    
    func stepsAfterDelay(){
        //your code after delay takes place here...
        //start tracking location.
        locationManager.startUpdatingLocation()
        startLocation=locationManager.location;
        //        print(startLocation);
        //        print("just started tracking location")
        startTime = NSDate();
        //        print("started time: ",startTime)
        
        myButtom.setTitle("End", forState: UIControlState.Normal);
    }
    
    
    func playSound(fileName: String){
        let audioFilePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "mp3",inDirectory: "Supporting Files")
        
        //        print(audioFilePath)
        //        print("trying to play ",fileName);
        
        if audioFilePath != nil {
            //                print("in Here")
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            //            print("url",audioFileUrl)
            
            //            print("last sound done.")
            //            print("firstTime", firstTime);
            
            if((audioPlayer==nil)==false &&  (audioPlayer.playing==true)){
                if(soundHasChanges(prevSound, b: fileName)==true){
                    do{
                        audioPlayer = try AVAudioPlayer(contentsOfURL: audioFileUrl, fileTypeHint: nil)
                        print("cur playing: ", prevSound)
                        print("try play: ", fileName);
                        audioPlayer.play()
                        //                audioPlayer.volume=0.1
                        //                print("music played");
                        
                    }catch{
                        //                    print(exception)
                        print("error")
                        return;
                    }
                }else{
                    print("same", fileName)
                }
            } else {
                print("firstTime")
                do{
                    audioPlayer = try AVAudioPlayer(contentsOfURL: audioFileUrl, fileTypeHint: nil)
                    print("new sound: ", fileName);
                    audioPlayer.play()
                    //                audioPlayer.volume=0.1
                    //                print("music played");
                    
                }catch{
                    //                    print(exception)
                    print("error")
                    return;
                }
                
            }
        }else{
            print("audio file is not found", fileName);
        }
        prevSound = fileName;
    }
    
    func soundHasChanges(a:String, b:String)->Bool{
        if(a==b){
            
            return false;
        }else{
            return true;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate=self
        
        
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        myGPS.backgroundColor=UIColor.grayColor();
        
        //        myLabel.text = String(format: "Max Speed: %.0f km/h", 0 * 3.6)
        myLabel.text = String(format: "Cur Speed: %.2f mph\n\nMax Speed: %.2f mph\n\nAvg Speed: %.2f mph\n\nCur G value: %.2f\n\nMax G value: %.2f", 0, 0, 0,0, 0);
        //        self.locationManager.startUpdatingLocation()
        
        //        locationManager.startMonitoringSignificantLocationChanges()
        
        //        print("start updating location");
        
        self.mapView.showsUserLocation=true;
        //        print("show user location")
        
        motionManager.accelerometerUpdateInterval=0.01
        
    }
    
    func outputAccData(acceleration: CMAcceleration){
        //        maxG = acceleration.y
        curG = acceleration.y
        let absCurG=abs(curG);
        if(absCurG>maxG){
            maxG=absCurG;
        }
        
    }
    
    func abs(a:Double)->Double{
        if(a<0){
            return -a
        }
        return a;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager,didUpdateLocations locations: [CLLocation]){
        //        print("function get called")
        let location=locations.last
        //        print(locations.description);
        //        print(motionManager.accelerometerAvailable)
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            self.outputAccData(accelerometerData!.acceleration)
            //            maxG=accelerometerData.y;
            if(NSError != nil) {
                print("\(NSError)")
            }
        }
        
        var speed: CLLocationSpeed = CLLocationSpeed()
        speed = locationManager.location!.speed
        speed = abs(speed);
        //        print("speed",speed);
        
        let curTime = locationManager.location!.timestamp
        //        print("time", curTime)
        
        var tmpDuration = curTime.timeIntervalSinceDate(startTime);
        if (tmpDuration<0) {
            tmpDuration = -tmpDuration;
        }
        //        tmpDuration
        //        print("tempDuration", tmpDuration);
        //        print(startLocation)
        let curDistance = startLocation!.distanceFromLocation(location!);
        //        print("curDistance", curDistance);
        
        avgSpeed=curDistance/tmpDuration;
        //        print("avg Speed", avgSpeed)
        //        audioPlayer.stop();
        //        if(speed<=50 && firstTime==false){
        //            print("play idle")
        //            playSound("Idle-music")
        //        }
        
        let speedDiff=speed-prevSpeed;
        print("speedDeff", speedDiff);
        
        firstTime=false;
        
        if(speedDiff>0){
            //accelerate
            
            statusLabel.text="Speed up"
            print("SpeedUp")
            playSound("Acceleration-music")
        }else if(speedDiff==0){
            if(speed<5*2.237){
                // idle
                print("idle")
                statusLabel.text="IDLE"
                playSound("Idle-music")
            }else{
                // drive smoothly.
                statusLabel.text="Drive smoothly"
                print("dive smoothly");
                //                playSound("SmoothAcc-music")
            }
        }else{
            // decelerate
            statusLabel.text="Decelerate"
            print("decelerate")
            playSound("Idle-music")
        }
        
        prevSpeed = speed;
        
        if(speed>maxSpeed){
            maxSpeed=speed
        }
        if(avgSpeed>maxSpeed){
            avgSpeed=maxSpeed
        }
        
        myLabel.text = String(format: "Cur Speed: %.1f mph\n\nMax Speed: %.1f mph\n\nAvg Speed: %.1f mph\n\nCur G value: %.1f\n\nMax G value: %.1f", speed*2.237, maxSpeed*2.237, avgSpeed*2.237,curG, maxG);
        
        if(location?.horizontalAccuracy<0){
            //            print("no signal")
            myGPS.backgroundColor = UIColor.redColor()
            
        }else if (location?.horizontalAccuracy > 163)
        {
            // Poor Signal
            myGPS.backgroundColor = UIColor.yellowColor()
            
        }
        else if (location?.horizontalAccuracy > 48)
        {
            // Average Signal
            myGPS.backgroundColor = UIColor.cyanColor()
        }
        else
        {
            // Full Signal
            myGPS.backgroundColor = UIColor.greenColor()
        }
        
        let center=CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        
        //        print("latitude: %d,", location!.coordinate.latitude);
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.001))
        
        self.mapView.setRegion(region, animated: true)
        
        //        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription);
    }
    
}

