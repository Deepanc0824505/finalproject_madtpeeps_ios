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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        audioLayout.isHidden = true
        audioViewLayout.isHidden = true
    }

    
  
    
    @IBAction func createButtonHandler(_ sender: UIButton) {
        
    }
    
    
    @IBAction func addAudio(_ sender: UIButton) {

    }
    
    @IBAction func recordingHandler(_ sender: UIButton) {
       
    }
    
    @IBAction func saveAudio(_ sender: UIButton) {
       
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        
    }
    
    @IBAction func deleteAudio(_ sender: UIButton) {
        
    }
    
}
