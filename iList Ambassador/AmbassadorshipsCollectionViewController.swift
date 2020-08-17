//
//  AmbassadorshipsCollectionViewController.swift
//  iList Ambassador
//
//  Created by Pontus Andersson on 06/03/16.
//  Copyright © 2016 iList AB. All rights reserved.
//

import UIKit
import Crashlytics

protocol AmbassadorshipsCollectionViewControllerDelegate: class {
    func didTapAddButtonForAmbassadorshipsCollectionViewController(_ ambassadorshipsCollectionViewController: AmbassadorshipsCollectionViewController)
    func ambassadorshipsCollectionViewController(didSelectCell cell: BrandCollectionViewCell, forAmbassadorship ambassadorship: Ambassadorship)
    func deletionIsActive(_ active:Bool)
}

class AmbassadorshipsCollectionViewController: UICollectionViewController {

    weak var delegate: AmbassadorshipsCollectionViewControllerDelegate?
    
    var ambassadorships: [Ambassadorship]?

    var user: User? {
        didSet {
            self.userUpdated()
        }
    }
    var overLayViewHeight: CGFloat = 16.0
    var shouldWiggle: Bool = false
    var showUtilButtons: Bool = false
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AmbassadorshipsCollectionViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(lpgr)
        
        collectionView!.register(BrandCollectionViewCell.self, forCellWithReuseIdentifier: BrandCollectionViewCell.cellIdentifier)
        collectionView?.contentInset = UIEdgeInsets(top: overLayViewHeight, left: 0, bottom: -overLayViewHeight, right: 0)
    }

    // MARK: - User
    
    func userUpdated() {
        guard let user = user else {
            print("user not found in BrandsCollectionViewController")
            return
        }
        print("PRINTING USER")
        print(user.id)
        showUtilButtons = user.isCurrentUser
        if user.isCurrentUser {
            getAmbassadroships(user.id)
        } else {
            getAmbassadroshipsForOtherUser(user.id)
        }
    }
    
    func getAmbassadroships(_ id: Int) {
        AmbassadorshipManager.sharedInstance.getAmbassadorshipsForUser(id, page: 1, pageSize: 20) { (ambassadorships, error) in
            if let ambassadorships = ambassadorships {
                self.ambassadorships = ambassadorships
                self.collectionView?.reloadData()
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    func getAmbassadroshipsForOtherUser(_ id: Int) {
        AmbassadorshipManager.sharedInstance.getAmbassadorshipsForAnyUser(id, page: 1, pageSize: 20) { (ambassadorships, error) in
            if let ambassadorships = ambassadorships {
                self.ambassadorships = ambassadorships
                self.collectionView?.reloadData()
            } else if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let ambassadorships = ambassadorships {
            return ambassadorships.count + (showUtilButtons ? 1 : 0)
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrandCollectionViewCell.cellIdentifier, for: indexPath) as! BrandCollectionViewCell
        
        cell.delegate = self
        
        if let ambassadorships = ambassadorships {
            if showUtilButtons && indexPath.row == 0 {
                cell.setAddStyle()
            } else {
                let row = indexPath.row - (showUtilButtons ? 1 : 0)
                let ambassadorship = ambassadorships[row]
                cell.updateWithBrand(ambassadorship.brand)
                if shouldWiggle {
                    cell.wiggleCell(row)
                } else {
                    cell.stopWiggleCell()
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let height = (collectionView.frame.size.height) / 2.3
        var size = CGSize(width: height, height: height)
        
        if showUtilButtons && indexPath.row == 0 {
            if let image = UIImage(named: "add_brand_small") {
                size.width = image.size.width
            } else {
                size.width = 44
            }
            size.height = size.width
        }
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let height = collectionView.frame.height / 2.3
        let edgeInset = (collectionView.frame.height - height) / 2
        return UIEdgeInsets(top: edgeInset, left: 28, bottom: edgeInset, right: 28)
    }
    
    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let ambassadorships = ambassadorships {
            if showUtilButtons && indexPath.row == 0 {
                delegate?.didTapAddButtonForAmbassadorshipsCollectionViewController(self)
            } else {
                if !shouldWiggle {
                    let row = indexPath.row - (showUtilButtons ? 1 : 0)
                    let ambassadorship = ambassadorships[row]
                    if let cell = collectionView.cellForItem(at: indexPath) as? BrandCollectionViewCell {
                        delegate?.ambassadorshipsCollectionViewController(didSelectCell: cell, forAmbassadorship: ambassadorship)
                    }
                }
            }
        }
    }
}

extension AmbassadorshipsCollectionViewController: BrandCollectionViewCellDelegate {
    
    func didTapDelete(forCell cell: BrandCollectionViewCell) {
        guard let indexPath = self.collectionView?.indexPath(for: cell), let ambassadorships = ambassadorships else {
            return
        }
        
        let ambassadorship = ambassadorships[indexPath.row - (showUtilButtons ? 1 : 0)]
    
        let message = String(format: NSLocalizedString("REVOKE_AMBASSDORSHIP_MESSAGE", comment: ""), ambassadorship.brand.name)
        let alertController = UIAlertController(title: nil, message: "Do you want to opt out of the channel?", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { (action: UIAlertAction) in
            self.revokeAmbassadorship(ambassadorship)
            alertController.dismiss(animated: true)
        }))
            
        alertController.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action: UIAlertAction) in
            alertController.dismiss(animated: true)
        }))
        
        present(alertController, animated: true)
    }
    
    private func revokeAmbassadorship(_ ambassadorship: Ambassadorship) {
        AmbassadorshipManager.sharedInstance.revokeAmbassadorship(ambassadorship, completion: { [weak self] (error: Error?) in
            if let _ = error {
                self?.showErrorAlert(withMessage: "Error revoking ambassadorship")
            } else {
                self?.shouldWiggle = false
                self?.toggleCellWiggle()
                self?.userUpdated()
            }
        })
    }
}

extension AmbassadorshipsCollectionViewController: UIGestureRecognizerDelegate {
    @objc func handleLongPress(_ gestureRecognizer : UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: self.collectionView)
        if let _ : IndexPath = self.collectionView?.indexPathForItem(at: p) {
            if !shouldWiggle {
                delegate?.deletionIsActive(true)
                shouldWiggle = true
                toggleCellWiggle()
            }
        }
    }
    func didLongPress() {
        if !shouldWiggle {
            delegate?.deletionIsActive(true)
            shouldWiggle = true
            toggleCellWiggle()
        }
    }
    func toggleCellWiggle() {
        let cells = collectionView?.visibleCells as! [BrandCollectionViewCell]
        var i = 0
        for cell in cells {
            if shouldWiggle {
                cell.wiggleCell(i)
            } else {
                cell.stopWiggleCell()
            }
            i += 1
        }
    }
}

extension AmbassadorshipsCollectionViewController : BrandConnectDelegate {
    func successfullySignForNewAmbassadorship(_ ambassador: Ambassadorship) {
        self.ambassadorships?.append(ambassador)
        self.collectionView?.reloadData()
    }
}
class BrandsCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        minimumInteritemSpacing = 15.0
        minimumLineSpacing = 0.0
    }

}
