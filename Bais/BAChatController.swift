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

class BAChatController: NMessengerViewController {
	
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
		self.messagePadding = UIEdgeInsets(top: 0, left: 10, bottom: 5, right: 10)
		observeMessages()
    }
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		navigationController!.interactivePopGestureRecognizer!.delegate =  self
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

}
