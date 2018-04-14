//
//  NoteListTableVC.swift
//  NotePro
//
//  Created by Araceli Teixeira on 28/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class NoteListTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var expandBtn: UIButton!
    
    private let cellNameAndId: String = String(describing: NoteViewCell.self)
    public var subject: Subject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        expandBtn.titleLabel?.text = "Expand"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellNameAndId, bundle: nil), forCellReuseIdentifier: cellNameAndId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTableList),
                                               name: NSNotification.Name(rawValue: kNOTIFICATION_NOTE_LIST_CHANGED), object: nil)
        
        CoreFacade.shared.fetchNoteList(subject)
    }
    
    @objc func updateTableList() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.contentOffset = .zero
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this note?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                CoreFacade.shared.deleteNote(CoreFacade.shared.notes[indexPath.row]);
                CoreFacade.shared.fetchNoteList(self.subject)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.performSegue(withIdentifier: "addNote", sender: indexPath)
        }
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreFacade.shared.notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: cellNameAndId, for: indexPath)
        
        guard let cell = rawCell as? NoteViewCell else {
            print("Error while retrieving cell \(cellNameAndId)")
            return rawCell
        }
        cell.configureCell(CoreFacade.shared.notes[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showNoteDetails", sender: tableView.cellForRow(at: indexPath))
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    @IBAction func expandBtnTouchUpInside(_ sender: UIButton) {
        guard let label = expandBtn.titleLabel else {
            print("Button label is invalid")
            return
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "showNoteDetails":
            guard let destination = segue.destination as? NoteVC else {
                print("Destination isn't a NoteVC")
                return
            }
            guard let index = tableView.indexPathForSelectedRow?.row else {
                print("Invalid index")
                return
            }
            destination.note = CoreFacade.shared.notes[index]
        default:
            break
        }
    }
    
    @IBAction func unwindToNoteList(sender: UIStoryboardSegue) {
        guard let destination = sender.source as? NoteVC else {
            print("Destination isn't a NoteVC")
            return
        }
        guard let subjectFromNote = destination.note?.subject else {
            print("Invalid Subject")
            return
        }
        subject = subjectFromNote
    }
}

extension UIView {
    
    func slideY(_ y: CGFloat) {
        
        let x = self.frame.origin.x
        
        let height = self.frame.height
        let width = self.frame.width
        
        UIView.animate(withDuration: 1.0, animations: {
            self.frame = CGRect(x: x, y: y, width: width, height: height)
        })
    }
}

extension UIView {
    func animateTo(frame: CGRect, withDuration duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        guard let _ = superview else {
            return
        }
        
        let xScale = frame.size.width / self.frame.size.width
        let yScale = frame.size.height / self.frame.size.height
        let x = frame.origin.x + (self.frame.width * xScale) * self.layer.anchorPoint.x
        let y = frame.origin.y + (self.frame.height * yScale) * self.layer.anchorPoint.y
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            self.layer.position = CGPoint(x: x, y: y)
            self.transform = self.transform.scaledBy(x: xScale, y: yScale)
        }, completion: completion)
    }
    
    func animateY(y: CGFloat, withDuration duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        let frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.width, height: self.frame.height)
        
        animateTo(frame: frame, withDuration: duration, completion: completion)
    }
}
