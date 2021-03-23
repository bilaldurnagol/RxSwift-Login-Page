//
//  LoginVC.swift
//  RxSwift Login Page
//
//  Created by Bilal Durnagöl on 22.03.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class LoginVC: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "RxSwift Login"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.returnKeyType = .continue
        textField.autocorrectionType = .no
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
     
        textField.placeholder = "Enter email..."
        textField.layer.borderWidth = 3.0
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.isSecureTextEntry = true
        textField.placeholder = "Enter password..."
        textField.layer.borderWidth = 3.0
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = true
        return button
    }()
    let disposeBag = DisposeBag()
    
    var isOK = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(titleLabel)
        loginButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        //validate email
        let emailValid = emailTextField
            .rx
            .text
            .orEmpty
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .map{self.validateEmail(candidate: $0)}
            .share(replay: 1)
        //validate password
        let passValid = passwordTextField
            .rx
            .text
            .orEmpty
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .map{self.validatePassword(candidate: $0)}
            .share(replay: 1)
        
        
        //merge password and email control
        let everythingValid = Observable
            .combineLatest(emailValid, passValid) { $0 && $1}
            .debug("everythingValid", trimOutput: true)
            .share(replay: 1)
        
        everythingValid.subscribe(onNext: {
            self.isOK = $0
        }).disposed(by: disposeBag)
        
        
        
        //show checkmark in emailtextfield
        emailValid
            .map{ return $0}
            .subscribe(onNext: {
                if $0 {
                    let imageView = UIImageView()
                    imageView.image = UIImage(systemName: "checkmark.circle.fill",
                                              withConfiguration:UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 30)))
                    imageView.tintColor = .systemGreen
                    imageView.contentMode = .scaleAspectFill
                    self.emailTextField.rightViewMode = .always
                    self.emailTextField.rightView = imageView
                }else {
                    let spinner = UIActivityIndicatorView()
                    spinner.color = .systemRed
                    spinner.style = .medium
                    self.emailTextField.rightViewMode = .whileEditing
                    self.emailTextField.rightView = spinner
                    spinner.startAnimating()
                }
            }).disposed(by: disposeBag)
     
        //show checkmark in passwordtextfield
        passValid
            .map{ return $0}
            .subscribe(onNext: {
                if $0 {
                    let imageView = UIImageView()
                    imageView.image = UIImage(systemName: "checkmark.circle.fill",
                                              withConfiguration:UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 30)))
                    imageView.tintColor = .systemGreen
                    imageView.contentMode = .scaleAspectFill
                    self.passwordTextField.rightViewMode = .always
                    self.passwordTextField.rightView = imageView
                }else {
                    let spinner = UIActivityIndicatorView()
                    spinner.color = .systemRed
                    spinner.style = .medium
                    self.passwordTextField.rightViewMode = .whileEditing
                    self.passwordTextField.rightView = spinner
                    spinner.startAnimating()
                }
            }).disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let labelWidht: CGFloat = view.frame.width - 60
        let labelHeight: CGFloat = 50
        
        emailTextField.frame = CGRect(x: 30,
                                      y: 0,
                                      width: labelWidht,
                                      height: labelHeight)
        emailTextField.center = view.center
        passwordTextField.frame = CGRect(x: 30,
                                         y: emailTextField.frame.maxY + 5,
                                         width: labelWidht,
                                         height: labelHeight)
        loginButton.frame = CGRect(x: (view.frame.width - 250)/2,
                                   y: passwordTextField.frame.maxY + 10,
                                   width: 250,
                                   height: 60)
        titleLabel.frame = CGRect(x: 0,
                                  y: view.safeAreaInsets.top,
                                  width: view.frame.width,
                                  height: view.frame.height/2)
    }
    
    
    //MARK:- Validations Funcs
    
    private func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    private func validatePassword(candidate: String) -> Bool {
        let passwordRegex = "(?=[^a-z]*[a-z])(?=[^0-9]*[0-9])[a-zA-Z0-9!@#$%^&*]{8,}"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: candidate)
    }
    
    //MARK:- Objc func
    @objc private func didTapButton() {
        if isOK {
            customAlert(alertAction: AlertAction(title: "Congratulations", message: "You are logged in.", style: .default)).subscribe(onNext: {_ in
                
            }).disposed(by: disposeBag)
        }else {
            customAlert(alertAction: AlertAction(title: "Sorry", message: "Check the information you entered.", style: .default)).subscribe(onNext: {_ in
                
            }).disposed(by: disposeBag)
        }
    }
}


extension LoginVC {
    private func customAlert(alertAction: AlertAction) -> Observable<UIAlertController> {
        return Observable<UIAlertController>.create{ observer in
            let alert = UIAlertController(title: alertAction.title, message: alertAction.message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: alertAction.style, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            })
            observer.onNext(alert)
            observer.onCompleted()
            alert.addAction(action)
            self.present(alert, animated: true)
            return Disposables.create()
        }
    }
}

struct AlertAction {
    let title: String
    let message: String
    let style: UIAlertAction.Style
}
