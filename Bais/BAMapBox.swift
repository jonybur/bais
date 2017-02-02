//
//  BAMapBox.swift
//  BAIS
//
//  Created by Jonathan Bursztyn on 8/9/16.
//  Copyright © 2016 Bais. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import AwaitKit
import MapKit

class BAMapBox : UIView, MKMapViewDelegate{

	static let mapHeight : CGFloat = 160;
	static let mapWidth : CGFloat = ez.screenWidth - 40;
	let uberButton : ASButtonNode = ASButtonNode();
	let directionsButton : ASButtonNode = ASButtonNode();
	var locationCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2D();
	
	override init (frame : CGRect) {
		super.init(frame : frame);
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("This class does not support NSCoding")
	}
	
	convenience init (coordinate : CLLocationCoordinate2D, yPosition : CGFloat) {
		self.init(frame: CGRect(0, 0, BAMapBox.mapWidth, BAMapBox.mapHeight));
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.showUberOptions(_:)), name: NSNotification.Name(rawValue: uberDownloadedKey), object: nil)
		
		locationCoordinate = coordinate;
		self.layer.cornerRadius = 10;
		self.clipsToBounds = true;
		
		
		let mapView = MKMapView(frame: self.frame);
		let camera = MKMapCamera.init(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 450);
		mapView.setCamera(camera, animated: false);
		mapView.isUserInteractionEnabled = false;
		mapView.showsPointsOfInterest = false;
		mapView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0);

		let annotation = MKPointAnnotation();
		annotation.coordinate = coordinate;
		mapView.addAnnotation(annotation);
		
		self.addSubview(mapView);
		
		setUberButton();
	}
	
	func setUberButton(){
		
		let buttonHeight : CGFloat = 40;
		
		// "Interested" button
		uberButton.frame = CGRect(x: 0, y: self.frame.height - buttonHeight, width: (self.frame.width) / 2 - 1, height: buttonHeight);
		uberButton.addTarget(self, action: #selector(uberButtonPressed(sender:)), forControlEvents: .touchUpInside);
		uberButton.setTitle("Uber", with: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular), with: UIColor.white, for: ASControlState());
		uberButton.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9);
		
		// "Going" button
		directionsButton.frame = CGRect(x: uberButton.frame.maxX + 1, y: self.frame.height - buttonHeight, width: (self.frame.width) / 2, height: buttonHeight);
		directionsButton.addTarget(self, action: #selector(directionsButtonPressed(sender:)), forControlEvents: .touchUpInside);
		directionsButton.setTitle("Directions", with: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular), with: UIColor.white, for: ASControlState());
		directionsButton.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9);
		
		self.addSubnode(uberButton);
		self.addSubnode(directionsButton);
		
	}
	
	func uberButtonPressed(sender: UIButton) {
		
		if (!AppsCommunicator.canOpenUber()){
			let alert = UIAlertController(title: "Uber Not Installed", message: "To use this function please install Uber", preferredStyle: .alert);
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));

			var topVC = UIApplication.shared.keyWindow?.rootViewController;
			while((topVC!.presentedViewController) != nil) {
				topVC = topVC!.presentedViewController;
			}
			topVC?.present(alert, animated: true, completion: nil);

			return;
		}
		
		async{
			CloudController.getUberProducts(self.locationCoordinate);
		}
		
		// animates the check
		let spin = POPSpringAnimation(propertyNamed: kPOPLayerRotation);
		spin?.fromValue = NSNumber(value: M_PI * 1 as Double);
		spin?.toValue = NSNumber(value: 0 as Int32);
		spin?.springBounciness = 5;
		spin?.velocity = NSNumber(value: 5 as Int32);
		self.uberButton.imageNode.pop_add(spin, forKey: "rotateAnimation");
		
	}
	
	func directionsButtonPressed(sender : UIButton){
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet);

		let canOpenWaze : Bool = AppsCommunicator.canOpenWaze();
		let canOpenGoogleMaps : Bool = AppsCommunicator.canOpenGoogleMaps();
		
		if (canOpenWaze || canOpenGoogleMaps){
			
			if (canOpenGoogleMaps){
				alert.addAction(UIAlertAction(title: "Google Maps", style: UIAlertActionStyle.default, handler: { action in
					AppsCommunicator.openGoogleMaps(self.locationCoordinate);
				}));
			}
			alert.addAction(UIAlertAction(title: "Apple Maps", style: UIAlertActionStyle.default, handler: { action in
				AppsCommunicator.openAppleMaps(self.locationCoordinate);
			}));
			if (canOpenWaze){
				alert.addAction(UIAlertAction(title: "Waze Maps", style: UIAlertActionStyle.default, handler: { action in
					AppsCommunicator.openWaze(self.locationCoordinate);
				}));
			}
			
			alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));
			
			var topVC = UIApplication.shared.keyWindow?.rootViewController
			while((topVC!.presentedViewController) != nil) {
				topVC = topVC!.presentedViewController;
			}
			
			topVC?.present(alert, animated: true, completion: nil);
			
		} else {
			
			AppsCommunicator.openAppleMaps(locationCoordinate);
		
		}
		
		// animates the check
		let spring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY);
		spring?.velocity = NSValue(cgPoint: CGPoint(x: 7, y: 7));
		spring?.springBounciness = 20;
		self.directionsButton.imageNode.pop_add(spring, forKey: "sendAnimation");
	}
	
	@objc func showUberOptions(_ notification: Notification){
		
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet);
		
		for product in FetchedContent.uberProducts{
			alert.addAction(UIAlertAction(title: product.displayName, style: UIAlertActionStyle.default, handler: { action in
				AppsCommunicator.openUber(product.productId, dropoff: self.locationCoordinate);
			}));
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));
		
		var topVC = UIApplication.shared.keyWindow?.rootViewController
		while((topVC!.presentedViewController) != nil) {
			topVC = topVC!.presentedViewController;
		}
		
		topVC?.present(alert, animated: true, completion: nil);

		
	}
	
}
