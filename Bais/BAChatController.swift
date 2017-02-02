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
import FirebaseAuth
import JSQMessagesViewController
import JSQSystemSoundPlayer

class BAChatController: JSQMessagesViewController {
	
	// MARK: Properties
	let rootRef = FIRDatabase.database().reference();
	var messages = [JSQMessage]()
	
	var userIsTypingRef: FIRDatabaseReference!
	var usersTypingQuery: FIRDatabaseQuery!
	private var localTyping = false
	var isTyping: Bool {
		get {
			return localTyping
		}
		set {
			localTyping = newValue
			userIsTypingRef.setValue(newValue)
		}
	}
	
	var outgoingBubbleImageView: JSQMessagesBubbleImage!
	var incomingBubbleImageView: JSQMessagesBubbleImage!
	
	var userToChat : User!;
	
	convenience init (with user: User){
		self.init();
		self.userToChat = user;
	}
	
	override func viewDidLoad() {
		
		// Navigation bar
		self.navigationController?.isNavigationBarHidden = false
		self.navigationController?.navigationBar.barTintColor = UIColor.white
		self.navigationController?.navigationBar.tintColor = ColorPalette.orange
		self.navigationController?.navigationBar.frame.setNewFrameHeight(55)
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		
		super.viewDidLoad()
		
		setupBubbles()

		// No avatars
		collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.init(width: 10, height: 10)
		collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
		
		self.title = userToChat.firstName
		
		UIApplication.shared.statusBarStyle = .default
		
		self.additionalContentInset = UIEdgeInsetsMake(70, 0, 0, 0);
		self.inputToolbar.contentView?.rightBarButtonItem?.setTitleColor(ColorPalette.orange, for: .normal)
		self.inputToolbar.contentView?.rightBarButtonItem?.setTitleColor(ColorPalette.orangeDarker, for: .highlighted)
		self.inputToolbar.contentView?.leftBarButtonItem = nil
		self.inputToolbar.contentView?.textView?.placeHolder = ""
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		observeMessages()
		observeTyping()
	    finishReceivingMessage()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	override func senderId() -> String {
		return FIRAuth.auth()!.currentUser!.uid;
	}
	
	override func senderDisplayName() -> String {
		return "DisplayName";
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
		return messages.count;
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData{
		return messages[indexPath.item]
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
		let message = messages[indexPath.item] // 1
		if message.senderId == senderId() { // 2
			return outgoingBubbleImageView
		} else { // 3
			return incomingBubbleImageView
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
		let message = messages[indexPath.item]
		
		if message.senderId == senderId() { // 1
			cell.textView!.textColor = UIColor.white // 2
		} else {
			cell.textView!.textColor = UIColor.black // 3
		}
		
		return cell
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
		return nil
	}
	
	func addMessage(id: String, text: String) {
		let message = JSQMessage(senderId: id, displayName: "", text: text)
		messages.append(message)
	}
	
	override func textViewDidChange(_ textView: UITextView) {
		super.textViewDidChange(textView)
		// If the text is not empty, the user is typing
		isTyping = textView.text != ""
	}
	
	private func setupBubbles() {
		let bubbleImageFactory = JSQMessagesBubbleImageFactory()
		outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImage(with: ColorPalette.argentinaBlue);
		incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
	}
	
	// FIREBASE METHODS // 
	
	private func observeTyping() {
		let typingIndicatorRef = rootRef.child("typingIndicator")
		userIsTypingRef = typingIndicatorRef.child(senderId())
		userIsTypingRef.onDisconnectRemoveValue()
		usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
		
		usersTypingQuery.observe(.value) { (data: FIRDataSnapshot!) in
			
			// You're the only typing, don't show the indicator
			if data.childrenCount == 1 && self.isTyping {
				return;
			}
			
			// Are there others typing?
			self.showTypingIndicator = data.childrenCount > 0
			self.scrollToBottom(animated: true)
		}
		
	}
	
	// gets new message
	// path to read message from: messages -> this_user_id (my inbox) -> user_im_chatting_with_id (messages recieved from him)
	private func observeMessages() {
		
		let messagesQuery = rootRef.child("messages").child(senderId()).child(userToChat.id);//.queryLimited(toLast: 25)
		messagesQuery.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
			
			let dictionary = snapshot.value as! NSDictionary;
			
			let senderId = dictionary["senderId"] as! String;
			let text = dictionary["text"] as! String;
			//let date = dictionary["timestamp"] as! TimeInterval;
			
			self.addMessage(id: senderId, text: text)
			
			self.finishReceivingMessage()
		}
	}
	
	// sends message
	// paths to insert message to: messages -> user_im_chatting_with_id -> this_user_id
	//		   					   messages -> this_user_id -> user_im_chatting_with_id
	// (due to double reference)
	override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date){
		
		let receiverRef = rootRef.child("messages").child(userToChat.id).child(senderId).childByAutoId()
		let senderRef = rootRef.child("messages").child(senderId).child(userToChat.id).childByAutoId()
		
		let messageItem = [
			"text": text,
			"senderId": senderId,
			"timestamp": NSDate().timeIntervalSince1970
		] as [String : Any]
		
		receiverRef.setValue(messageItem)
		senderRef.setValue(messageItem)
		
		//JSQSystemSoundPlayer.playSound(JSQSystemSoundPlayer)()
		
		finishSendingMessage()
		isTyping = false
	}
	
	
}
