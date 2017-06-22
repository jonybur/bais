//
//  BAChatHorizontalScrollCellNode.swift
//  BAIS
//
//  Created by jbursztyn on 6/19/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import DGActivityIndicatorView

class BAChatHorizonalController: UIViewController, ASCollectionDataSource, ASCollectionDelegate {
    
    let _collectionNode: ASCollectionNode!
    var sessions: [Session]!
    
    required init(with sessions: [Session]) {
        self.sessions = sessions;
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        _collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        
        extendedLayoutIncludesOpaqueBars = true
        
        _collectionNode.dataSource = self
        _collectionNode.delegate = self
        _collectionNode.backgroundColor = ColorPalette.white
        _collectionNode.view.showsHorizontalScrollIndicator = false
        _collectionNode.view.showsVerticalScrollIndicator = false
        _collectionNode.view.isScrollEnabled = true
        _collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
    }
    
    required init(coder: NSCoder) {
        fatalError("Storyboards are not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubnode(_collectionNode!)
    }
    
    override func viewWillLayoutSubviews() {
        _collectionNode.frame = self.view.bounds
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let session = sessions[indexPath.item]
        let chatHorizontalCellNode = BAChatHorizonalCellNode(with: session)
        return chatHorizontalCellNode
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
        return ASCellNode()
    }
    
    //MARK: - Dealloc
    
    deinit {
        _collectionNode.dataSource = nil
        _collectionNode.delegate = nil
    }
}


