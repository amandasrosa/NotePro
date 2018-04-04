//
//  SubjectListTableVC.swift
//  NotePro
//
//  Created by Araceli Teixeira on 26/03/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit

class SubjectListTableVC: UITableViewController {
    private let cellNameAndId: String = String(describing: SubjectViewCell.self)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName: cellNameAndId, bundle: nil), forCellReuseIdentifier: cellNameAndId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTableList),
                                               name: NSNotification.Name(rawValue: kNOTIFICATION_SUBJECT_LIST_CHANGED), object: nil)
        CoreFacade.shared.fetchSubjectList()
    }

    @objc func updateTableList() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.contentOffset = .zero
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.performSegue(withIdentifier: "addSubject", sender: indexPath)
        }
        
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreFacade.shared.subjects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: cellNameAndId, for: indexPath)

        guard let cell = rawCell as? SubjectViewCell else {
            print("Error while retrieving cell \(cellNameAndId)")
            return rawCell
        }
        
        cell.configureCell(CoreFacade.shared.subjects[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showNotesOfSubject", sender: tableView.cellForRow(at: indexPath))
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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "showNotesOfSubject":
            guard let destination = segue.destination as? NoteListTableVC else {
                print("Destination isn't a NoteListTableVC")
                return
            }
            guard let index = tableView.indexPathForSelectedRow?.row else {
                print("Invalid index")
                return
            }
            destination.subject = CoreFacade.shared.subjects[index]
        case "addSubject":
            guard let destination = segue.destination as? SubjectVC else {
                print("Destination isn't a SubjectVC")
                return
            }
            guard let indexPath = sender as? IndexPath else {
                print("Invalid index")
                return
            }
            destination.subject = CoreFacade.shared.subjects[indexPath.row]
        default:
            break
        }
    }
    
    @IBAction func unwindToSubjectList(sender: UIStoryboardSegue) {
        
    }
}
