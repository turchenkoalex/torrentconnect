//
//  TorrentsListViewController.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 19.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class TorrentsListViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var segmentedController: NSSegmentedControl!

    private var _tableController: TableController<TorrentModel>!
    private let _torrentsGroupBy = TorrentsGroupBy()
    private var _sections: Sections<TorrentModel> = Sections<TorrentModel>(sections: [])
    private var _selectBehaviour: SelectBehaviourDelegate?
    private var _torrents: [TorrentModel] = [TorrentModel]()
    private let _torrentFilter = TorrentFilter()
    private var filterText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._tableController = TableController(groupBy: _torrentsGroupBy.byDownloadDir())
        self.tableView.doubleAction = #selector(self.doubleClick)
        
        TransmissionConnectManager.sharedInstance.fetchTorrentsEvent.addHandler(self, handler: TorrentsListViewController.fetchTorrents)
        
        TransmissionConnectManager.sharedInstance.connect()
    }
    
    func setupController(selectBehaviour: SelectBehaviourDelegate) {
        _selectBehaviour = selectBehaviour
    }
    
    func prepeareTorrents(torrents: [TorrentModel]) -> [TorrentModel] {
        let filtered = self._torrentFilter.filter(filterText, torrents: torrents)
        let sorted = filtered.sort { $0.0.name < $0.1.name }
        return sorted
    }
    
    func fetchTorrents(torrents: [TorrentModel]) {
        self._torrents = torrents
        self.showTorrents()
    }
    
    func showTorrents() {
        let torrents = prepeareTorrents(_torrents)
        let sections = self._tableController.getSections(torrents, sections: _sections)
        applySections(sections)
    }
    
    func toggleSection(section: Section<TorrentModel>) {
        let sections = _sections.toggleSection(section.title)
        applySections(sections)
    }
    
    func applySections(sections: Sections<TorrentModel>) {
        let changes = SectionsDiff.getChanges(_sections, right: sections)
        _sections = sections
        
        if (changes.inserted.count == 0
            && changes.deleted.count == 0
            && changes.updated.count == 0
            && changes.sectionsUpdated.count == 0) {
            return
        }
        
        let insertedSet = NSMutableIndexSet()
        let updatedSet = NSMutableIndexSet()
        let deletedSet = NSMutableIndexSet()
        
        for i in changes.inserted {
            insertedSet.addIndex(i)
        }
        for i in changes.updated {
            updatedSet.addIndex(i)
        }
        for i in changes.deleted {
            deletedSet.addIndex(i)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            if (insertedSet.count > 0 || deletedSet.count > 0 || updatedSet.count > 0) {
                self.tableView.beginUpdates()
                self.tableView.removeRowsAtIndexes(deletedSet, withAnimation: NSTableViewAnimationOptions.SlideUp)
                self.tableView.insertRowsAtIndexes(insertedSet, withAnimation: NSTableViewAnimationOptions.SlideUp)
                self.tableView.reloadDataForRowIndexes(updatedSet, columnIndexes: NSIndexSet(index: 0))
                self.tableView.endUpdates()
            }
            
            for i in changes.sectionsUpdated {
                if let view = self.tableView.viewAtColumn(0, row: i, makeIfNecessary: true) as? TorrentTableHeaderView {
                    if let section = self._sections.sectionAt(i) {
                        let toggleSection = { () in
                            self.toggleSection(section)
                        }
                        view.setupView(section, toggleSection: toggleSection)
                    }
                }
            }
            
            self.tableViewSelectionDidChange(NSNotification(name: "updates", object: nil))
            
            if (self._sections.totalCount == 0 || self._sections.totalCount == self._sections.sectionsCount) {
                self.tableView.reloadData()
            }
        }
    }
    
    func doubleClick() {
        let selection = tableView.selectedRowIndexes
        if (selection.count == 1) {
            if let torrent = self._sections.elementAt(selection.firstIndex) {
                _selectBehaviour?.open(torrent)
            }
            return
        }
    }
    
    @IBAction func searchTextChanged(sender: AnyObject) {
        filterText = self.searchField.stringValue
        self.showTorrents()
    }
    
    @IBAction func segmentChanged(sender: AnyObject) {
        let selected = self.segmentedController.selectedSegment
        if (selected == 0) {
            self.segmentedController.setImage(NSImage(assetIdentifier: .Folder), forSegment: 0)
            self.segmentedController.setImage(NSImage(assetIdentifier: .DisabledBox), forSegment: 1)
            self._tableController = TableController(groupBy: _torrentsGroupBy.byDownloadDir())
        } else {
            self.segmentedController.setImage(NSImage(assetIdentifier: .DisabledFolder), forSegment: 0)
            self.segmentedController.setImage(NSImage(assetIdentifier: .Box), forSegment: 1)
            self._tableController = TableController(groupBy: _torrentsGroupBy.byState())
        }
        showTorrents()
    }
}

extension TorrentsListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self._sections.totalCount
    }
    
    func tableView(tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return self._sections.isGroup(row)
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if (self._sections.isGroup(row)) {
            return TorrentTableHeaderView.DefaultHeight
        }
        return TorrentTableCellView.DefaultHeight
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TorrentTableRowView()
        return rowView
    }

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (self._sections.isGroup(row)) {
            let headerView = tableView.makeViewWithIdentifier("TorrentTableHeaderView", owner: self) as! TorrentTableHeaderView
            if let section = self._sections.sectionAt(row) {
                let toggleSection = { () in
                    self.toggleSection(section)
                }
                headerView.setupView(section, toggleSection: toggleSection)
                return headerView
            }
        }

        let cellView = tableView.makeViewWithIdentifier("TorrentTableCellView", owner: self) as! TorrentTableCellView
        if let model = self._sections.elementAt(row) {
            cellView.setupView(model)
        }
        
        return cellView
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return !self._sections.isGroup(row)
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let selection = tableView.selectedRowIndexes
        var items = [TorrentModel]()
        for index in selection {
            if let torrent = _sections.elementAt(index) {
                items.append(torrent)
            }
        }
        _selectBehaviour?.select(items)
    }
}