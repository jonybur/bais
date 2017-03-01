//
//  BALicensesButtonElementCellNode
//  Bais
//
//  Created by Jonathan Bursztyn on 9/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BALicensesButtonElementCellNode: BASettingsButtonElementCellNode{
	var license = String()
	
	convenience init(title: String, license: String){
		self.init(title: title)
		self.license = license
	}
}
