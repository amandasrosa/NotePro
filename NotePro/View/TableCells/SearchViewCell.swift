//
//  SearchViewCell.swift
//  NotePro
//
//  Created by Araceli Teixeira on 13/04/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class SearchViewCell: UITableViewCell {
    @IBOutlet weak var searchByLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var heigthConstraint: NSLayoutConstraint!
    var completionHandler: ((String)->Void)?
    public var isExpanded = false
    {
        didSet
        {
            if !isExpanded {
                self.heigthConstraint.constant = 0.0
                
            } else {
                self.heigthConstraint.constant = 30.0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        backgroundColor = UIColor.white
    }
    
    public func setLabel(_ text: String) {
        searchByLabel.text = text
    }
    
    public func setCallback(_ completionHandler: @escaping ((String)->Void)) {
        self.completionHandler = completionHandler
    }
    
    @IBAction func doSearch(_ sender: UIButton) {
        if let handler = completionHandler, let text = searchTextField.text {
            handler(text)
        }
    }
}
