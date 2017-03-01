//
//  BALicensesCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 9/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol BALicensesNodeDelegate: class {
	func licensesNodeDidClickLicenseButton(_ button: BALicensesButtonElementCellNode)
}

class BALicensesCellNode: ASCellNode{
	
	let popNode = BALicensesButtonElementCellNode(productName: "pop", license: "Test123")
	let dgActivityNode = BALicensesButtonElementCellNode(productName: "DGActivityIndicatorView", license: "")
	let asdkNode = BALicensesButtonElementCellNode(productName: "AsyncDisplayKit", license: "")
	let tabBarNode = BALicensesButtonElementCellNode(productName: "ESTabBarController", license: "")
	let fbsdkCoreNode = BALicensesButtonElementCellNode(productName: "FBSDKCoreKit", license: "")
	let fbsdkLoginNode = BALicensesButtonElementCellNode(productName: "FBSDKLoginKit", license: "")
	let fbsdkShareNode = BALicensesButtonElementCellNode(productName: "FBSDKShareKit", license: "")
	let alamoNode = BALicensesButtonElementCellNode(productName: "Alamofire", license: "")
	let swiftyNode = BALicensesButtonElementCellNode(productName: "SwiftyJSON", license: "")
	let promiseNode = BALicensesButtonElementCellNode(productName: "PromiseKit", license: "")
	let countryNode = BALicensesButtonElementCellNode(productName: "CountryPicker", license: "")
	let nmessengerNode = BALicensesButtonElementCellNode(productName: "NMessenger", license: "")
	let iconsNode = BALicensesButtonElementCellNode(productName: "Icons8", license: "")
	let geofireNode = BALicensesButtonElementCellNode(productName: "GeoFire", license: "The MIT License (MIT)\r\n\r\nCopyright (c) 2016 Firebase\r\n\r\nPermission is hereby granted, free of charge, to any person obtaining a copy\r\nof this software and associated documentation files (the \"Software\"), to deal\r\nin the Software without restriction, including without limitation the rights\r\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\r\ncopies of the Software, and to permit persons to whom the Software is\r\nfurnished to do so, subject to the following conditions:\r\n\r\nThe above copyright notice and this permission notice shall be included in all\r\ncopies or substantial portions of the Software.\r\n\r\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\r\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\r\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\r\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\r\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\r\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\r\nSOFTWARE.")
	
	weak var delegate: BALicensesNodeDelegate?
	
	required override init() {
		super.init()
		
		popNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		dgActivityNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		asdkNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		tabBarNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		fbsdkCoreNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		fbsdkLoginNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		fbsdkShareNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		alamoNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		swiftyNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		promiseNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		countryNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		nmessengerNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		iconsNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)
		geofireNode.addTarget(self, action: #selector(licensePressed(_:)), forControlEvents: .touchUpInside)

		addSubnode(popNode)
		addSubnode(dgActivityNode)
		addSubnode(asdkNode)
		addSubnode(tabBarNode)
		addSubnode(fbsdkCoreNode)
		addSubnode(fbsdkLoginNode)
		addSubnode(fbsdkShareNode)
		addSubnode(alamoNode)
		addSubnode(swiftyNode)
		addSubnode(promiseNode)
		addSubnode(countryNode)
		addSubnode(nmessengerNode)
		addSubnode(iconsNode)
		addSubnode(geofireNode)
	}
	
	func licensePressed(_ button: BALicensesButtonElementCellNode){
		delegate?.licensesNodeDidClickLicenseButton(button)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.children = [popNode, dgActivityNode, asdkNode, tabBarNode, fbsdkCoreNode, fbsdkLoginNode, fbsdkShareNode, alamoNode, swiftyNode,
		promiseNode, countryNode, nmessengerNode, iconsNode, geofireNode]
		return verticalStack
	}
}
