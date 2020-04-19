//
//  CustomColorViewController.swift
//  Cornhole Scorer
//
//  Created by Alex Wong on 3/26/20.
//  Copyright © 2020 Kids Can Code. All rights reserved.
//

import UIKit

class CustomColorViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var customColorLabel: UILabel!
    @IBOutlet weak var rLabel: UILabel!
    @IBOutlet weak var gLabel: UILabel!
    @IBOutlet weak var bLabel: UILabel!
    @IBOutlet weak var rSlider: UISlider!
    @IBOutlet weak var gSlider: UISlider!
    @IBOutlet weak var bSlider: UISlider!
    @IBOutlet weak var rNumber: UILabel!
    @IBOutlet weak var gNumber: UILabel!
    @IBOutlet weak var bNumber: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    var controller: SelectColorViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        backgroundImageView.image = backgroundImage
        
        if bigDevice() {
            customColorLabel.font = UIFont(name: systemFont, size: 60)
            rLabel.font = UIFont(name: systemFont, size: 60)
            gLabel.font = UIFont(name: systemFont, size: 60)
            bLabel.font = UIFont(name: systemFont, size: 60)
            rNumber.font = UIFont(name: systemFont, size: 60)
            gNumber.font = UIFont(name: systemFont, size: 60)
            bNumber.font = UIFont(name: systemFont, size: 60)
            doneButton.titleLabel?.font = UIFont(name: systemFont, size: 30)
        } else {
            customColorLabel.font = UIFont(name: systemFont, size: 30)
            rLabel.font = UIFont(name: systemFont, size: 30)
            gLabel.font = UIFont(name: systemFont, size: 30)
            bLabel.font = UIFont(name: systemFont, size: 30)
            rNumber.font = UIFont(name: systemFont, size: 30)
            gNumber.font = UIFont(name: systemFont, size: 30)
            bNumber.font = UIFont(name: systemFont, size: 30)
            doneButton.titleLabel?.font = UIFont(name: systemFont, size: 17)
        }
        
        let defaultColor = UIColor.red
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        defaultColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        rSlider.value = Float(r)
        gSlider.value = Float(g)
        bSlider.value = Float(b)
        
        colorView.layer.masksToBounds = true
        colorView.layer.cornerRadius = colorView.bounds.width / 2
        colorView.backgroundColor = defaultColor
    }

    @IBAction func colorChanged(_ sender: Any) {
        colorView.backgroundColor = UIColor(red: CGFloat(rSlider.value), green: CGFloat(gSlider.value), blue: CGFloat(bSlider.value), alpha: 1)
    }
    
    @IBAction func saveColor(_ sender: Any) {
        let r = CGFloat(rSlider.value)
        let g = CGFloat(gSlider.value)
        let b = CGFloat(bSlider.value)
        
        let newColor = UIColor(red: r, green: g, blue: b, alpha: 1)
        
        var customs = UserDefaults.colorsForKey(key: "customColors")
        customs.insert(newColor, at: 0)
        UserDefaults.setColors(colors: customs, forKey: "customColors")
        
        controller?.viewDidLoad()
        dismiss(animated: true, completion: nil)
    }
}
