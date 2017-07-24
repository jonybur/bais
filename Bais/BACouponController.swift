//
//  BACouponController.swift
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

class BACouponController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {
    
    var coupons = [Coupon]()
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    let _layoutInspector = MosaicCollectionViewLayoutInspector()
    
    init() {
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeCoupons()
    }
    
    private func observeCoupons() {
        // observe coupons
        let userId = FirebaseService.currentUserId
        let userFriendsRef = FirebaseService.usersReference.child(userId).child("coupons")
        userFriendsRef.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
            guard let dictionary = snapshot.value as? NSDictionary else { return }
            let coupon = Coupon(from: dictionary)
            if (!coupon.redeemed){
                coupon.fetchAdditionalData().then(execute: { _ -> Void in
                    self.coupons.append(coupon)
                    self.tableNode.reloadData()
                }).catch(execute: { _ in })
            }
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let item = indexPath.item
        
        if (item == 0){
            return BACouponHeaderCellNode()
        }
        
        if (item > coupons.count){
            return BASpacerCellNode()
        }
        
        let coupon = coupons[indexPath.item - 1]
        return BACouponCellNode(with: coupon)
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        let count = coupons.count > 0 ? coupons.count + 1 : 0 // for bottom spacer
        return count + 1 // for header
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            // show message alert
        }
        removeAction.backgroundColor = ColorPalette.orange
        return [removeAction]
    }
}

