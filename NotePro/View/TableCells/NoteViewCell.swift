//
//  NoteViewCell.swift
//  NotePro
//
//  Created by Araceli Teixeira on 28/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class NoteViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var color: UIView!
    private var note: Note!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        color.backgroundColor = note.subject.color
    }
    
    public func configureCell(_ note: Note) {
        self.note = note
        
        titleLabel.text = note.title
        descriptionLabel.text = note.description
        dateTimeLabel.text = DateUtil.convertDateToString(note.dateTime)
        color.backgroundColor = note.subject.color
    }
}
