//
//  SearchResultViewController.swift
//  NeteaseMusic
//
//  Created by xjbeta on 2019/5/29.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class SearchResultViewController: NSViewController {
    
    @IBOutlet weak var contentTabView: NSTabView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    @IBAction func selectNewType(_ sender: NSSegmentedControl) {
        guard let type = SearchSuggestionsViewController.GroupType(rawValue: sender.selectedSegment + 1),
            type != resultType else { return }
        
        ViewControllerManager.shared.selectedSidebarItem = .init(title: "", id: sender.selectedSegment + 1, type: .searchResults)
    }
    
    var sidebarItemObserver: NSKeyValueObservation?
    var pageData = (count: 0, current: 0)
    var resultType: SearchSuggestionsViewController.GroupType = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sidebarItemObserver = ViewControllerManager.shared.observe(\.selectedSidebarItem, options: [.initial, .old, .new]) { [weak self] core, changes in
            guard let newV = changes.newValue,
                let newValue = newV else { return }
            let id = newValue.id
            guard newValue.type == .searchResults,
                let type = SearchSuggestionsViewController.GroupType(rawValue: id) else { return }
            self?.initContentView(type)
        }
        
    }
    
    func initContentView(_ type: SearchSuggestionsViewController.GroupType) {
        let index = type.rawValue - 1
        guard index >= 0 else { return }
        segmentedControl.setSelected(true, forSegment: index)
        
        resultType = type
        initResults()
    }
    
    func initResults(_ offset: Int = 0) {
        guard let pageVC = pageSegmentedControlViewController(),
            let trackVC = trackTableVC(),
            let albumArtistVC = albumArtistTableVC() else {
                return
        }
        
        let type = resultType
        switch type {
        case .songs:
            trackVC.resetData()
            contentTabView.selectTabViewItem(at: 0)
        default:
            albumArtistVC.resetData(type, responsiveScrolling: false)
            contentTabView.selectTabViewItem(at: 1)
        }
        
        pageVC.delegate = self
        let keywords = ViewControllerManager.shared.searchFieldString
        let limit = resultType == .songs ? 100 : 20
        pageData.current = offset
        
        PlayCore.shared.api.search(keywords, limit: limit, page: offset, type: resultType).done {
            guard type == self.resultType,
                offset == self.pageData.current else { return }
            
            print("Update search result with \(keywords), page \(offset), limit \(limit).")
            
            var pageCount = 0
            
            switch type {
            case .songs:
                var tracks = $0.songs
                tracks.enumerated().forEach {
                    tracks[$0.offset].index = $0.offset + (offset * limit)
                }
                trackVC.songs = tracks
                pageCount = Int(ceil(Double($0.songCount) / Double(limit)))
            case .albums:
                albumArtistVC.albums = $0.albums
                pageCount = Int(ceil(Double($0.albumCount) / Double(limit)))
            case .artists:
                albumArtistVC.artists = $0.artists
                pageCount = Int(ceil(Double($0.artistCount) / Double(limit)))
            case .playlists:
                albumArtistVC.playlists = $0.playlists
                pageCount = Int(ceil(Double($0.playlistCount) / Double(limit)))
            default:
                break
            }
            
            self.pageData = (pageCount, offset)
            pageVC.reloadData()
            
            if type == .songs {
                trackVC.tableView.reloadData()
                self.initLayoutConstraint(trackVC.tableView)
            } else {
                albumArtistVC.tableView.reloadData()
                self.initLayoutConstraint(albumArtistVC.tableView)
            }
            
            }.catch {
                print($0)
        }
    }
    
    func pageSegmentedControlViewController() -> PageSegmentedControlViewController? {
        let vc = children.compactMap {
            $0 as? PageSegmentedControlViewController
            }.first
        return vc
    }
    
    func trackTableVC() -> TrackTableViewController? {
        let vc = children.compactMap {
            $0 as? TrackTableViewController
            }.first
        return vc
    }
    
    func albumArtistTableVC() -> AlbumArtistTableViewController? {
        let vc = children.compactMap {
            $0 as? AlbumArtistTableViewController
            }.first
        return vc
    }
    
    func initLayoutConstraint(_ tableView: NSTableView) {
        let headerViewHeight = tableView.headerView?.frame.height ?? 0
        let height = tableView.intrinsicContentSize.height + tableView.intercellSpacing.height + headerViewHeight
        tableHeightLayoutConstraint.constant = height
    }
    
    deinit {
        sidebarItemObserver?.invalidate()
    }
}


extension SearchResultViewController: PageSegmentedControlDelegate {
    func currentPage() -> Int {
        return pageData.current
    }
    
    func numberOfPages() -> Int {
        return pageData.count
    }
    
    func clickedPage(_ number: Int) {
        initResults(number)
    }
}
