//
//  SubjectViewCell.swift
//  NotePro
//
//  Created by Araceli Teixeira on 26/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class SubjectViewCell: UITableViewCell {
    @IBOutlet weak private var colorView: UIView!
    @IBOutlet weak private var subjectLabel: UILabel!
    private var subject: Subject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        colorView.backgroundColor = subject.color
    }
    
    public func configureCell(_ subject: Subject) {
        self.subject = subject
        
        subjectLabel.text = subject.subject
        colorView.backgroundColor = subject.color
    }
}
