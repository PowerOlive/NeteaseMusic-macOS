//
//  SongInfoViewController.swift
//  NeteaseMusic
//
//  Created by xjbeta on 2019/5/14.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class SongInfoViewController: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var secondNameTextField: NSTextField!
    @IBOutlet weak var albumButton: IdButton!
    @IBOutlet weak var artistStackView: NSStackView!
    @IBOutlet weak var artistScrollView: NSScrollView!
    @IBAction @objc func buttonAction(_ sender: IdButton) {
        if sender == albumButton {
            ViewControllerManager.shared.selectSidebarItem(.album, sender.id)
        } else {
            ViewControllerManager.shared.selectSidebarItem(.artist, sender.id)
        }
        
//        exit playingSongView
        if let vc = view.window?.windowController?.contentViewController as? MainViewController,
            vc.playingSongViewStatus != .hidden {
            vc.updatePlayingSongTabView(.main)
            vc.playingSongViewStatus = .hidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func initInfos(_ track: Track) {
        nameTextField.stringValue = track.name
        secondNameTextField.isHidden = track.secondName.isEmpty
        secondNameTextField.stringValue = track.secondName
        albumButton.title = track.album.name
        albumButton.id = track.album.id
        
        let buttons = track.artists.map { artist -> IdButton in
            let b = IdButton(title: artist.name, target: self, action: #selector(buttonAction(_:)))
            b.id = artist.id
            return b
        }
        
        artistStackView.arrangedSubviews.forEach {
            artistStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        buttons.enumerated().forEach {
            artistStackView.addArrangedSubview($0.element)
            if $0.offset < (buttons.count - 1) {
                let textField = NSTextField(labelWithString: "/")
                textField.textColor = .tertiaryLabelColor
                artistStackView.addArrangedSubview(textField)
            }
        }
    }
}
