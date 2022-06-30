//
//  ViewController.swift
//  messenger
//
//  Created by Администратор on 20.02.2022.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {

    var currentUser: MUser!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //errorLabel.alpha = 0
        
    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        DbService.shared.getUser(email: loginTextField.text!, password: passwordTextField.text!){ (result) in
            switch result {
            case .success(_):
                self.performSegue(withIdentifier: "chatsSegue", sender: nil)
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
}

