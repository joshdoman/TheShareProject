//
//  PendingCell.swift
//  Swipe
//
//  Created by Josh Doman on 12/2/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class PendingCell: UICollectionViewCell, UITextFieldDelegate {
    
    var homeController: HomeController?
    
    var timer: Timer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
    }
    
    let pendingLabel: UILabel = {
        let label = UILabel()
        label.text = "You're request is pending"
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = UIColor(r: 110, g: 151, b: 261)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    func setupViews() {
        addSubview(pendingLabel)

        
        pendingLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pendingLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        pendingLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        pendingLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
