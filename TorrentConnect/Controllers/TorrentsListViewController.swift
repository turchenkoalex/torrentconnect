//
//  TorrentsListViewController.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 19.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class TorrentsListViewController: NSViewController {

    @IBOutlet weak var pathMenu: NSMenu!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var segmentedController: NSSegmentedControl!

    fileprivate var _tableController: TableController<Torrent>!
    fileprivate let _torrentsGroupBy = TorrentsGroupBy()
    fileprivate var _sections = Sections<Torrent>(sections: [])
    fileprivate var _selectBehaviour: SelectBehaviourDelegate?
    fileprivate var _torrents = [Torrent]()
    fileprivate let _torrentFilter = TorrentFilter()
    fileprivate var filterText = ""
    fileprivate var _attachedHandler: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._tableController = TableController(groupBy: _torrentsGroupBy.byDownloadDir())
        self.tableView.doubleAction = #selector(self.doubleClick)
        
        _attachedHandler = TransmissionConnectManager.shared.fetchTorrentsEvent.addHandler(self, handler: TorrentsListViewController.fetchTorrents)
        
        TransmissionConnectManager.shared.connect()
        
        setupMenu()
    }
    
    func setupMenu() {
        let locations = TorrentLocations.all()
        for location in locations {
            let item = NSMenuItem(title: location.name, action: #selector(moveTorrents), keyEquivalent: "")
            item.representedObject = location.location
            pathMenu.addItem(item)
        }
        pathMenu.addItem(NSMenuItem.separator())
        pathMenu.addItem(NSMenuItem(title: "Trash", action: #selector(trashTorrents), keyEquivalent: ""))
    }
    
    func setupController(_ selectBehaviour: SelectBehaviourDelegate) {
        _selectBehaviour = selectBehaviour
    }
    
    func prepeareTorrents(_ torrents: [Torrent]) -> [Torrent] {
        let filtered = self._torrentFilter.filter(filterText, torrents: torrents)
        let sorted = filtered.sorted { $0.0.name < $0.1.name }
        return sorted
    }
    
    func fetchTorrents(_ torrents: [Torrent]) {
        self._torrents = torrents
        self.showTorrents()
    }
    
    func showTorrents() {
        let torrents = prepeareTorrents(_torrents)
        let sections = self._tableController.getSections(torrents, sections: _sections)
        applySections(sections)
    }
    
    func toggleSection(_ section: Section<Torrent>) {
        let sections = _sections.toggleSection(section.title)
        applySections(sections)
    }
    
    func applySections(_ sections: Sections<Torrent>) {
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
            insertedSet.add(i)
        }
        for i in changes.updated {
            updatedSet.add(i)
        }
        for i in changes.deleted {
            deletedSet.add(i)
        }
        
        DispatchQueue.main.async {
            if (insertedSet.count > 0 || deletedSet.count > 0 || updatedSet.count > 0) {
                self.tableView.beginUpdates()
                self.tableView.removeRows(at: deletedSet as IndexSet, withAnimation: NSTableViewAnimationOptions.slideUp)
                self.tableView.insertRows(at: insertedSet as IndexSet, withAnimation: NSTableViewAnimationOptions.slideUp)
                self.tableView.reloadData(forRowIndexes: updatedSet as IndexSet, columnIndexes: IndexSet(integer: 0))
                self.tableView.endUpdates()
            }
            
            for i in changes.sectionsUpdated {
                if let view = self.tableView.view(atColumn: 0, row: i, makeIfNecessary: true) as? TorrentTableHeaderView {
                    if let section = self._sections.sectionAt(i) {
                        let toggleSection = { () in
                            self.toggleSection(section)
                        }
                        view.setupView(section, toggleSection: toggleSection)
                    }
                }
            }
            
            self.tableViewSelectionDidChange(Notification(name: Notification.Name(rawValue: "updates"), object: nil))
            
            if (self._sections.totalCount == 0 || self._sections.totalCount == self._sections.sectionsCount) {
                self.tableView.reloadData()
            }
        }
    }
    
    func doubleClick() {
        let selection = tableView.selectedRowIndexes
        if (selection.count == 1) {
            if let torrent = self._sections.elementAt(selection.first!) {
                _selectBehaviour?.open(torrent)
            }
            return
        }
    }
    
    @IBAction func searchTextChanged(_ sender: AnyObject) {
        filterText = self.searchField.stringValue
        self.showTorrents()
    }
    
    @IBAction func segmentChanged(_ sender: AnyObject) {
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
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self._sections.totalCount
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return self._sections.isGroup(row)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if (self._sections.isGroup(row)) {
            return TorrentTableHeaderView.DefaultHeight
        }
        return TorrentTableCellView.DefaultHeight
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TorrentTableRowView()
        return rowView
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (self._sections.isGroup(row)) {
            let headerView = tableView.make(withIdentifier: "TorrentTableHeaderView", owner: self) as! TorrentTableHeaderView
            if let section = self._sections.sectionAt(row) {
                let toggleSection = { () in
                    self.toggleSection(section)
                }
                headerView.setupView(section, toggleSection: toggleSection)
                return headerView
            }
        }

        let cellView = tableView.make(withIdentifier: "TorrentTableCellView", owner: self) as! TorrentTableCellView
        if let model = self._sections.elementAt(row) {
            cellView.setupView(model)
        }
        
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return !self._sections.isGroup(row)
    }
    
    func selectedTorrents() -> [Torrent] {
        let selection = tableView.selectedRowIndexes
        var items = [Torrent]()
        for index in selection {
            if let torrent = _sections.elementAt(index) {
                items.append(torrent)
            }
        }
        
        return items
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        _selectBehaviour?.select(selectedTorrents())
    }
    
    func onDeselectTorrents() {
        DispatchQueue.main.async {
            self.tableView.deselectAll(self)
        }
    }
    
    func proceededClickTorrents() -> [Int] {
        let clickedRow = tableView.clickedRow
        if clickedRow != -1 && !tableView.isRowSelected(clickedRow) {
            if let torrent = _sections.elementAt(clickedRow) {
                return [torrent.id]
            }
        } else {
            return selectedTorrents().map { $0.id }
        }
        return []
    }
    
    func moveTorrents(_ item: NSMenuItem) {
        let ids = self.proceededClickTorrents()
        if let location = item.representedObject as? String {
            TransmissionConnectManager.shared.moveTorrents(ids, location: location) { }
        }
    }
    
    func trashTorrents(_ item: NSMenuItem) {
        let ids = self.proceededClickTorrents()
        TransmissionConnectManager.shared.deleteTorrents(ids) { }
    }
}
