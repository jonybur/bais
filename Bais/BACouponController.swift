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

class BACouponController: UIViewController, MosaicCollectionViewLayoutDelegate,
                            ASCollectionDataSource, ASCollectionDelegate {
    
    let collectionNode: ASCollectionNode!
    let _layoutInspector = MosaicCollectionViewLayoutInspector()
    let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
                                                        tintColor: ColorPalette.orangeLighter,
                                                        size: 80)
    var coupons = [Coupon]()
    
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
        
        observeCoupons()
        //activityIndicatorView?.startAnimating()
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
                    self.collectionNode.reloadData()
                }).catch(execute: { _ in })
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        collectionNode.frame = self.view.bounds
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
        return BACouponHeaderCellNode()
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return coupons.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let coupon = coupons[indexPath.item]
        return BACouponCellNode(with: coupon)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .normal, title: "Reject") { (rowAction, indexPath) in
            
        }
        removeAction.backgroundColor = ColorPalette.orange
        return [removeAction]
    }
    
//MARK: - MosaicCollectionViewLayoutDelegate delegate methods
    
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        return CGSize(width: 1, height: 0.457)
    }
        
//MARK: - Dealloc
    
    deinit {
        collectionNode.dataSource = nil
        collectionNode.delegate = nil
    }
}

