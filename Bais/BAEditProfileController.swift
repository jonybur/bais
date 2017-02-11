//
//  BAEditProfileController.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 10/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import PromiseKit

final class BAEditProfileController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate,
BAEditImageCarouselCellNodeDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	var user = User()
	var backButtonNode = ASButtonNode()
	
	var tableNode: ASTableNode {
		return node as! ASTableNode
	}
	
	init(with userId: String){
		super.init(node: ASTableNode())
		
		FirebaseService.getUser(with: userId).then { user -> Void in
			self.user = user
			self.commonInit()
			}.catch { _ in }
	}
	
	init(with user: User) {
		super.init(node: ASTableNode())
		self.user = user
		commonInit()
	}
	
	func commonInit(){
		tableNode.delegate = self
		tableNode.dataSource = self
		tableNode.view.separatorStyle = .none
		tableNode.allowsSelection = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		backButtonNode.frame = CGRect(x: 0, y: 10, width: 75, height: 75)
		backButtonNode.setImage(UIImage(named: "back-button"), for: [])
		backButtonNode.addTarget(self, action: #selector(backButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		super.node.addSubnode(backButtonNode)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	func closeKeyboard() {
		view.endEditing(true)
	}
	
	func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y == 0{
				self.view.frame.origin.y -= keyboardSize.height
			}
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y != 0{
				self.view.frame.origin.y += keyboardSize.height
			}
		}
	}
	
	func backButtonPressed(_ sender: UIButton){
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		self.navigationController!.interactivePopGestureRecognizer!.delegate =  self
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if (scrollView.contentOffset.y < 0){
			scrollView.contentOffset.y = 0
		}
		
		backButtonNode.view.center = CGPoint(x: backButtonNode.view.center.x,
		                                     y: scrollView.contentOffset.y + backButtonNode.view.frame.height / 2 + 10)
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	//MARK: - ASTableNode data source and delegate
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let item = indexPath.item
		
		if (item == 0){
			let headerCellNode = BAEditImageCarouselCellNode(with: user)
			headerCellNode.delegate = self
			return headerCellNode
		} else if (item == 1){
			let basicCellNode = BAEditBasicUserInfoCellNode(with: user)
			return basicCellNode
		} else if (item == 2){
			let descriptionCellNode = BAEditDescriptionCellNode(with: user)
			return descriptionCellNode
		}
		
		return BASpacerCellNode()
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	//MARK: - BAEditImageCarouselCellNodeDelegate methods
	
	internal func editImageCarouselNodeDidClickEditImageButton() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { action in
			self.openImagePickerController()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
	
	func openImagePickerController(){
		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.sourceType = .photoLibrary;
			imagePicker.allowsEditing = true
			present(imagePicker, animated: true, completion: nil)
		}
	}
	
	//MARK: - UIImagePickerControllerDelegate methods
	
	internal func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
		let image = info[UIImagePickerControllerEditedImage] as? UIImage
		dismiss(animated: true, completion: nil)
		
		FirebaseService.storeImage(image!, as: .profilePicture).then { url -> Void in
			self.user.profilePicture = url.absoluteString
			let indexPath = [IndexPath(item: 0, section: 0)]
			self.tableNode.reloadRows(at: indexPath, with: .fade)
			FirebaseService.updateUserImage(with: url.absoluteString, imagePurpose: .profilePicture)
		}.catch { _ in }
	}
	
}
