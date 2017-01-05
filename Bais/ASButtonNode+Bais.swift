//
//  ASUserCard+Claxon.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 3/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import AsyncDisplayKit

extension ASButtonNode{
    func setTitleInMiddleAlignment(_ string: String, withFont: UIFont, withColor: UIColor, state: ASControlState) {
        self.setTitle(string, with: withFont, with: withColor, for: state);
        
        let fontSize : CGSize = withFont.sizeOfString(string);
        
        self.contentEdgeInsets = UIEdgeInsets(top: (self.frame.size.height - fontSize.height) / 2, left: (self.frame.size.width - fontSize.width) / 2, bottom: 0, right: 0)
        self.measure(self.frame.size);
    }
}
