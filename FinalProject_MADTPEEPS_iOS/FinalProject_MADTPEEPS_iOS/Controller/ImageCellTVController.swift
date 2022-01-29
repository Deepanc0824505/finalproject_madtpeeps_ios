//
//  ImageCellTVController.swift
//  FinalProject_MADTPEEPS_iOS
//
//  Created by MADT Peeps on 2022-01-27.
//

import UIKit

class ImageCellTVController: UICollectionViewCell {
    
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var ivTask: UIImageView!
    
    var deleteButtonTapped:(()->())?
    var image:Data! {
        didSet {
            setData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUiView()
    }
    
    func initView() {
        ivTask.image = UIImage(systemName: "plus.rectangle.fill.on.folder.fill")
        ivTask.contentMode = .center
        btnDel.isHidden = true
    }
    
    func initUiView() {
        ivTask.layer.cornerRadius = 10
        ivTask.layer.masksToBounds = true
        
        btnDel.layer.cornerRadius = btnDel.frame.height/2
        btnDel.layer.masksToBounds = true
    }
    
    func setData() {
        ivTask.image = UIImage(data: image)
        ivTask.contentMode = .scaleAspectFill
    }
    
    
    
    @IBAction func deleteHandler(_ sender: UIButton) {
        self.deleteButtonTapped?()
    }
        
}
