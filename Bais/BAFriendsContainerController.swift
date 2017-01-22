//
//  BAFriendsContainer.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 22/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit

class BAFriendsContainerController: UIViewController{
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// add container
		
		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(containerView)
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
			containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
			containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
			])
		
		// add child view controller view to container
		let controller = BAFriendsController()
		addChildViewController(controller)
		controller.view.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(controller.view)
		
		NSLayoutConstraint.activate([
			controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			controller.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 100),
			controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
			])
		
		controller.didMove(toParentViewController: self)
	}

}
