//
//  BSWaterfallView.swift
//  Bais
//
//  Created by Rajeev Gupta on 11/9/16.
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit
import FirebaseDatabase
import FirebaseAuth

var globalVar : CGFloat = 0;

class BSWaterfallView: UIViewController, MosaicCollectionViewLayoutDelegate, ASCollectionDataSource, ASCollectionDelegate {

	var _sections = [[User]]()
	let _collectionNode: ASCollectionNode!
	let _layoutInspector = MosaicCollectionViewLayoutInspector()
	let usersRef = FIRDatabase.database().reference().child("users")
	
	init (){
		let layout = MosaicCollectionViewLayout()
		layout.numberOfColumns = 2;
		layout.headerHeight = 80;
		_collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
		super.init(nibName: nil, bundle: nil);
		layout.delegate = self
		
		_collectionNode.dataSource = self;
		_collectionNode.delegate = self;
		_collectionNode.view.layoutInspector = _layoutInspector
		_collectionNode.backgroundColor = UIColor.white
		_collectionNode.view.isScrollEnabled = true
		_collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
		
		populateUsers();
	}
	
	private func populateUsers(){
		usersRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
			if let snapshotDictionary = snapshot.value as? NSDictionary{
				// sets a new section
				
				self._sections.append([]);
				
				//for _ in 0...1{
					for (_, value) in snapshotDictionary{
						if let userDictionary = value as? NSDictionary{
							let user = User(fromNSDictionary: userDictionary);
							self._sections[0].append(user);
						}
					}
				//}
			}
			
			self._collectionNode.reloadData();
		}
	}
	
	required init(coder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	deinit {
		_collectionNode.dataSource = nil;
		_collectionNode.delegate = nil;
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubnode(_collectionNode!)
	}
	
	override func viewWillLayoutSubviews() {
		_collectionNode.frame = self.view.bounds;
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
		let user = _sections[indexPath.section][indexPath.item]
		return BSWaterfallViewCell(with: user)
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
		let textAttributes : NSDictionary = [
			NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
			NSForegroundColorAttributeName: UIColor.gray
		]
		let textInsets = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 0)
		let textCellNode = ASTextCellNode(attributes: textAttributes as! [AnyHashable : Any], insets: textInsets)
		textCellNode.text = String(format: "Section %zd", indexPath.section + 1)
		return textCellNode;
	}
	
	func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
		return _sections.count
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
		return _sections[section].count
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
		let node = collectionNode(self._collectionNode, nodeForItemAt: originalItemSizeAtIndexPath);
		return (node as! BSWaterfallViewCell).ratio
	}
}

