//
//  HelpCell.swift
//  Swipe
//
//  Created by Josh Doman on 12/2/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class HelpCell: UICollectionViewCell {
    
    var homeController: HomeController?
    
    lazy var getHelpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 110, g: 151, b: 261)
        button.setTitle("Help", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 50
        button.addTarget(self, action: #selector(handleGetHelp), for: .touchUpInside)//TODO-- change selector back to handleGetHelp
        
        return button
    }()
    
    func handleGetHelp() {
        homeController?.handleNextCell()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(getHelpButton)
        
        getHelpButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        getHelpButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        getHelpButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        getHelpButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
