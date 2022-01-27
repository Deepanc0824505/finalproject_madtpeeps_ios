//
//  AddTaskController.swift
//  FinalProject_MADTPEEPS_iOS
//
//  Created by MADT Peeps on 2022-01-27.
//

import UIKit
import CoreData
import AVFoundation

class AddTaskController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var btnSaveAudio: UIButton!
    @IBOutlet weak var btnCancelAudio: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPlaySaveAudio: UIButton!
    @IBOutlet weak var btnAudioAdd: UIButton!
    @IBOutlet weak var audioViewLayout: UIStackView!
    @IBOutlet weak var imgListView: UICollectionView!
    @IBOutlet weak var audioLayout: UIStackView!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet var lblTimeAudio: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var tftaskTitle: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lblAudioName: UILabel!
    @IBOutlet weak var norecordingLayout: UIStackView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedTask: Task? {
        didSet {
            editMode = true
        }
    }
    
    // edit mode by default is false
    var editMode: Bool = false
    
    // an in instance of the noteTVC in noteVC - delegate
    weak var delegate: TaskTVController?
    
    
    var category = [Category]()
    var selectedCategory: Category!

    var task: Task! = nil
    var taskList = [Task]()
    
    var images: [Data] = []
    var imagePicker: ImagePicker?
    var audio = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        audioLayout.isHidden = true
        audioViewLayout.isHidden = true
        setupCollectionView()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = (task != nil ? "Edit" : "Add") + " Task"
    }
    
    func setupData() {
        if task != nil {
            tftaskTitle.text = task!.taskTitle
            self.images = task.taskImages!
            btnAdd.setTitle("Update", for: .normal)
            btnAdd.setTitleColor(.black, for: .normal)

            datePicker.date = task.taskEndDate!.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss Z") ?? Date()
            self.title = "Update Task"
            if task.taskAudio != nil {
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                 let url = URL(fileURLWithPath: path)
                lblAudioName.text = "\(task.taskAudio?.split(separator: "/").last ?? "No Recorded File")"
                let fileUrl = url.appendingPathComponent(lblAudioName.text!)

                let filePath = fileUrl.path
                 let fileManager = FileManager.default
                 if fileManager.fileExists(atPath: filePath) {
                     print("FILE AVAILABLE")
                 } else {
                     print("FILE NOT AVAILABLE")
                 }
                btnAudioAdd.isHidden = true
                audioViewLayout.isHidden = false
                if lblAudioName.text == "No Recorded File" {
                    btnAudioAdd.isHidden = false
                    norecordingLayout.isHidden = true
                }
                
            }
            
        } else {
            btnAdd.setTitle("Create", for: .normal)
            btnAdd.setTitleColor(.black, for: .normal)
            self.navigationItem.title = "Add"
        }
        
        
    }
    
    func setupCollectionView() {
        imgListView.dataSource = self
        imgListView.delegate = self
    }
    

    func reloadCollectionView() {
        self.imgListView.reloadData()
    }
    
    @IBAction func createButtonHandler(_ sender: UIButton) {
        guard let title = tftaskTitle.text, !title.isEmpty else {
            self.alert(message: "Title is required", title: "Alert", okAction: nil)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func alert(message: String?, title: String? = nil, okAction: (()->())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            okAction?()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addAudio(_ sender: UIButton) {
        if !tftaskTitle.text!.isEmpty {
            audioLayout.isHidden = sender != btnAudioAdd
            btnAudioAdd.isHidden = sender == btnAudioAdd
            btnSaveAudio.isHidden = sender == btnAudioAdd
            if sender == btnCancelAudio {
                btnSaveAudio.isHidden = true
                btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        } else {
            self.alert(message: "Title is required", title: "Alert", okAction: nil)
        }
        
    }
    
    @IBAction func recordingHandler(_ sender: UIButton) {
       
    }
    
    @IBAction func saveAudio(_ sender: UIButton) {
        audioLayout.isHidden = true
        audioViewLayout.isHidden = false
        norecordingLayout.isHidden = false
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        
    }
    
    @IBAction func deleteAudio(_ sender: UIButton) {
        
    }

}


// MARK: For Collection View START
extension AddTaskController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if images.count == indexPath.row {
            // add new image
            imagePicker = ImagePicker(presentationController: self)
            imagePicker?.present(from: self.view)
            imagePicker?.completion = { [weak self] selectedImage in
                guard let self = self else { return }
                let imageData = selectedImage.jpegData(compressionQuality: 0.8)!
                self.images.append(imageData)
                self.reloadCollectionView()
            }
        }
    }
    
    
}

extension AddTaskController: UICollectionViewDelegateFlowLayout {
    // Define size of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height
        return CGSize(width: height, height: height) // square cell
    }
    
    // Padding for inner view in collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

extension UICollectionView {
    
    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as! T
    }
    
}
extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
