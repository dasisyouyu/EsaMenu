//
//  EsaEntriesViewController.swift
//  EsaMenu
//
//  Created by horimislime on 9/18/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

class EsaEntriesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var progress: NSProgressIndicator! {
        didSet {
            progress.wantsLayer = true
            progress.layer?.backgroundColor = NSColor.clearColor().CGColor
        }
    }
    
    @IBOutlet weak var settingsButton: NSButton!
    
    @IBAction func settingsButtonTapped(sender: AnyObject) {
        let menu = NSMenu(title: "settings")
        menu.insertItemWithTitle("Quit", action: #selector(quitMenuTapped(_:)), keyEquivalent: "q", atIndex: 0)
        NSMenu.popUpContextMenu(menu, withEvent: NSApplication.sharedApplication().currentEvent!, forView: settingsButton)
    }
    
    func quitMenuTapped(sender: NSMenu) {
        print("quitMenuTapped")
        NSApplication.sharedApplication().terminate(sender)
    }
    
    private var entries = FetchedEntries()
    private weak var timer: NSTimer?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.cornerRadius = 4
        tableView.registerNib(NSNib(nibNamed: "EsaEntryCell", bundle: nil), forIdentifier: "EsaEntryCellIdentifier")
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.selectionHighlightStyle = .None
        tableView.focusRingType = .None
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(updatePosts(_:)), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func updatePosts(timer: NSTimer) {
        print("timer fired")
        progress.hidden = false
        progress.startAnimation(self)
        
        Entry.list() { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .Success(let entries):
                print("success")
                strongSelf.entries.push(entries)
                strongSelf.tableView.reloadData()
                
            case .Failure(_):
                print("error")
            }
            strongSelf.progress.hidden = true
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        tableView.gridColor = (entries.count == 0) ? NSColor.clearColor() : NSColor(type: .lightGray)
        return entries.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let cell = tableView.makeViewWithIdentifier("EsaEntryCellIdentifier", owner: self) as! EsaEntryCell
        cell.configure(entries.sorted()[row])
        cell.layoutSubtreeIfNeeded()
        return cell.frame.height
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("EsaEntryCellIdentifier", owner: self) as! EsaEntryCell
        cell.configure(entries.sorted()[row])
        return cell
    }
    
    func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
        
        if tableView.selectedRow == -1 { return true }
        
        let cell = tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: true)
        cell!.layer!.backgroundColor = NSColor.clearColor().CGColor
        return true
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: entries.sorted()[row].url)!)
        
        let cell = tableView.viewAtColumn(0, row: row, makeIfNecessary: true)
        cell!.layer!.backgroundColor = NSColor(type: .lightGray).CGColor
        return true
    }
}
