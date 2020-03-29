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
    @IBOutlet weak var customColorButton: UIButton!
    @IBOutlet weak var customsCollectionView: UICollectionView!
    
    var delegate: SelectColorViewControllerDelegate! = nil
    
    var color: UIColor = UIColor.black
    var customColors: [UIColor] = []
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
            customColorButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
        } else {
            selectColorLabel.font = UIFont(name: systemFont, size: 30)
            customColorButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
        
        backgroundImageView.image = backgroundImage
        
        let cellSize = (view.frame.size.width - 2 * edgeInset) / CGFloat(itemsPerRow) - colorsBorder * 2
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        
        layout.minimumInteritemSpacing = colorsBorder
        layout.minimumLineSpacing = colorsBorder
        
        presetsCollectionView.collectionViewLayout = layout
        
        customColors = UserDefaults.colorsForKey(key: "customColors")
        
        presetsCollectionView.reloadData()
        customsCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.tag == 0 ? colorKeys.count : customColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            let cell = presetsCollectionView.dequeueReusableCell(withReuseIdentifier: "presetCell", for: indexPath)
            
            // Configure the cell
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = cell.bounds.width / 2
            cell.backgroundColor = colorKeys[indexPath.row]
            return cell
        } else {
            let cell = customsCollectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath)
            
            // Configure the cell
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = cell.bounds.width / 2
            cell.backgroundColor = customColors[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 {
            color = colorKeys[indexPath.row]
        } else {
            color = customColors[indexPath.row]
        }
        dismiss(animated: true, completion: nil)
        delegate.didSelectColorVC(controller: self)
    }
    
    @IBAction func customColor(_ sender: Any) {
        if proPaid {
            performSegue(withIdentifier: "customColorSegue", sender: nil)
        } else {
            self.present(createBasicAlert(title: "PRO Feature", message: "To get Cornhole Scorer PRO, go to the Settings tab"), animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // custom color segue
        let controller = segue.destination as! CustomColorViewController
        controller.controller = self
    }
}
