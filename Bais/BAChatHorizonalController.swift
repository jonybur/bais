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
    
    let collectionNode: ASCollectionNode!
    var sessions = [Session]()
    
    required init(with sessions: [Session]) {
        
        self.sessions = sessions;
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionHeadersPinToVisibleBounds = true
        collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        
        extendedLayoutIncludesOpaqueBars = true
        
        collectionNode.dataSource = self
        collectionNode.delegate = self
        collectionNode.backgroundColor = ColorPalette.white
        collectionNode.view.showsHorizontalScrollIndicator = false
        collectionNode.view.showsVerticalScrollIndicator = false
        collectionNode.view.isScrollEnabled = true
        collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
    }
    
    required init(coder: NSCoder) {
        fatalError("Storyboards are not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubnode(collectionNode!)
    }
    
    override func viewWillLayoutSubviews() {
        collectionNode.frame = self.view.bounds
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
    
    //MARK: - Dealloc
    
    deinit {
        collectionNode.dataSource = nil
        collectionNode.delegate = nil
    }
}


