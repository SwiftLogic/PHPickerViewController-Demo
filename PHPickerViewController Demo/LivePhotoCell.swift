//
//  LivePhotoCell.swift
//  PHPickerViewController Demo
//
//  Created by Osaretin Uyigue on 7/23/22.
//

import UIKit
import PhotosUI
class LivePhotoCell: UICollectionViewCell {
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - Properties
    static let cellReuseIdentifier = String(describing: LivePhotoCell.self)
    
    fileprivate(set) lazy var livePhotoView: PHLivePhotoView = {
        let photoView = PHLivePhotoView()
        photoView.backgroundColor = .red
        photoView.translatesAutoresizingMaskIntoConstraints = false
//        photoView.delegate = self
        return photoView
    }()

    
    
    //MARK: - Methods
    fileprivate func setUpViews() {
        addSubview(livePhotoView)
        NSLayoutConstraint.activate([
            livePhotoView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            livePhotoView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            livePhotoView.widthAnchor.constraint(equalToConstant: frame.width),
            livePhotoView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
}
