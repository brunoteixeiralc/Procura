//
//  MenuViewController.swift
//  procura
//
//  Created by Bruno Lemgruber on 08/02/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate: class {
    func menuViewControllerSendEmail(_ controller: MenuViewController)
}

class MenuViewController: UITableViewController {
    
    weak var delegate:MenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MenuViewController{

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0{
            delegate?.menuViewControllerSendEmail(self)
        }
    }
}
