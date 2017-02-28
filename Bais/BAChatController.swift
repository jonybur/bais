/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Firebase
import FirebaseDatabase
import AsyncDisplayKit
import FirebaseAuth
import NMessenger

class BAChatController: NMessengerViewController, BAChatNavigationBarDelegate {
	
	var session: Session!
	var messagesSentByUser = [String:Message]()
	
	init(with session: Session){
        super.init()
		self.session = session
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	override func getInputBar() -> InputBarView{
		guard let inputBar = super.getInputBar() as? NMessengerBarView else { return InputBarView() }
		inputBar.inputTextViewPlaceholder = ""
		return inputBar
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		messagePadding = UIEdgeInsets(top: 0, left: 10, bottom: 5, right: 10)
		observeMessages()
		observeSessionStatus()
		
		let emptyCell = createTextMessage("", isIncomingMessage: true)
		emptyCell.backgroundColor = .clear
		emptyCell.alpha = 0
		addMessageToMessenger(emptyCell)
		
		for user in session.participants{
			if (user.id != FirebaseService.currentUserId){
				let navBar = BAChatNavigationBar(with: user)
				navBar.delegate = self
				navBar.frame = CGRect(x: 0, y: 0, width: ez.screenWidth, height: 70)
				self.view.addSubnode(navBar)
				break
			}
		}
	}
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		navigationController!.interactivePopGestureRecognizer!.delegate = self
		FirebaseService.resetUnreadCount(of: session)
		NotificationCenter.default.addObserver(self,
		                                       selector:#selector(applicationWillEnterForeground(_:)),
		                                       name:NSNotification.Name.UIApplicationWillEnterForeground,
		                                       object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                       selector:#selector(applicationWillEnterBackground(_:)),
		                                       name:NSNotification.Name.UIApplicationDidEnterBackground,
		                                       object: nil)
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		FirebaseService.resetUnreadCount(of: session)
		NotificationCenter.default.removeObserver(self)
	}
	
	func observeMessages(){
		FirebaseService.sessionsReference.child(session.id).child("messages").observe(.childAdded, with: { snapshot in
			guard let messageDictionary = snapshot.value as? NSDictionary else { return }
			
			if (self.messagesSentByUser[snapshot.key] != nil) {
				return
			}
			
			let text = messageDictionary["text"] as! String
			let senderId = messageDictionary["sender_id"] as! String
			
			let message = Message(text: text, senderId: senderId)
			message.timestamp = messageDictionary["timestamp"] as! CGFloat
			
			self.session.messages.append(message)
			
			_ = super.sendText(text, isIncomingMessage: (FirebaseService.currentUserId != senderId))
		})
	}
	
	override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
		let message = Message(text: text, senderId: FirebaseService.currentUserId)
		let messageKey = FirebaseService.sendMessage(message, to: session)
		messagesSentByUser.updateValue(message, forKey: messageKey)
		return super.sendText(text, isIncomingMessage: isIncomingMessage)
	}
	
//MARK: - Options buttons
	
	func chatNavigationBarTapBack(_ chatNavigationBar: BAChatNavigationBar) {
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	func chatNavigationBarTapProfile(_ chatNavigationBar: BAChatNavigationBar) {
		guard let user = chatNavigationBar.user else { return }
		
		let controller = BAProfileController(with: user)
		navigationController?.pushViewController(controller, animated: true)
	}
	
	func chatNavigationBarTapSettings(_ chatNavigationBar: BAChatNavigationBar) {
		guard let user = chatNavigationBar.user else { return }

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: "Unfriend " + user.firstName, style: .default, handler: { action in
			self.unmatchAction(user)
		}))
		
		alert.addAction(UIAlertAction(title: "Report " + user.firstName, style: .default, handler: { action in
			self.reportAction(user)
		}))
		
		alert.addAction(UIAlertAction(title: "Show " + user.firstName + "'s Profile", style: .default, handler: { action in
			let controller = BAProfileController(with: user)
			self.navigationController?.pushViewController(controller, animated: true)
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
	
	func unmatchAction(_ user: User){
		let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Unfriend", style: .default, handler: { action in
			FirebaseService.endFriendRelationshipWith(friendId: user.id, sessionId: self.session.id)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated:true, completion:nil)
	}
	
	func reportAction(_ user: User){
		let alert = UIAlertController(title: "Report User", message: "Is this person bothering you?\nTell us what they did.", preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = "Additional Info (Optional)"
			textField.autocapitalizationType = .sentences
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { action in
			let textField = alert.textFields![0] as UITextField
			FirebaseService.sendReport(for: user, reason: textField.text!)
		}))
		present(alert, animated:true, completion:nil)
	}
	
//MARK: - Firebase

	private func observeSessionStatus(){
		let userSessionsRef = FirebaseService.usersReference.child(FirebaseService.currentUserId).child("sessions")
		userSessionsRef.observe(.childChanged) { (snapshot: FIRDataSnapshot!) in
			// checks if session activity was turned to false
			guard let sessionValues = snapshot.value as? NSDictionary else { return }
			guard let sessionIsActive = sessionValues["active"] as? Bool else { return }
			if (sessionIsActive){
				return
			}
			
			// pops screen
			if (snapshot.key == self.session.id){
				var tabBar: UIViewController!
				let navigationControllersCount = (self.navigationController?.viewControllers.count)!
				if (self.navigationController?.topViewController is BAProfileController){
					tabBar = self.navigationController?.viewControllers[navigationControllersCount - 3]
				}else{
					tabBar = self.navigationController?.viewControllers[navigationControllersCount - 2]
				}
				_ = self.navigationController?.popToViewController(tabBar, animated: true)
			}
		}
	}
	
//MARK: - Application notifications
	
	func applicationWillEnterForeground(_ notification: NSNotification) {
		FirebaseService.resetUnreadCount(of: session)
		FirebaseService.resetBadgeCount()
	}
	
	func applicationWillEnterBackground(_ notification: NSNotification) {
		FirebaseService.resetUnreadCount(of: session)
		FirebaseService.resetBadgeCount()
	}

}
