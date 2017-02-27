//
//  ExampleBasicContentView.swift
//  ESTabBarControllerExample
//
//  Created by lihao on 2017/2/9.
//  Copyright © 2017年 Vincent Li. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class BABasicContentView: ESTabBarItemContentView {
	convenience init(){
		self.init(frame: CGRect.zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		textColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
		highlightTextColor = ColorPalette.orange
		iconColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
		highlightIconColor = ColorPalette.orange
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class BAHomeContentView: ESTabBarItemContentView{
	override func updateDisplay() {
		if selected {
			//backgroundColor = highlightBackdropColor
			imageView.image = UIImage(named: "home-full-icon")
		} else {
			//backgroundColor = backdropColor
			imageView.image = UIImage(named: "home-empty-icon")?.withRenderingMode(.alwaysTemplate)
			imageView.tintColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
		}
	}
}

class BABouncesContentView: BABasicContentView {
	public var duration = 0.3
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func selectAnimation(animated: Bool, completion: (() -> ())?) {
		self.bounceAnimation()
		completion?()
	}
	
	override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
		self.bounceAnimation()
		completion?()
	}
	
	func bounceAnimation() {
		let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
		impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
		impliesAnimation.duration = duration * 2
		impliesAnimation.calculationMode = kCAAnimationCubic
		imageView.layer.add(impliesAnimation, forKey: nil)
	}
}
