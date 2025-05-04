//
//  ViewController.swift
//  Sosyal_Tarif
//
//  Created by Ömer Yılmaz on 4.05.2025.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    private var passwordToggleButton = UIButton(type: .custom)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLoadingIndicator()
    }

    private func setupUI() {
        loginButton.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }
}

// MARK: - Navigation Controller
extension ViewController {
    
    @objc private func handleRegister() {
        let storyboard = UIStoryboard(name: "RegisterViewController", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private func goHomeView() {
        let storyboard = UIStoryboard(name: "HomeViewController", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        navigationController?.pushViewController(homeVC, animated: true)
    }
}

// MARK: - UI Setup
extension ViewController {
    
    private func setupLoadingIndicator() {
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = UIColor.white
        view.addSubview(loadingIndicator)
    }
}

// MARK: - Firebase Authentication
extension ViewController {
    
    @objc private func handleLogin(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlertError(title: "Eksik Bilgi", message: "Lütfen e-posta ve şifre girin.")
            return
        }
        
        guard isValidEmail(email) else {
            showAlertError(title: "Hatalı Giriş", message: "Geçersiz e-posta formatı.")
            return
        }

        guard isValidPassword(password) else {
            showAlertError(title: "Hatalı Giriş", message: "Şifre en az 6 karakter olmalı.")
            return
        }

        loadingIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }

            if let error = error {
                self?.handleAuthError(error)
            } else {
                self?.showAlertSuccess(title: "Giriş Başarılı", message: "Hoş geldiniz!") {
                    self?.goHomeView()
                }
            }
        }
    }
}

// MARK: - Error Helpers
extension ViewController {
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^\\S{6,25}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    private func handleAuthError(_ error: Error) {
        let nsError = error as NSError

        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            showAlertError(title: "HATA", message: "Bilinmeyen bir hata oluştu: \(nsError.localizedDescription)")
            return
        }

        switch errorCode {
        case .invalidEmail:
            showAlertError(title: "HATA", message: "Geçersiz E-posta Adresi.")
        case .userNotFound:
            showAlertError(title: "HATA", message: "Bu e-posta ile kayıtlı bir kullanıcı bulunamadı.")
        case .wrongPassword, .invalidCredential:
            showAlertError(title: "HATA", message: "Şifreniz yanlış. Lütfen tekrar deneyin.")
        case .networkError:
            showAlertError(title: "HATA", message: "İnternet bağlantısı yok.")
        default:
            showAlertError(title: "HATA", message: "Bir hata oluştu: \(nsError.localizedDescription)")
        }
    }
}

// MARK: - Alerts
extension ViewController {
    
    private func showAlertSuccess(title: String, message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
            completion()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
