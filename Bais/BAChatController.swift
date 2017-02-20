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
	
	var session: Session?
	
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
    }
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		navigationController!.interactivePopGestureRecognizer!.delegate =  self
    }
    
	override func createTextMessage(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
		let textMessage = super.createTextMessage(text, isIncomingMessage: isIncomingMessage) as! MessageNode
		if (!isIncomingMessage){
			return textMessage
		}
		let avatarNode = ASNetworkImageNode()
		//avatarNode.setURL(URL(string: (user?.profilePicture)!), resetToDefault: false)
        textMessage.avatarNode = avatarNode
        return textMessage
    }
}
