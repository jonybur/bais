//
//  BouncesStyleAnimator.swift
//  ESTabBarControllerExample
//
//  Created by lihao on 16/5/21.
//  Copyright © 2016年 Egg Swift. All rights reserved.
//

import UIKit
import ESTabBarController
import pop

open class IrregularityBasicStyleAnimator: BouncesStyleAnimator {
    
    public override init() {
        super.init()
        textColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        highlightTextColor = ColorPalette.baisOrange;
        iconColor = UIColor.black;
        highlightIconColor = ColorPalette.baisOrange;
        backgroundColor = UIColor.white;
        highlightBackgroundColor = UIColor.white;
    }
}

open class IrregularityStyleAnimator: BackgroundStyleAnimator {
    
    public override init() {
        super.init()
        textColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        highlightTextColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
        iconColor = UIColor.black
        highlightIconColor = ColorPalette.baisOrange
        backgroundColor = UIColor.white
        highlightBackgroundColor = UIColor.white
    }
    
    open override func selectAnimation(content: UIView, animated: Bool, completion: (() -> ())?) {
        super.selectAnimation(content: content, animated: animated, completion: completion)
        
        if let content = content as? ESTabBarItemContent , animated == true {
            let view = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: 2.0, height: 2.0)))
            view.layer.cornerRadius = 1.0
            view.layer.opacity = 0.5
            view.backgroundColor = UIColor.white
            content.addSubview(view)
            playMaskAnimation(animateView: view, target: content.imageView, completion: {
                [weak view] in
                view?.removeFromSuperview()
                completion?()
                })
        }
    }
    
    open override func reselectAnimation(content: UIView, animated: Bool, completion: (() -> ())?) {
        selectAnimation(content: content, animated: animated, completion: completion)
        //super.reselectAnimation(content: content, animated: animated, completion: completion)
    }
    
    open override func deselectAnimation(content: UIView, animated: Bool, completion: (() -> ())?) {
        super.deselectAnimation(content: content, animated: animated, completion: completion)
        if let content = content as? ESTabBarItemContent {
            content.backgroundColor = backgroundColor
            content.titleLabel.textColor = textColor
            if let image = content.imageView.image {
                let renderImage = image.withRenderingMode(.alwaysOriginal)
                content.imageView.image = renderImage
                content.imageView.tintColor = iconColor
            }
        }
    }
    
    open override func highlightAnimation(content: UIView, animated: Bool, completion: (() -> ())?) {
        if let content = content as? ESTabBarItemContent {
            UIView.beginAnimations("small", context: nil)
            UIView.setAnimationDuration(0.2)
            let transform = (content.imageView.transform).scaledBy(x: 1, y: 1)
            content.imageView.transform = transform
            UIView.commitAnimations()
        }
        completion?()
    }
    
    open override func dehighlightAnimation(content: UIView, animated: Bool, completion: (() -> ())?) {
        if let content = content as? ESTabBarItemContent {
            UIView.beginAnimations("big", context: nil)
            UIView.setAnimationDuration(0.2)
            let transform = CGAffineTransform.identity
            content.imageView.transform = transform
            UIView.commitAnimations()
        }
        completion?()
    }
    
    fileprivate func playMaskAnimation(animateView view: UIView, target: UIView, completion: (() -> ())?) {
        completion?();
    }
}
