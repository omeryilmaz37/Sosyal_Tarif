//
//  RegisterViewController.swift
//  Sosyal_Tarif
//
//  Created by Ömer Yılmaz on 4.05.2025.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    private func setupActions() {
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(goBackToLogin), for: .touchUpInside)
    }
}

// MARK: - Navigation
extension RegisterViewController {
    
    @objc private func goToHome() {
        let storyboard = UIStoryboard(name: "HomeViewController", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController {
            navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    @objc private func goBackToLogin() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Firebase Authentication
extension RegisterViewController {
    
    @objc private func registerButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let surname = surnameTextField.text, !surname.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let passwordAgain = passwordAgainTextField.text, !passwordAgain.isEmpty else {
            showAlertError(title: "Hata", message: "Lütfen tüm alanları doldurun.")
            return
        }

        guard password == passwordAgain else {
            showAlertError(title: "Hata", message: "Şifreler eşleşmiyor.")
            return
        }
                
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showAlertError(title: "Kayıt Hatası", message: error.localizedDescription)
                return
            }

            self?.showAlertSuccess(title: "Başarılı", message: "Kayıt başarılı! Anasayfaya yönlendiriliyorsunuz.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self?.goToHome()
            }
        }
    }
}

// MARK: - Alerts
extension RegisterViewController {
    
    private func showAlertSuccess(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

