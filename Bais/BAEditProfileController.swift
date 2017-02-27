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
	BAEditBasicUserInfoCellNodeDelegate, BAEditCountryPickerCellNodeDelegate, BAEditImageCarouselCellNodeDelegate,
	BAEditDescriptionCellNodeDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	var user = User()
	var backButtonNode = BADetailBackButtonNode()
	var actionButtonNode = BADetailActionButtonNode()
	var showCountryPicker: Bool = false
	var mode: EditProfileMode?
	
	enum EditProfileMode: String{
		case settings = "settings", create = "create"
	}
	
	var tableNode: ASTableNode {
		return node as! ASTableNode
	}
	
	init(with user: User, as mode: EditProfileMode) {
		super.init(node: ASTableNode())
		self.mode = mode
		self.user = user
		
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
		actionButtonNode.frame = CGRect(x: ez.screenWidth / 2 - ez.screenWidth / 4, y: ez.screenHeight - 60, width: ez.screenWidth / 2, height: 50)
		
		let yourCarefullyDrawnPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: actionButtonNode.frame.width, height: actionButtonNode.frame.height), cornerRadius: 20)
		let maskForYourPath = CAShapeLayer()
		maskForYourPath.path = yourCarefullyDrawnPath.cgPath
		actionButtonNode.layer.mask = maskForYourPath

		if (mode == .settings){
			super.node.addSubnode(backButtonNode)
		} else if (mode == .create) {
			super.node.addSubnode(actionButtonNode)
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
		view.addGestureRecognizer(tap)
		
		backButtonNode.addTarget(self, action: #selector(backButtonPressed(_:)), forControlEvents: .touchUpInside)
		actionButtonNode.addTarget(self, action: #selector(actionButtonPressed(_:)), forControlEvents: .touchUpInside)
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
		_ = navigationController?.popViewController(animated: true)
	}
	
	func actionButtonPressed(_ sender: UIButton){
		let loadingController = BALoadingController()
		navigationController?.pushViewController(loadingController, animated: true)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if (mode == .settings){
			navigationController!.interactivePopGestureRecognizer!.isEnabled = true
			navigationController!.interactivePopGestureRecognizer!.delegate =  self
		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if (scrollView.contentOffset.y < 0){
			scrollView.contentOffset.y = 0
		}
		
		backButtonNode.view.center = CGPoint(x: backButtonNode.view.center.x,
		                                     y: scrollView.contentOffset.y + backButtonNode.view.frame.height / 2 + 10)
		
		actionButtonNode.view.center = CGPoint(x: actionButtonNode.view.center.x,
		                                     y: scrollView.contentOffset.y + ez.screenHeight - actionButtonNode.view.frame.height + 15)
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
		} else if (item == 1) {
			let basicCellNode = BAEditBasicUserInfoCellNode(with: user, allowsCountryEditing: mode == .create)
			basicCellNode.delegate = self
			return basicCellNode
		}
		
		if (showCountryPicker){
			if (item == 2){
				let countryPickerCellNode = BAEditCountryPickerCellNode()
				countryPickerCellNode.delegate = self
				return countryPickerCellNode
			} else if (item == 3){
				let descriptionCellNode = BAEditDescriptionCellNode(with: user)
				descriptionCellNode.delegate = self
				return descriptionCellNode
			}
		} else {
			if (item == 2){
				let descriptionCellNode = BAEditDescriptionCellNode(with: user)
				descriptionCellNode.delegate = self
				return descriptionCellNode
			}
		}
		
		return BASpacerCellNode()
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return showCountryPicker ? 5 : 4
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
	
//MARK: - BAEditCountryPickerCellNodeDelegate methods
	
	internal func editCountryPickerNodeDidClosePicker(country: String, code: String) {
		showCountryPicker = false
		user.countryCode = code
		let idxPath = [IndexPath(item: 2, section:0)]
		tableNode.deleteRows(at: idxPath, with: .fade)
		let idxPathToReload = [IndexPath(item: 1, section:0), IndexPath(item: 2, section:0)]
		tableNode.reloadRows(at: idxPathToReload, with: .fade)
		FirebaseService.updateUserNationality(with: code)
		actionButtonNode.enable()
	}
	
//MARK: - BAEditBasicUserInfoCellNodeDelegate methods

	internal func editBasicUserInfoCellNodeDidPressOpenCountryPicker(){
		if (showCountryPicker){
			return
		}
		showCountryPicker = true
		let idxPath = [IndexPath(item: 2, section:0)]
		tableNode.insertRows(at: idxPath, with: .fade)
		tableNode.reloadRows(at: idxPath, with: .fade)
	}
	
//MARK: - BAEditDescriptionCellNode methods
	
	internal func editDescriptionCellNodeDidFinishEditing(about: String) {
		user.about = about
		FirebaseService.updateUserAbout(with: about)
	}

}
