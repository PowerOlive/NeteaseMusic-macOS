//
//  PlaylistViewController.swift
//  NeteaseMusic
//
//  Created by xjbeta on 2019/4/9.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class PlaylistViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var coverImageView: NSImageView!
    @IBOutlet weak var titleTextFiled: NSTextField!
    
    @IBOutlet weak var playCountTextField: NSTextField!
    @IBOutlet weak var trackCountTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    var sidebarItemObserver: NSKeyValueObservation?
    @objc dynamic var tracks = [PlayList.Track]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coverImageView.wantsLayer = true
        coverImageView.layer?.cornerRadius = 6
        coverImageView.layer?.borderWidth = 0.5
        coverImageView.layer?.borderColor = NSColor.tertiaryLabelColor.cgColor
        
        
        sidebarItemObserver = PlayCore.shared.observe(\.selectedSidebarItem, options: [.initial, .old, .new]) { core, changes in
            guard let new = changes.newValue,
                new?.type == .playlist || new?.type == .favourite,
                let id = new?.id,
                id > 0 else { return }
            
            PlayCore.shared.api.playlistDetail(id).done(on: .main) {
                self.coverImageView.image = NSImage(contentsOf: $0.coverImgUrl)
                self.titleTextFiled.stringValue = $0.name
                self.descriptionTextField.stringValue = $0.description ?? "none"
                self.playCountTextField.integerValue = $0.playCount
                self.trackCountTextField.integerValue = $0.trackCount
                self.tracks = $0.tracks ?? []
                }.catch {
                    print($0)
            }
        }
    }
    
    deinit {
        sidebarItemObserver?.invalidate()
    }
}

extension PlaylistViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return 10
    }
    
    
    
}
