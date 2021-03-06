//
//  OkTableViewDelegate.swift
//  OkDataSources
//
//  Created by Roberto Frontado on 2/17/16.
//  Copyright © 2016 Roberto Frontado. All rights reserved.
//

import UIKit

public class OkTableViewDelegate<T: OkViewDataSource>: OkViewDelegate<T>, UITableViewDelegate {
    
    public override init(dataSource: T, onItemClicked: (item: T.ItemType, position: Int) -> Void) {
        super.init(dataSource: dataSource, onItemClicked: onItemClicked)
    }
    
    // MARK: - Public methods
    // MARK: Pull to refresh
    public func setOnPullToRefresh(tableView: UITableView, onRefreshed: (refreshControl: UIRefreshControl) -> Void) {
        setOnPullToRefresh(tableView, onRefreshed: onRefreshed, refreshControl: nil)
    }
    
    public func setOnPullToRefresh(tableView: UITableView, onRefreshed: (refreshControl: UIRefreshControl) -> Void, var refreshControl: UIRefreshControl?) {
        configureRefreshControl(&refreshControl, onRefreshed: onRefreshed)
        tableView.addSubview(refreshControl!)
    }
    
    // MARK: UITableViewDelegate
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Ask for nextPage every time the user is getting close to the trigger treshold
        if dataSource.reverseItemsOrder {
            if reverseTriggerTreshold == indexPath.row
                && tableView.visibleCells.count > reverseTriggerTreshold {
                let inverseIndex = dataSource.items.count - indexPath.row - 1
                let item = dataSource.itemAtIndexPath(NSIndexPath(forItem: inverseIndex, inSection: 0))
                onPagination?(item: item)
            }
        } else {
            if (dataSource.items.count - triggerTreshold) == indexPath.row
                && indexPath.row > triggerTreshold {
                    onPagination?(item: dataSource.items[indexPath.row])
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
