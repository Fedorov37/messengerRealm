//
//  CreateGroupViewController.swift
//  messenger
//
//  Created by Администратор on 30.05.2022.
//

import UIKit

class CreateGroupViewController: UIViewController {

    
    @IBOutlet weak var avatarGroupImageView: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    
    @IBAction func addPhotoButton(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func addGroupButton(_ sender: UIButton) {
        if self.avatarGroupImageView.image == nil {
            self.showAlert(with: "Ошибка!", and: "Не заполнен аватар")
        }
        if self.groupNameTextField.text! == "" {
            self.showAlert(with: "Ошибка!", and: "Не заполнено наиманование")
        }
        let imageData = avatarGroupImageView.image!.jpeg(.highest)
        let chatGroup = MGroupChat(nameGroup: groupNameTextField.text!, avatar: imageData, adminUser: DbService.shared.currentUser, lastMessageContent: "")
        DbService.shared.createGroup(chat: chatGroup)
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CreateGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.avatarGroupImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
}

