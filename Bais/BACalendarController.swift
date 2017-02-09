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
	let webService = WebService()
	let _layoutInspector = MosaicCollectionViewLayoutInspector()
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.orange,
	                                                    size: 75)
	
	init (){
		let layout = MosaicCollectionViewLayout(startsAt: 10)
		layout.numberOfColumns = 1
		_collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: layout)
		super.init(nibName: nil, bundle: nil)
		layout.delegate = self
		
		let activityIndicatorSize = (activityIndicatorView?.size)!
		activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - activityIndicatorSize) / 2,
		                                      y: (ez.screenHeight - activityIndicatorSize) / 2,
		                                      width: activityIndicatorSize, height: activityIndicatorSize);
		
		extendedLayoutIncludesOpaqueBars = true
		
		_collectionNode.dataSource = self
		_collectionNode.delegate = self
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
		self.view.addSubview(activityIndicatorView!)
		
		activityIndicatorView?.startAnimating()
		
		webService.delegate = self
		webService.getFacebookEvents()
	}

	override func viewWillLayoutSubviews() {
		_collectionNode.frame = self.view.bounds
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
	
	//MARK: - WebService delegate methods
	
	internal func eventsLoaded(_ events: [Event]) {
		var idxToInsert = [IndexPath]()
		for event in events {
			if ((event.startTime as Date) < Date() &&
				(event.endTime as Date) < Date()) {
				continue
			}
			
			let idxPath = IndexPath(item: idxToInsert.count, section: 0)
			idxToInsert.append(idxPath)
			_contentToDisplay.append(event)
			
			webService.getRSVPStatus(of: event)
		}
		
		_collectionNode.insertItems(at: idxToInsert)
		_collectionNode.reloadItems(at: idxToInsert)
		activityIndicatorView?.removeFromSuperview()
	}
	
	internal func gotRSVPStatus(of eventId: String, status: RSVPStatus) {
		for (idx, event) in _contentToDisplay.enumerated(){
			if(event.id == eventId){
				event.status = status
				_collectionNode.reloadItems(at: [IndexPath(item: idx, section: 0)])
				return
			}
		}
	}
	
	//MARK: - MosaicCollectionViewLayoutDelegate delegate methods
	internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
		return CGSize(width: 1, height: 0.6)
	}
	
	//MARK: - BACalendarCellNode delegate methods
	internal func calendarCellNodeDidClickInterestedButton(_ calendarViewCell: BACalendarCellNode) {
		setStatusForEvent(with: calendarViewCell.event.id, status: .maybe)
	}
	
	internal func calendarCellNodeDidClickGoingButton(_ calendarViewCell: BACalendarCellNode) {
		setStatusForEvent(with: calendarViewCell.event.id, status: .attending)
	}
	
	internal func calendarCellNodeDidClickIsInterestedButton(_ calendarViewCell: BACalendarCellNode) {
		displayOptions(for: calendarViewCell.event)
	}

	internal func calendarCellNodeDidClickIsGoingButton(_ calendarViewCell: BACalendarCellNode) {
		displayOptions(for: calendarViewCell.event)
	}
	
	internal func calendarCellNodeDidClickView(_ calendarViewCell: BACalendarCellNode) {
		let event = calendarViewCell.event
		let controller = BAEventController(with: event!)
		self.navigationController?.pushViewController(controller, animated: true)
	}
	
	func displayOptions(for event: Event){
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		if (event.status == .maybe){
			alert.addAction(UIAlertAction(title: "Going", style: .default, handler: { action in
				self.setStatusForEvent(with: event.id, status: .attending)
			}))
		} else if (event.status == .attending){
			alert.addAction(UIAlertAction(title: "Interested", style: .default, handler: { action in
				self.setStatusForEvent(with: event.id, status: .maybe)
			}))
		}
		
		alert.addAction(UIAlertAction(title: "Not Going", style: .default, handler: { action in
			self.setStatusForEvent(with: event.id, status: .declined)
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		var topVC = UIApplication.shared.keyWindow?.rootViewController
		while((topVC!.presentedViewController) != nil) {
			topVC = topVC!.presentedViewController
		}
		
		topVC?.present(alert, animated: true, completion: nil)
	}
	
	func setStatusForEvent(with id: String, status: RSVPStatus){
		webService.setNewRSVPStatus(id, rsvpStatus: status)
		gotRSVPStatus(of: id, status: status)
	}
	
	//MARK: - Dealloc
	deinit {
		_collectionNode.dataSource = nil
		_collectionNode.delegate = nil
	}
}

