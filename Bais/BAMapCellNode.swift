//
//  BAMapCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 7/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import AsyncDisplayKit
import Foundation
import MapKit

protocol BAMapCellNodeDelegate: class {
	// sets the proper status for event
	func mapCellNodeDidClickUberButton(_ mapViewCell: BAMapCellNode);
	func mapCellNodeDidClickDirectionsButton(_ mapViewCell: BAMapCellNode);
}

class BAMapCellNode: ASCellNode{
	
	var mapView: MKMapView!
	let uberButtonNode = ASButtonNode()
	let directionsButtonNode = ASButtonNode()
	weak var delegate: BAMapCellNodeDelegate?
	
	required init(with place: Place) {
		super.init()
		
		view.frame = CGRect(x: 15, y: 0, width: ez.screenWidth - 30, height: 200)

		initializeOnMainThread(place)
		
		uberButtonNode.setTitle("Uber",
		                        with: UIFont.init(name: "Nunito-SemiBold", size: 14),
		                        with: ColorPalette.grey, for: [])
		uberButtonNode.addTarget(self, action: #selector(self.uberButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		directionsButtonNode.setTitle("Directions",
		                              with: UIFont.init(name: "Nunito-SemiBold", size: 14),
		                              with: ColorPalette.grey, for: [])
		directionsButtonNode.addTarget(self, action: #selector(self.directionsButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		addSubnode(uberButtonNode)
		addSubnode(directionsButtonNode)
	}
	
	func uberButtonPressed(_ sender: UIButton){
		delegate?.mapCellNodeDidClickUberButton(self);
	}
	
	func directionsButtonPressed(_ sender: UIButton){
		delegate?.mapCellNodeDidClickDirectionsButton(self);
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// left button
		uberButtonNode.style.preferredSize = CGSize(width: constrainedSize.max.width / 2 - 15, height: 50)
		uberButtonNode.contentVerticalAlignment = .center
		uberButtonNode.contentHorizontalAlignment = .middle
		
		// right button
		directionsButtonNode.style.preferredSize = CGSize(width: constrainedSize.max.width / 2 - 15, height: 50)
		directionsButtonNode.contentVerticalAlignment = .center
		directionsButtonNode.contentHorizontalAlignment = .middle
		
		// vertical stack
		let horizontalStack = ASStackLayoutSpec()
		horizontalStack.direction = .horizontal
		horizontalStack.alignItems = .start
		horizontalStack.children = [uberButtonNode, directionsButtonNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 180, left: 15, bottom: 0, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: horizontalStack)
		
		return textInsetSpec
	}
	
	func initializeOnMainThread(_ place: Place){
		DispatchQueue.main.async(execute: {
			let frame = CGRect(x: 15, y: 0, width: ez.screenWidth - 30, height: 180)
			self.mapView = MKMapView(frame: frame)
			
			let coordinate = place.coordinates.coordinate
			let camera = MKMapCamera.init(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 350);
			self.mapView.setCamera(camera, animated: false)
			self.mapView.isUserInteractionEnabled = false
			self.mapView.showsPointsOfInterest = false
			self.mapView.layer.cornerRadius = 10
			
			/*
			// to avoid using cornerRadius:
			gradientNode = ASDisplayNode(layerBlock: { () -> CALayer in
				let gradient = CAGradientLayer()
				gradient.colors = [UIColor.clear.cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor]
				return gradient
			})
			*/
			
			self.mapView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			self.mapView.addAnnotation(annotation)
			
			self.view.addSubview(self.mapView)
		})
	}
	
	/*
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASLayoutSpec()
	}
	*/
}
