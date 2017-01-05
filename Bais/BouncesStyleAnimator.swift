//
//  BouncesStyleAnimator.swift
//  ESTabBarControllerExample
//
//  Created by lihao on 16/5/21.
//  Copyright © 2016年 Egg Swift. All rights reserved.
//

import UIKit
import ESTabBarController

open class BouncesStyleAnimator: ESTabBarItemAnimator {
    
    open var duration = 0.3
    
    override init() {
        super.init()
        textColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
        highlightTextColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
        iconColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
        highlightIconColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
        backgroundColor = UIColor.clear;
		highlightBackgroundColor = UIColor.clear;
	}
    
    open override func selectAnimation(content: UIView, animated: Bool, completion: (() -> ())?) {
        super.selectAnimation(content: content, animated: animated, completion: completion)
        if let content = content as? ESTabBarItemContent {
            self.bounceAnimation(content.imageView)
        }
    }
    
    open override func reselectAnimation(content: UIView, animated: Bool, completion: (() -> ())?) {
        super.reselectAnimation(content: content, animated: animated, completion: completion)
        if let content = content as? ESTabBarItemContent {
            self.bounceAnimation(content.imageView)
        }
    }
    
    open override func deselectAnimation(content: UIView, animated: Bool, completion: (() -> ())?) {
        super.deselectAnimation(content: content, animated: animated, completion: completion)
    }
    
    internal func bounceAnimation(_ view: UIView) {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        
        view.layer.add(impliesAnimation, forKey: nil)
    }
    
}
