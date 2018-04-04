//
//  ViewController.swift
//  NotePro
//
//  Created by Araceli Teixeira on 24/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        CoreFacade.shared.createTables()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

