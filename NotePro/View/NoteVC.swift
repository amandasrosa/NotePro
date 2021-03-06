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
    @IBOutlet weak var readItButton: UIButton!
    
    public var note: Note?
    public var subject: Subject?
    public var backSegue: String?
    
    private let datePickerView: UIDatePicker = UIDatePicker()
    private let locationManager = CLLocationManager()
    private let spk = AVSpeechSynthesizer()
    private var subjectPickerView: SubjectPickerView?
    private var userLocation: CLLocationCoordinate2D?
    private var notePhotos = [Picture]()
    private var defaultUIImageView: UIImageView?
    
    
    @objc var lastChosenMediaType: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        CoreFacade.shared.fetchSubjectList()
        determineUserCurrentLocation(locationManager)
        configureTapGestures()
        initScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Init and Configure Screen
    fileprivate func initScreen() {
        setDefaultDate()
        createSubjectPicker(self.subjectField)
        prepareToEditNote()
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            spk.stopSpeaking(at: .word)
        }
    }
    
    fileprivate func setDefaultDate() {
        self.dateField.text = DateUtil.convertDateToString(Date(), .medium, .short)
    }
    
    fileprivate func prepareToEditNote() {
        if let note = note {
            titleField.text = note.title
            descriptionField.text = note.description
            subjectPickerView?.selectedSubject = note.subject
            subjectField.text = note.subject.subject
            datePickerView.date = note.dateTime
            dateField.text = DateUtil.convertDateToString(note.dateTime, .medium, .short)
            notePhotos = note.photos
            loadImagesToPhotosScrollView()
        }

        if titleField.text!.isEmpty && descriptionField.text!.isEmpty {
            readItButton.isHidden = true
        } else {
            readItButton.isHidden = false
        }
        
        if notePhotos.count <= 0 {
            setDefaultUIImage()
        }
        
        if let subject = subject {
            subjectPickerView?.selectedSubject = subject
            subjectField.text = subject.subject
        }
    }
    
    fileprivate func setDefaultUIImage() {
        defaultUIImageView = createNewImageForPhotoScrollView(image: UIImage(named: "default")!, xPosition: 0, contentMode: .scaleAspectFill)
        photosScrollView.addSubview(defaultUIImageView!)
        photosScrollView.setNeedsDisplay()
        self.view.setNeedsDisplay()
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
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.shootPicture(sender:)))
        longPress.numberOfTapsRequired = 0
        longPress.minimumPressDuration = 1.0
        
        longPress.delegate = self

        self.view.addGestureRecognizer(longPress)
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
        if let title = titleField.text,
            let description = descriptionField.text,
            let subject = subjectPickerView?.selectedSubject,
            let dateTime = dateField.text,
            let userLocation = self.userLocation {
            
            if title.isEmpty || description.isEmpty {
                let alert = UIAlertController(title: "Alert", message: "Title and description must be provided!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
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
            upsertNode.setPhotos(notePhotos)
            CoreFacade.shared.saveNote(upsertNode)
            self.note = upsertNode
            
            if let backSegue = backSegue {
                self.performSegue(withIdentifier: backSegue, sender: self)
            } else {
                print("Error to get the backSegue")
            }
            
        } else {
            print("Error to get informations")
        }
    }
    
    @IBAction func readNoteTitleAndDescription(_ sender: UIButton) {
        let voice = AVSpeechSynthesisVoice(language: "en-ca")
        let textToRead = "Title: \(titleField.text!). Description: \(descriptionField.text!)"
        let toSay = AVSpeechUtterance(string: textToRead)
        toSay.voice = voice
        spk.speak(toSay)
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
        case "showMap":
            guard let destination = segue.destination as? MapVC else {
                print("Destination isn't a MapVC")
                return
            }
            destination.location = userLocation
        default:
            break
        }
     }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && photosScrollView.subviews.count > 1 {
            return 20
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && notePhotos.count > 1 {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
            label.textAlignment = .center
            label.textColor = UIColor.darkGray
            label.text = "Number of pictures: \(notePhotos.count)"
            footerView.addSubview(label)
            return footerView
        }
        return nil
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
        print("lat: \(userLocation?.latitude) | long: \(userLocation?.longitude)")
        
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
        print("Test Camera")
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
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        lastChosenMediaType = info[UIImagePickerControllerMediaType] as? String
        if let mediaType = lastChosenMediaType {
            if mediaType == (kUTTypeImage as NSString) as String {
                guard let newImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
                    print("It was not possible to get selected image")
                    return
                }

                let imageName = "notePotho\(Int((Date().timeIntervalSince1970 * 1000.0).rounded())).png"
                saveImage(imageName: imageName, image: newImage)
                
                loadImagesToPhotosScrollView()
            } else {
                print("Error to compare kUTTypeImage")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveImage(imageName: String, image: UIImage){
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        print(imagePath)
        let data = UIImagePNGRepresentation(image)
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
        let picture = Picture(image, imageName)
        notePhotos.append(picture)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func loadImagesToPhotosScrollView() {
        
        if notePhotos.count > 0 {
            defaultUIImageView?.removeFromSuperview()
        }
        
        for i in 0..<notePhotos.count {
            let newImageView = createNewImageForPhotoScrollView(path: notePhotos[i].path, xPosition: i, contentMode: .scaleAspectFit)
            photosScrollView.contentSize.width = self.view.frame.width * CGFloat(i + 1)
            photosScrollView.addSubview(newImageView)
            newImageView.setNeedsDisplay()
            
            tableView.reloadData()
        }

        photosScrollView.setNeedsDisplay()
        self.view.setNeedsDisplay()

    }
    
    private func createNewImageForPhotoScrollView(image: UIImage, xPosition: Int, contentMode: UIViewContentMode) -> UIImageView {
        let newImageView = UIImageView()
        newImageView.image = image
        newImageView.contentMode = contentMode
        let xPosition = self.view.frame.width * CGFloat(xPosition)
        newImageView.frame = CGRect(x: xPosition, y: 0, width: view.frame.width, height: self.photosScrollView.frame.height)
        return newImageView
    }
    
    private func createNewImageForPhotoScrollView(path: String, xPosition: Int, contentMode: UIViewContentMode) -> UIImageView {
        let newImageView = UIImageView()
        guard let image = getImage(imageName: path) else {
            print("Error loading image")
            return newImageView
        }
        newImageView.image = image
        newImageView.contentMode = contentMode
        let xPosition = self.view.frame.width * CGFloat(xPosition)
        newImageView.frame = CGRect(x: xPosition, y: 0, width: view.frame.width, height: self.photosScrollView.frame.height)
        return newImageView
    }
    
    func getImage(imageName: String) -> UIImage? {
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)
        }else{
            print("Error loading image")
            return nil
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    

}

// MARK: - Gesture Delegate
extension NoteVC: UIGestureRecognizerDelegate {
    
}
