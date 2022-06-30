//
//  RegistrationViewController.swift
//  messenger
//
//  Created by Администратор on 27.02.2022.
//

import UIKit

class RegistrationViewController: UIViewController {

    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
    }
    @IBAction func selectPhotoButton(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func singUpButton(_ sender: UIButton) {
        
        if passwordTextField.text != confirmPasswordTextField.text {
            self.showAlert(with: "Ошибка!", and: "Пароли не совпадают")
            return
        }
        if self.avatarImageView.image == nil {
            self.showAlert(with: "Ошибка!", and: "Не заполнен аватар")
        }
        DbService.shared.saveUser(email: loginTextField.text!, username: userNameTextField.text!, avatarImage: avatarImageView.image!, password: passwordTextField.text!){(result) in
            switch result {
            case .success(_):
                //self.showAlert(with: "Успешно!", and: "Данные сохранены!", completion: {
                    self.performSegue(withIdentifier: "chatsSegue", sender: nil)
                //})
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
}


extension UIViewController {
    func showAlert(with title: String, and message: String, completion: @escaping () -> Void = {}) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.avatarImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
}
