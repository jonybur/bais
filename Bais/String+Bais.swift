//
//  String+Bais.swift
//  BAIS
//
//  Created by Jonathan Bursztyn on 6/9/16.
//  Copyright © 2016 Bais. All rights reserved.
//

import Foundation

extension String {
	public func indexOfCharacter(_ char: Character) -> Int? {
		if let idx = self.characters.index(of: char) {
			return self.characters.distance(from: self.startIndex, to: idx)
		}
		return nil
	}
}
