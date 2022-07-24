//
//  TitleHeader.swift
//  PHPickerViewController Demo
//
//  Created by Osaretin Uyigue on 7/23/22.
//

import UIKit
class TitleHeader: UICollectionReusableView {
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Properties
    
    fileprivate(set) lazy var titleLabel = UILabel()

    
    fileprivate func setUpViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    
}
