//
//  ChatsTableViewController.swift
//  messenger
//
//  Created by Администратор on 20.02.2022.
//

import UIKit
import SwiftUI
import RealmSwift

class ChatsTableViewController: UITableViewController {

    var currentUser: MUser!

    var notificationToken : NotificationToken?

    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
        self.tableView.dataSource = self
        self.currentUser = DbService.shared.currentUser
        let chats = currentUser.chats
        notificationToken = chats
            .observe { [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .initial:
                    print(self.currentUser.chats.count)
                    self.tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                              with: .automatic)
                    self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                              with: .automatic)
                    self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                              with: .automatic)
                    self.tableView.endUpdates()
                    break
                case .error(let error):
                    fatalError(error.localizedDescription)
                    break
                }
            }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        self.tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Actions
    @IBAction func addBarButton(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "contactsSegue", sender: nil)
      }
 
    override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser.chats.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 70
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellChat", for: indexPath) as! ChatsTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.avatarImageView?.image = UIImage(data: currentUser.chats[indexPath.row].user!.avatarImage!)
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.height / 2
        cell.usernameLabel?.text = currentUser.chats[indexPath.row].user!.username
        cell.lastMessageLabel?.text = currentUser.chats[indexPath.row].lastMessageContent
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = currentUser.chats[indexPath.row]
        let viewController = ChatExampleViewController(user: currentUser, chat: chat)
        self.navigationItem.backButtonTitle = "Назад"
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            DbService.shared.deleteChat(chat: self.currentUser.chats[indexPath.row])
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])

        return configuration
    }
  }


