//
//  ViewController.swift
//  NotePro
//
//  Created by Araceli Teixeira on 24/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var labelInitial: UILabel!
    @IBOutlet var btn1: UIButton!
    @IBOutlet var btn2: UIButton!
    @IBOutlet var btn3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "noteBack")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        labelInitial.font = UIFont(name:"chalkduster", size: 25.0)
        btn1.titleLabel?.font =  UIFont(name:"chalkduster", size: 20)
        btn2.titleLabel?.font =  UIFont(name:"chalkduster", size: 20)
        btn3.titleLabel?.font =  UIFont(name:"chalkduster", size: 20)
        CoreFacade.shared.initDatabase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMenuView(sender: UIStoryboardSegue) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "addNote":
            guard let destination = segue.destination as? NoteVC else {
                print("Destination isn't a NoteVC")
                return
            }
            destination.backSegue = "unwindToMenuView"
        default:
            break
        }
    }

}

