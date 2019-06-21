//
//  HelpTableViewController.swift
//  Clew
//
//  Created by tad on 6/18/19.
//  Copyright © 2019 OccamLab. All rights reserved.
//

import Foundation

///The view controller which handles the Help table documentation
class HelpTableViewController: UIViewController {
    
    ///create a new helpviewmodel which handles calculations regarding the table view
    fileprivate let viewModel = HelpViewModel()
    
    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView?
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        ///calls default behavior
        super.viewDidLoad()
        
        ///reloads the table
        viewModel.reloadSections = { [weak self] (section: Int) in
            self?.tableView?.beginUpdates()
            self?.tableView?.reloadSections([section], with: .fade)
            self?.tableView?.endUpdates()
        }
        
        ///Listens for notifications from the child that the cells with website vies need to be reloaded to display properly
        NotificationCenter.default.addObserver(forName: Notification.Name("webContentLoaded"), object: nil, queue: nil) { (notification) -> Void in
            
            ///makes sure that the object provided by the notification is in the proper format
            guard let object = notification.object as? (CGFloat, Int) else {
                print("unexpected object sent with notification")
                return
            }
            
            ///if the size of the webpage is equal to the unadjusted height
            if object.0 == CGFloat(200){
                ///reload the section with that web page
                //self.tableView?.setNeedsLayout()
                self.viewModel.reloadSections!(object.1)
            }
        }

        ///sets the dimensions for each row and the headers
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.sectionHeaderHeight = 70
        ///do not display dividers in the table
        tableView?.separatorStyle = .none
        //sets the data source for the table as the view model so that the view model dictates what information is given to the table
        tableView?.dataSource = viewModel
        ///sets the view model as the delegate for the table
        tableView?.delegate = viewModel as UITableViewDelegate
        ///registers all the different types of cells that can be used
        tableView?.register(HelpSectionCell.nib, forCellReuseIdentifier: HelpSectionCell.identifier)
        ///registers the header this one is important and needs to stay
        tableView?.register(HeaderView.nib, forHeaderFooterViewReuseIdentifier: HeaderView.identifier)
    }
    
    /// This is called when the view should close.  This method posts a notification "ClewPopoverDismissed" that can be listened to if an object needs to know that the view is being closed.
    @objc func doneWithHelp() {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("ClewPopoverDismissed"), object: nil)
    }
}