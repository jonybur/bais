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
import FBSDKLoginKit
import GeoFire

class BACalendarController: UIViewController, MosaicCollectionViewLayoutDelegate,
	ASCollectionDataSource, ASCollectionDelegate, BACalendarCellNodeDelegate, WebServiceDelegate {
	
	var _contentToDisplay = [Event]()
	let collectionNode: ASCollectionNode!
	let webService = WebService()
	let _layoutInspector = MosaicCollectionViewLayoutInspector()
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.orangeLighter,
	                                                    size: 80)
	
	init (){
		let layout = MosaicCollectionViewLayout(startsAt: 10)
		layout.numberOfColumns = 1
		collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: layout)
		super.init(nibName: nil, bundle: nil)
		layout.delegate = self
		
		let activityIndicatorSize = (activityIndicatorView?.size)!
		activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - activityIndicatorSize) / 2,
		                                      y: (ez.screenHeight - activityIndicatorSize) / 2,
		                                      width: activityIndicatorSize, height: activityIndicatorSize);
		
		extendedLayoutIncludesOpaqueBars = true
		
		collectionNode.dataSource = self
		collectionNode.delegate = self
		collectionNode.view.layoutInspector = _layoutInspector
		collectionNode.backgroundColor = ColorPalette.white
		collectionNode.view.isScrollEnabled = true
		collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
	}
	
	required init(coder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubnode(collectionNode!)
		self.view.addSubview(activityIndicatorView!)
		
		activityIndicatorView?.startAnimating()
		
		webService.delegate = self
		webService.getFacebookEvents()
	}

	override func viewWillLayoutSubviews() {
		collectionNode.frame = self.view.bounds
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
		
		collectionNode.insertItems(at: idxToInsert)
		collectionNode.reloadItems(at: idxToInsert)
		activityIndicatorView?.removeFromSuperview()
	}
	
	internal func gotRSVPStatus(of eventId: String, status: RSVPStatus) {
		for (idx, event) in _contentToDisplay.enumerated(){
			if(event.id == eventId){
				event.status = status
				collectionNode.reloadItems(at: [IndexPath(item: idx, section: 0)])
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
		navigationController?.pushViewController(controller, animated: true)
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
		present(alert, animated: true, completion: nil)
	}
	
	func setStatusForEvent(with id: String, status: RSVPStatus){
		webService.setNewRSVPStatus(id, rsvpStatus: status)
		gotRSVPStatus(of: id, status: status)
	}
	
	func needsFacebookLogin(){
		loginToFacebookWithReadPermissions().then(execute: { _ -> Void in
			self.loginToFacebookWithPublishPermissions().then(execute: { _ -> Void in
				self.webService.getFacebookEvents()
			}).catch(execute: { _ in })
		}).catch(execute: { _ in })
	}
	
	func loginToFacebookWithReadPermissions() -> Promise<Void>{
		return Promise{ fulfill, reject in
			let loginManager = FBSDKLoginManager()
			loginManager.logIn(withReadPermissions: WebService.readPermissions, from: self, handler: { (result, error) in
				if (error != nil || (result?.isCancelled)!){ } else {
					fulfill()
				}
			})
		}
	}
	
	func loginToFacebookWithPublishPermissions() -> Promise<Void>{
		return Promise{ fulfill, reject in
			let loginManager = FBSDKLoginManager()
			loginManager.logIn(withPublishPermissions: WebService.publishPermissions, from: self, handler: { (result, error) in
				if (error != nil || (result?.isCancelled)!){ } else {
					fulfill()
				}
			})
		}
	}
	
//MARK: - Dealloc
	
	deinit {
		collectionNode.dataSource = nil
		collectionNode.delegate = nil
	}
}

