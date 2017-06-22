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

class BAChatHorizonalController: UIViewController, MosaicCollectionViewLayoutDelegate, ASCollectionDataSource, ASCollectionDelegate {
    
    let _collectionNode: ASCollectionNode!
    let _layoutInspector = MosaicCollectionViewLayoutInspector()
    var sessions: [Session]!
    
    required init(with sessions: [Session]) {
        self.sessions = sessions;
        let layout = MosaicCollectionViewLayout(startsAt: 10)
        layout.numberOfColumns = 1
        _collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        layout.delegate = self
        
        extendedLayoutIncludesOpaqueBars = true
        
        _collectionNode.dataSource = self
        _collectionNode.delegate = self
        _collectionNode.view.layoutInspector = _layoutInspector
        _collectionNode.backgroundColor = ColorPalette.blue
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
    
    //MARK: - MosaicCollectionViewLayoutDelegate delegate methods
    
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        return CGSize(width: 1, height: 0.6)
    }
    
    //MARK: - Dealloc
    
    deinit {
        _collectionNode.dataSource = nil
        _collectionNode.delegate = nil
    }
}


