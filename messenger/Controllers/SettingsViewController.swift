//
//  SettingsViewController.swift
//  messenger
//
//  Created by Администратор on 20.02.2022.
//

import UIKit
import SDWebImage

class SettingsViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userLoginTextField: UITextField!
    var currentUser: MUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUser = DbService.shared.currentUser
        userLoginTextField.text = currentUser.email
        userNameTextField.text = currentUser.username
        avatarImageView.image = UIImage(data: currentUser.avatarImage!)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
        self.reloadInputViews()
    }
    
    @IBAction func editAvatarButton(_ sender: UIButton) {
        
    }
    
    @IBAction func userNameSend(_ sender: UITextField) {
        
    }
    
    @IBAction func logOutButton(_ sender: UIButton) {
        let alertController = UIAlertController(
          title: nil,
          message: "Вы действительно хотите выйти?",
          preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)

        let signOutAction = UIAlertAction(
          title: "Выйти",
          style: .destructive) { _ in
          do {
              DbService.shared.currentUser = nil
              self.dismiss(animated: true, completion: nil)
          }
        }
        alertController.addAction(signOutAction)

        present(alertController, animated: true)
    }
}
