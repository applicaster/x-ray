//
//  LoggerViewCollectionFlowLayout.swift
//  LoggerInfo
//
//  Created by Alex Zchut on 19/08/2020.
//

import UIKit

final class LoggerViewCollectionFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup() {
        self.sectionInsetReference = .fromContentInset // .fromContentInset is default
        self.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.minimumInteritemSpacing = 10
        self.minimumLineSpacing = 10
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.headerReferenceSize = CGSize(width: 0, height: 0)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
        layoutAttributesObjects?.forEach({ layoutAttributes in
            if layoutAttributes.representedElementCategory == .cell {
                if let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                    layoutAttributes.frame = newFrame
                }
            }
        })
        return layoutAttributesObjects
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            fatalError()
        }
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }

        layoutAttributes.frame.origin.x = sectionInset.left
        layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        return layoutAttributes
    }
}

