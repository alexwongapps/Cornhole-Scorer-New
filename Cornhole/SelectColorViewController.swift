//
//  SelectColorViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 3/16/20.
//  Copyright © 2020 Kids Can Code. All rights reserved.
//

import UIKit

protocol SelectColorViewControllerDelegate {
    func didSelectColorVC(controller: SelectColorViewController)
}

class SelectColorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var selectColorLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var presetsCollectionView: UICollectionView!
    
    var delegate: SelectColorViewControllerDelegate! = nil
    
    var color: UIColor = UIColor.black
    let itemsPerRow = 5
    let edgeInset: CGFloat = 10
    let colorsBorder: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }

        // Do any additional setup after loading the view.
        
        // fonts
        if bigDevice() {
            
            selectColorLabel.font = UIFont(name: systemFont, size: 60)
            
        } else {
            
            selectColorLabel.font = UIFont(name: systemFont, size: 30)
        }
        
        backgroundImageView.image = backgroundImage
        
        let cellSize = (view.frame.size.width - 2 * edgeInset) / CGFloat(itemsPerRow) - colorsBorder * 2
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        
        layout.minimumInteritemSpacing = colorsBorder
        layout.minimumLineSpacing = colorsBorder
        
        presetsCollectionView.collectionViewLayout = layout
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = presetsCollectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
        
        // Configure the cell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = cell.bounds.width / 2
        cell.backgroundColor = colorKeys[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        color = colorKeys[indexPath.row]
        dismiss(animated: true, completion: nil)
        delegate.didSelectColorVC(controller: self)
    }
}
