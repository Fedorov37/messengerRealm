//
//  ContactsTableViewController.swift
//  messenger
//
//  Created by Администратор on 10.03.2022.
//

import UIKit
import RealmSwift

class ContactsTableViewController: UITableViewController {
    
    var users: [MUser] = []
    private var currentUser: MUser!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Пользователи"
        self.currentUser = DbService.shared.currentUser
        self.users = DbService.shared.allUsers()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelTapped))
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellContacts", for: indexPath) as! ContactsTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.avatarImageView?.image = UIImage(data: users[indexPath.row].avatarImage!)
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.height / 2
        cell.usernameLable?.text = users[indexPath.row].username
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        var chat = user.chats.first(where: {$0.user == currentUser})
        if chat == nil{
            chat = MChat(user: user, lastMessageContent: "")
        }
        let viewController = ChatExampleViewController(user: currentUser, chat: chat!)
        viewController.modalPresentationStyle = .overFullScreen// .fullScreen
        self.navigationItem.backButtonTitle = "Назад"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func cancelTapped(){
        self.dismiss(animated: true, completion: nil)
    }
}
