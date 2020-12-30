//
//  FilterViewController.swift
//  Pods
//
//  Created by Anton Kononenko on 12/28/20.
//

import UIKit
import XrayLogger

class FilterViewController: UIViewController {
    var data:[String] = []
    let cellIdentifier = "FilterDataCell"
    
    @IBOutlet var saveFilterDataButton: FilterButton!
    @IBOutlet var addFilterItemButton: FilterButton!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        saveFilterDataButton.backgroundColor = LogLevel.debug.toColor()
        addFilterItemButton.backgroundColor = LogLevel.info.toColor()
        
        let bundle = Bundle(for: type(of: self))
        tableView.register(UINib(nibName: cellIdentifier,
                                 bundle: bundle), forCellReuseIdentifier: cellIdentifier)
        tableView.isEditing = true

    }
    
    @IBAction func saveFilterData(_ sender: UIButton) {
        
        // Apply Settings
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func addFilterItem(_ sender: UIButton) {
        
    }
}

extension FilterViewController: UITableViewDelegate {
    
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
            //data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath) as? FilterDataCell

//        if indexPath.row == 0 {
//            updateTypeCell(indexPath: indexPath,
//                           cell: cell)
//        } else {
//            updateDetailCell(indexPath: indexPath,
//                             cell: cell)
//        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Foo")
       //            objects.remove(at: indexPath.row)
       //            tableView.deleteRows(at: [indexPath], with: .fade)
               }
    }
    
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let movedObject = self.headlines[sourceIndexPath.row]
//        headlines.remove(at: sourceIndexPath.row)
//        headlines.insert(movedObject, at: destinationIndexPath.row)
    }
    

    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }
    
}
