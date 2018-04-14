//
//  SortViewCell.swift
//  NotePro
//
//  Created by Araceli Teixeira on 13/04/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class SortViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        backgroundColor = UIColor.white
    }
    
    @IBAction func sortByTitle(_ sender: UIButton) {
        CoreFacade.shared.sortNoteByTitle()
    }
    
    @IBAction func sortByDate(_ sender: UIButton) {
        CoreFacade.shared.sortNoteByDate()
    }
    
}
