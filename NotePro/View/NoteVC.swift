//
//  NoteVC.swift
//  NotePro
//
//  Created by Araceli Teixeira on 02/04/18.
//  Copyright © 2018 Orion Team. All rights reserved.
//

import UIKit
import CoreLocation
import AVKit
import AVFoundation
import MobileCoreServices

class NoteVC: UITableViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var subjectField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var photosScrollView: UIScrollView!
    
    public var note: Note?
    
    private let datePickerView: UIDatePicker = UIDatePicker()
    private let locationManager = CLLocationManager()
    private var subjectPickerView: SubjectPickerView?
    private var userLocation: CLLocationCoordinate2D?
    private var notePhotos = [UIImage]()
    
    @objc var lastChosenMediaType: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        CoreFacade.shared.fetchSubjectList()
        determineUserCurrentLocation(locationManager)
        configureTapGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initScreen()
        prepareToEditNote()
    }
    
    // MARK: - Init and Configure Screen
    fileprivate func initScreen() {
        setDefaultDate()
        createSubjectPicker(self.subjectField)
    }
    
    fileprivate func prepareToEditNote() {
        if let note = note {
            titleField.text = note.title
            descriptionField.text = note.description
            subjectPickerView?.selectedSubject = note.subject
            subjectField.text = note.subject.subject
            dateField.text = DateUtil.convertDateToString(note.dateTime, .medium, .short)
        }
    }
    
    fileprivate func setDefaultDate() {
        self.dateField.text = DateUtil.convertDateToString(Date(), .medium, .short)
    }
    
    fileprivate func configureTapGestures() {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            print("Camera it is not available")
        } else {
            configureTapGestureToTakePickture()
        }
        configureTapGestureToUsePicktureFromPhotoLibrary()
    }
    
    fileprivate func configureTapGestureToTakePickture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.shootPicture(sender:)))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
    }
    
    fileprivate func configureTapGestureToUsePicktureFromPhotoLibrary() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectExistingPicture))
        tap.delegate = self
        tap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
    }

    @IBAction func handleSubjectPicker(_ sender: UITextField) {
        createSubjectPicker(sender)
    }
    
    fileprivate func createSubjectPicker(_ sender: UITextField) {
        subjectPickerView = SubjectPickerView(subjectField: sender)
        sender.inputView = subjectPickerView?.pickerView
        subjectField.inputAccessoryView = createToolBarForSubject()
    }
    
    @IBAction func handleDatePicker(_ sender: UITextField) {
        createDataPicker(sender)
    }
    
    fileprivate func createDataPicker(_ sender: UITextField) {
        datePickerView.datePickerMode = .dateAndTime
        datePickerView.endEditing(true)
        datePickerView.isUserInteractionEnabled = true
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(NoteVC.hangleValueChange), for: .valueChanged)
        dateField.inputAccessoryView = createToolBar()
    }
    
    @objc func hangleValueChange() {
        handleDataPicker()
    }
    
    @objc func hangleValueChangeForSubject(subject: String) {
        subjectField.text = subject
    }
    
    fileprivate func createToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        toolBar.setItems(createButtons(), animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    fileprivate func handleDataPicker() {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateStyle = .medium
        dateTimeFormatter.timeStyle = .short
        dateField.text = DateUtil.convertDateToString(datePickerView.date, .medium, .short)
    }
    
    fileprivate func createButtons() -> [UIBarButtonItem] {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NoteVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NoteVC.cancelClick))
        let buttons: [UIBarButtonItem] = [cancelButton, spaceButton, doneButton]
        return buttons
    }
    
    @objc func doneClick() {
        handleDataPicker()
        dateField.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        dateField.resignFirstResponder()
    }
    
    fileprivate func createToolBarForSubject() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        toolBar.setItems(createButtonsForSubject(), animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    fileprivate func createButtonsForSubject() -> [UIBarButtonItem] {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NoteVC.doneClickForSubject))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NoteVC.cancelClickForSubject))
        let buttons: [UIBarButtonItem] = [cancelButton, spaceButton, doneButton]
        return buttons
    }
    
    @objc func doneClickForSubject() {
        subjectField.resignFirstResponder()
    }
    
    @objc func cancelClickForSubject() {
        subjectField.resignFirstResponder()
    }
    
    // MARK: - Save Note
    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        print("Prepare to Save Note")
        if let title = titleField.text,
            let description = descriptionField.text,
            let subject = subjectPickerView?.selectedSubject,
            let dateTime = dateField.text,
            let userLocation = self.userLocation {
            
            guard let dateTimeToObject = DateUtil.convertStringToDate(dateTime, .medium, .short) else {
                print("Error to parse the date")
                return
            }
            
            var upsertNode: Note
            if let note = note {
                upsertNode = Note(note.noteId, title, description, subject, datePickerView.date, userLocation, [])
            } else {
                upsertNode = Note(title, description, subject, dateTimeToObject)
                upsertNode.setLocation(userLocation)
            }
            
            CoreFacade.shared.saveNote(upsertNode)
            self.note = upsertNode

            /* Implement save image
             if let newNoteImage = noteImage {
             
             //newNote.addPhoto(Picture())
             }
             */
            
            print("Note saved")
            self.performSegue(withIdentifier: "unwindNotesOfSubject", sender: self)
        } else {
            print("Error to get informations")
        }
    }
    
    // MARK: - Navigation
    fileprivate func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "unwindNotesOfSubject":
            guard let destination = segue.destination as? NoteListTableVC else {
                print("Destination isn't a NoteListTableVC")
                return
            }
            destination.subject = subjectPickerView?.selectedSubject
        default:
            break
        }
     }
    

}

// MARK: - Subject Picker View
class SubjectPickerView: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var subjects: [Subject] = []
    var pickerView: UIPickerView = UIPickerView()
    var subjectField: UITextField
    var selectedSubject: Subject?
    
    init(subjectField: UITextField) {
        self.subjectField = subjectField
        super.init()
        self.pickerView.endEditing(true)
        self.pickerView.isUserInteractionEnabled = true
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.subjects = CoreFacade.shared.subjects
        self.pickerView.selectedRow(inComponent: 0)
        setDefaultSubject()
    }
    
    func setDefaultSubject() {
        if subjects.count > 0 {
            self.selectedSubject = subjects[0]
            self.subjectField.text = subjects[0].subject
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subjects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return subjects[row].subject
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.subjectField.text = subjects[row].subject
        self.selectedSubject = subjects[row]
    }
}

// MARK: - Location Manager Delegate
extension NoteVC: CLLocationManagerDelegate {
    
    func determineUserCurrentLocation(_ locationManager: CLLocationManager) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations[0].coordinate
        
        if self.userLocation != nil {
            locationManager.stopUpdatingLocation();
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error to get user location: \(error)")
    }
}

// MARK: - Image Picker Delegate
extension NoteVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func shootPicture(sender: UIButton) {
        pickMediaFromSource(UIImagePickerControllerSourceType.camera)
    }
    
    @objc func selectExistingPicture(sender: UIButton) {
        pickMediaFromSource(UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @objc func pickMediaFromSource(_ sourceType:UIImagePickerControllerSourceType) {
        let mediaTypes =
            UIImagePickerController.availableMediaTypes(for: sourceType)!
        if UIImagePickerController.isSourceTypeAvailable(sourceType)
            && mediaTypes.count > 0 {
            let picker = UIImagePickerController()
            picker.mediaTypes = mediaTypes
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = sourceType
            present(picker, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title:"Error accessing media",
                                                    message: "Unsupported media source.",
                                                    preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        lastChosenMediaType = info[UIImagePickerControllerMediaType] as? String
        if let mediaType = lastChosenMediaType {
            if mediaType == (kUTTypeImage as NSString) as String {
                guard let newImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
                    print("It was not possible to get selected image")
                    return
                }
                notePhotos.append(newImage)
                addNewImageToPhotosScrollView(newImage: newImage)
                
            } else {
                print("Error to compare kUTTypeImage")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func addNewImageToPhotosScrollView(newImage: UIImage) {
        let newImageView = UIImageView()
        newImageView.image = newImage
        newImageView.contentMode = .scaleAspectFit
        let xPosition = self.view.frame.width * CGFloat(notePhotos.count - 1)
        newImageView.frame = CGRect(x: xPosition, y: 0, width: self.photosScrollView.frame.width, height: self.photosScrollView.frame.height)
        
        photosScrollView.contentSize.width = photosScrollView.frame.width * CGFloat(notePhotos.count)
        photosScrollView.addSubview(newImageView)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

// MARK: - Gesture Delegate
extension NoteVC: UIGestureRecognizerDelegate {
    
}
