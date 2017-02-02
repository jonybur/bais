//
//  GradientBar.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 27/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import UIKit

class GradientBar : UIView, CAAnimationDelegate{
    
    let gradient: CAGradientLayer = CAGradientLayer();

    let firstColor : UIColor = ColorPalette.argentinaBlueDarker;
    let secondColor : UIColor = ColorPalette.argentinaBlue;
	
	open static let height : CGFloat = 70;
	
    var phase : Bool = false;
    
    override init (frame : CGRect) {
        super.init(frame : frame);
        
        setGradient();
        setLogo();
        
        self.alpha = 0.9;
    }
    
    convenience init () {
        self.init(frame:CGRect(x: 0, y: 0, width: ez.screenWidth, height: GradientBar.height))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setLogo(){
        // ios status bar height is 20px
        let logoView : UIImageView = UIImageView(frame: CGRect(x: 0, y: 20, width: 100, height: self.frame.height));
        
        logoView.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 10)
        logoView.contentMode = .scaleAspectFit;
        logoView.image = UIImage(named: "Logo");
        
        self.addSubview(logoView);
    }
    
    func setGradient (){
        self.gradient.frame = self.bounds;
        self.gradient.startPoint = CGPoint(x: 0, y: 1);
        self.gradient.endPoint = CGPoint(x: 1, y: 0);
        self.gradient.colors = [firstColor.cgColor, secondColor.cgColor];
        
        animateLayer(secondColor.cgColor, rightColor: firstColor.cgColor);
        
        self.layer.insertSublayer(gradient, at: 0);
    }
    
    func animateLayer(_ leftColor : CGColor, rightColor : CGColor){
        let fromColors = self.gradient.colors;
        
        let toColors: [AnyObject] = [ leftColor, rightColor ];
        
        self.gradient.colors = toColors;
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors");
        
        self.phase = !self.phase;
        
        animation.fromValue = fromColors;
        animation.toValue = toColors;
        animation.duration = 3.00;
        animation.isRemovedOnCompletion = true;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
        animation.delegate = self;
        
        self.gradient.add(animation, forKey: "animateGradient");
    }
	
	// TODO: check if works
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if (!self.phase){
            animateLayer(firstColor.cgColor, rightColor: secondColor.cgColor);
        } else {
            animateLayer(secondColor.cgColor, rightColor: firstColor.cgColor);
        }
    }
    
}
