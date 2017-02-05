//
//  BACalendarController.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FirebaseDatabase
import FirebaseAuth
import DGActivityIndicatorView
import PromiseKit
import GeoFire

class BACalendarController: UIViewController, MosaicCollectionViewLayoutDelegate,
	ASCollectionDataSource, ASCollectionDelegate, BACalendarCellNodeDelegate, WebServiceDelegate {

	var _contentToDisplay = [Event]()
	let _collectionNode: ASCollectionNode!
	let _layoutInspector = MosaicCollectionViewLayoutInspector()
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.orange,
	                                                    size: 75)
	
	init (){
		let layout = MosaicCollectionViewLayout(startsAt: 10)
		layout.numberOfColumns = 1;
		_collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: layout)
		super.init(nibName: nil, bundle: nil);
		layout.delegate = self
		
		extendedLayoutIncludesOpaqueBars = true
		
		_collectionNode.dataSource = self;
		_collectionNode.delegate = self;
		_collectionNode.view.layoutInspector = _layoutInspector
		_collectionNode.backgroundColor = ColorPalette.white
		_collectionNode.view.isScrollEnabled = true
		_collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
	}
	
	required init(coder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubnode(_collectionNode!)
		self.view.addSubview(activityIndicatorView!);
		
		activityIndicatorView?.startAnimating()
		
		let webService = CloudController()
		webService.delegate = self
		webService.getFacebookEvents()
	}
	
	internal func eventsLoaded(_ events: [Event]) {
		var idxToInsert = [IndexPath]()
		for event in events {
			if ((event.startTime as Date) < Date() &&
				(event.endTime as Date) < Date()) {
				continue;
			}
			
			let idxPath = IndexPath(item: idxToInsert.count, section: 0)
			idxToInsert.append(idxPath)
			_contentToDisplay.append(event)
		}
		
		_collectionNode.insertItems(at: idxToInsert)
		_collectionNode.reloadItems(at: idxToInsert)
	}
	
	override func viewWillLayoutSubviews() {
		_collectionNode.frame = self.view.bounds;
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
		let event = _contentToDisplay[indexPath.item]
		let node = BACalendarCellNode(with: event)
		node.delegate = self
		return node
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
		return BACalendarHeaderCellNode()
	}
	
	func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
		return 1
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
		return _contentToDisplay.count
	}
	
	//MARK: - MosaicCollectionViewLayoutDelegate delegate methods
	internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
		return CGSize(width: 1, height: 0.5)
	}
	
	//MARK: - BACalendarCellNode delegate methods
	internal func calendarCellNodeDidClickButton(_ calendarViewCell: BACalendarCellNode) {
		
	}
	
	internal func calendarCellNodeDidClickView(_ calendarViewCell: BACalendarCellNode) {
		
	}
	
	//MARK: - Dealloc
	deinit {
		_collectionNode.dataSource = nil;
		_collectionNode.delegate = nil;
	}
}

