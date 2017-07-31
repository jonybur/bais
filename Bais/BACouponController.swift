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
    var emptyStateCouponsNode = BAEmptyStateCouponsCellNode()
    var coupons = [String:Coupon]()
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
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
        node.addSubnode(emptyStateCouponsNode)
    }
    
    private func observeCoupons() {
        // observe coupons
        let userId = FirebaseService.currentUserId
        let userFriendsRef = FirebaseService.usersReference.child(userId).child("coupons")
        userFriendsRef.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
            guard let dictionary = snapshot.value as? NSDictionary else { return }
            let coupon = Coupon(from: dictionary, key: snapshot.key)
            if (!coupon.redeemed){
                coupon.fetchAdditionalData().then(execute: { _ -> Void in
                    self.coupons[coupon.promotionId] = coupon
                    self.tableNode.reloadData()
                }).catch(execute: { _ in })
            }
        }
        userFriendsRef.observe(.childChanged) { (snapshot: FIRDataSnapshot!) in
            guard let _ = snapshot.value as? NSDictionary else { return }
            self.coupons.removeValue(forKey: snapshot.key)
            self.tableNode.reloadData()
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
        let coupon = Array(coupons.values)[indexPath.item - 1]
        return BACouponCellNode(with: coupon)
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if (coupons.count > 0){
            // header and spacer
            emptyStateCouponsNode.alpha = 0
            return coupons.count + 2
        }
        // header and empty state box
        emptyStateCouponsNode.alpha = 1
        return 2
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            // show message alert
            let alert = UIAlertController(title: "Delete this coupon?", message: "You will lose access to this coupon\nThis action cannot be undone!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                let coupon = Array(self.coupons.values)[indexPath.item - 1]
                let userId = FirebaseService.currentUserId
                FirebaseService.usersReference.child(userId).child("coupons").child(coupon.promotionId).child("redeemed").setValue(true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        removeAction.backgroundColor = ColorPalette.orange
        return [removeAction]
    }
}

