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
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    var recordingUrl:URL!;
    
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
                recordingUrl =  URL(fileURLWithPath:filePath)
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
        if task == nil {
            var path = ""
            if(recordingUrl != nil){
                path = recordingUrl.path
            }
            delegate!.editTask(title: title, audio: path, dueDate: "\(datePicker.date)", currentDate: "\(Date())", images: images, isCompleted: false)
        } else {
            task.taskTitle = title
            if(recordingUrl != nil){
                task.taskAudio = recordingUrl.path
            } else {
                task.taskAudio = ""
            }
            task.taskImages = images
            task.taskEndDate = "\(datePicker.date)"
            task.taskStartDate = "\(Date())"
            task.isCompleted = false
            delegate?.editTask(currenttask: task)
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
            checkRecordPermission()
            audioLayout.isHidden = sender != btnAudioAdd
            btnAudioAdd.isHidden = sender == btnAudioAdd
            btnSaveAudio.isHidden = sender == btnAudioAdd
            if sender == btnCancelAudio {
                btnSaveAudio.isHidden = true
                btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
                if isRecording {
                    audioRecorder.stop()
                   // lblTimeAudio.text = "Tap + to play recorded audio"
                   // btnAudioAdd.setImage(UIImage(systemName: "play.fill"), for: .normal)
                }
                
                if isPlaying {
                    audioPlayer.stop()
                }
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
        if(isPlaying)
        {
            audioPlayer.stop()
            btnRecord.isEnabled = true
            btnSaveAudio.isEnabled = true
            btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
            btnPlaySaveAudio.setImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlaying = false
        }
        else
        {
            
          
            
            if FileManager.default.fileExists(atPath: recordingUrl.path)
            {
                btnRecord.isEnabled = false
                btnSaveAudio.isEnabled = false
                btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                btnPlaySaveAudio.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                preparePlay()
                audioPlayer.play()
                isPlaying = true
            }
            else
            {
                display_alert(msg_title: "Error", msg_desc: "Audio file is missing.", action_title: "OK")
            }
        }
    }
    
    @IBAction func deleteAudio(_ sender: UIButton) {
        recordingUrl = nil;
        btnAudioAdd.isHidden = false
        
        
        UIView.animate(withDuration: 0.25) {
            self.audioViewLayout.isHidden = true
        }
    }
    
    // MARK: Audio Methods
    func checkRecordPermission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isAudioRecordingGranted = true
            break
        case .denied:
            isAudioRecordingGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL
    {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
        return documentsUrl
    }
    
    func getFileUrl() -> URL
    {
        let now = Date()
          let formatter = DateFormatter()
          formatter.timeZone = TimeZone.current
          formatter.dateFormat = "yyyyMMddHHmmss"

          let dateString = formatter.string(from: now)
        let filename = dateString + ".m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        lblAudioName.text = filename
        return filePath
    }
    
    func setupRecorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                recordingUrl = getFileUrl()
                audioRecorder = try AVAudioRecorder(url: recordingUrl, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let _ {
              print("Error while playing audio")
            }
        }
        else
        {
            print("audio permission not granted")
        }
    }
    
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            lblTimeAudio.text = totalTimeString
//            btnRecord.setTitle(totalTimeString, for: .normal)
            audioRecorder.updateMeters()
        }
    }
    
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            print("recorded successfully.")
            lblTimeAudio.text = "Audio Recorded"

        }
        else
        {
           print("Audio Error")
        }
    }
    
    func preparePlay()
    {
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: recordingUrl)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch{
            print("Error")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            finishAudioRecording(success: false)
        }
        btnPlay.isEnabled = true
        btnSaveAudio.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        btnRecord.isEnabled = true
        btnSaveAudio.isEnabled = true
        btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        btnPlaySaveAudio.setImage(UIImage(systemName: "play.fill"), for: .normal)
        isPlaying = false
    }
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
                     {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
}


// MARK: For Collection View START
extension AddTaskController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCellTVController = collectionView.dequeueCell(for: indexPath)
        
        if images.count != indexPath.row {
            //not a last index
            cell.image = images[indexPath.row]
            cell.btnDel.isHidden = false
            cell.deleteButtonTapped = {
                let deleteActionSheetController = UIAlertController(title: "Alert", message: "Are you sure you want to delete?", preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                    self.images.remove(at: indexPath.row)
                    self.reloadCollectionView()
                }
                
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                    
                }
                
                deleteActionSheetController.addAction(deleteAction)
                deleteActionSheetController.addAction(cancelAction)
                
                self.present(deleteActionSheetController, animated: true, completion: nil)
            }
        } else {
            // last index add button should be shown
            cell.initView()
        }
        return cell
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
