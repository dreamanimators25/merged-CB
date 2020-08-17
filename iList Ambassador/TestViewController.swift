//
//  TestViewController.swift
//  iList Ambassador
//
//  Created by Dmitriy on 01.10.2018.
//  Copyright © 2018 iList AB. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    var im: UIImage?
    var text: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UITextField(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        label.text = text
        label.textColor = UIColor.white
        view.addSubview(label)

//        let image = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
//        image.image = im
//        view.addSubview(image)
//
//        image.isUserInteractionEnabled = true
//        let ges = UITapGestureRecognizer.init(target: self, action: #selector(click))
//        image.addGestureRecognizer(ges)
        // Do any additional setup after loading the view.
    }
    
    
    func click() {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
