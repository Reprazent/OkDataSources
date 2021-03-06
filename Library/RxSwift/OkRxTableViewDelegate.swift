//
//  OkRxTableViewDelegate.swift
//  OkDataSources
//
//  Created by Roberto Frontado on 4/22/16.
//  Copyright © 2016 Roberto Frontado. All rights reserved.
//

import UIKit
import RxSwift

public class OkRxTableViewDelegate<T: OkViewDataSource>: OkRxViewDelegate<T>, UITableViewDelegate {
    
    private var tableView: UITableView!
    
    public override init(dataSource: T, onItemClicked: (item: T.ItemType, position: Int) -> Void) {
        super.init(dataSource: dataSource, onItemClicked: onItemClicked)
    }
    
    // MARK: - Public methods
    // MARK: Pull to refresh
    public func setOnPullToRefresh(tableView: UITableView, onRefreshed: () -> Observable<[T.ItemType]>) {
        setOnPullToRefresh(tableView, onRefreshed: onRefreshed, refreshControl: nil)
    }
    
    public func setOnPullToRefresh(tableView: UITableView, onRefreshed: () -> Observable<[T.ItemType]>, var refreshControl: UIRefreshControl?) {
        self.tableView = tableView
        configureRefreshControl(&refreshControl, onRefreshed: onRefreshed)
        tableView.addSubview(refreshControl!)
    }
    
    override func refreshControlValueChanged(refreshControl: UIRefreshControl) {
        super.refreshControlValueChanged(refreshControl)
        onRefreshed?()
            .observeOn(MainScheduler.instance)
            .subscribeNext { items in
                self.dataSource.items.removeAll()
                self.dataSource.items.appendContentsOf(items)
                self.tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDelegate
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Ask for nextPage every time the user is getting close to the trigger treshold
        if dataSource.reverseItemsOrder {
            if reverseTriggerTreshold == indexPath.row
                && tableView.visibleCells.count > reverseTriggerTreshold {
                let reverseIndex = dataSource.items.count - indexPath.row - 1
                let item = dataSource.itemAtIndexPath(NSIndexPath(forItem: reverseIndex, inSection: 0))
                onPagination?(item: item)
                    .observeOn(MainScheduler.instance)
                    .subscribeNext { items in
                        if items.isEmpty { return }
                        self.dataSource.items.appendContentsOf(items)
                        let beforeHeight = tableView.contentSize.height
                        let beforeOffsetY = tableView.contentOffset.y
                        tableView.reloadData()
                        tableView.contentOffset = CGPoint(x: 0, y: (tableView.contentSize.height - beforeHeight + beforeOffsetY))
                }
                
            }
        } else {
            if (dataSource.items.count - triggerTreshold) == indexPath.row
                && indexPath.row > triggerTreshold {
                onPagination?(item: dataSource.items[indexPath.row])
                    .observeOn(MainScheduler.instance)
                    .subscribeNext { items in
                        if items.isEmpty { return }
                        self.dataSource.items.appendContentsOf(items)
                        tableView.reloadData()
                }
            }
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var item = dataSource.itemAtIndexPath(indexPath)
        
        if dataSource.reverseItemsOrder {
            let inverseIndex = dataSource.items.count - indexPath.row - 1
            item = dataSource.itemAtIndexPath(NSIndexPath(forItem: inverseIndex, inSection: 0))
            onItemClicked(item: item, position: inverseIndex)
        } else {
            onItemClicked(item: item, position: indexPath.row)
        }
    }
}