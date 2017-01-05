//
//  LoginScreen.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 18/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//


import UIKit
import AsyncDisplayKit
import CoreGraphics

class SettingsScreen: UIViewController {
	
	var scrollNode : ASScrollNode = ASScrollNode();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		
		view.backgroundColor = ColorPalette.baisWhite;
		self.automaticallyAdjustsScrollViewInsets = false;
		
		navigationController?.isNavigationBarHidden = true;
		
		initializeInterface();
	}
	
	func initializeInterface(){
		
		let baisLogo : ASImageNode = ASImageNode();
		baisLogo.frame = CGRect(0, 0, 200, 200);
		baisLogo.image = UIImage(named: "BaisLogo");
		baisLogo.position = CGPoint(x: ez.screenWidth / 2, y: 190)
		
		setAddress(baisLogo.frame.maxY + 20);
		
		let location = CLLocationCoordinate2D(latitude:-34.591248, longitude:-58.393159);
		let map : UIMapBox = UIMapBox(coordinate: location, yPosition: baisLogo.frame.maxY + 50);
		map.center = CGPoint(x: ez.screenWidth / 2, y: baisLogo.frame.maxY + 50 + UIMapBox.mapHeight / 2);
		
		let descriptionAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
		                             NSForegroundColorAttributeName: UIColor.black]
		
		let descriptionView : UITextView = UITextView();
		descriptionView.frame = CGRect(20, baisLogo.frame.maxY + 230, ez.screenWidth - 40, 10);
		descriptionView.attributedText = NSAttributedString(string: "La primera organización de estudiantes de intercambio en Argentina\n\nBAIS Argentina es la primera organización no gubernamental (ONG) que tiene como objetivo la integración social de jóvenes extranjeros mediante la elaboración de actividades semanales, logrando ampliar la visión del país y su cultura, haciendo que la estadía sea más fácil y enriquecedora.\n\nNuestro objetivo es ofrecer a los estudiantes de intercambio la oportunidad de conocerse y conocer el país de manera distinta. Hacerles sentir apoyados durante su estadía a través de un asesoramiento que les permita abrirse a una nueva cultura.\n\n+54 11 5263 - 2247\nLunes a viernes de 11 a 18 hs.\ninfo@baisargentina.com", attributes: descriptionAttributes);
		descriptionView.dataDetectorTypes = .phoneNumber;
		descriptionView.isScrollEnabled = false;
		descriptionView.isEditable = false;
		let newSize = descriptionView.sizeThatFits(descriptionView.frame.size);
		descriptionView.frame.size = newSize;
		
		let boardLogo : ASImageNode = ASImageNode();
		boardLogo.frame = CGRect(0, 0, 100, 23.25);
		boardLogo.image = UIImage(named: "BoardLogo");
		boardLogo.position = CGPoint(x: ez.screenWidth / 2, y: descriptionView.frame.maxY + 45)

		self.scrollNode.addSubnode(baisLogo);
		self.scrollNode.addSubnode(boardLogo);
		self.scrollNode.view.addSubview(map);
		self.scrollNode.view.addSubview(descriptionView);
		self.scrollNode.frame = CGRect(x: 0, y: 0, width: ez.screenWidth, height: ez.screenHeight);
		self.scrollNode.view.contentSize = CGSize(width: ez.screenWidth, height: boardLogo.frame.maxY + 95);
		
		self.view.addSubnode(scrollNode);
	}
	
	func setAddress(_ yPosition : CGFloat){
		let addressAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
		                         NSForegroundColorAttributeName: UIColor.black]
		
		let addressLabel : UILabel = UILabel();
		addressLabel.frame = CGRect(x: 20, y: yPosition, width: ez.screenWidth - 40, height: 20);
		addressLabel.adjustsFontSizeToFitWidth = true;
		addressLabel.attributedText = NSAttributedString(string: "Ayacucho 1571 - PB", attributes: addressAttributes);
		
		self.scrollNode.view.addSubview(addressLabel);
	}
	
}
