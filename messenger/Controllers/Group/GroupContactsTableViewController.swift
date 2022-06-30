//
//  GroupContactsTableViewController.swift
//  messenger
//
//  Created by Администратор on 30.05.2022.
//

import UIKit
import RealmSwift

class GroupContactsTableViewController: UITableViewController {
    
    var groups: [MGroupChat] = []
    private var currentUser: MUser!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Группы"
        self.currentUser = DbService.shared.currentUser
        self.groups = DbService.shared.allGroupChats()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelTapped))
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellContactsGroup", for: indexPath) as! GroupContactsTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.avatarImageView?.image = UIImage(data: groups[indexPath.row].avatarImage!)
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.height / 2
        cell.usernameLable?.text = groups[indexPath.row].nameGroup
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        let viewController = GroupChatViewController(user: currentUser, chat: group)
        self.navigationItem.backButtonTitle = "Назад"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func cancelTapped(){
        self.dismiss(animated: true, completion: nil)
    }

}

