//
//  LoginViewController.swift
//  IssoWade
//
//  Created by Kaveen Suraweera on 2021-10-02.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailFeild: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        
        return field
    }()
    
    private let passwordFeild: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email","public_profile"]
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailFeild.delegate = self
        passwordFeild.delegate = self
        facebookLoginButton.delegate = self
        
        //Add  subViews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailFeild)
        scrollView.addSubview(passwordFeild)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailFeild.frame = CGRect(x: 30,
                                 y: imageView.bottom+10,
                                 width: scrollView.width-60,
                                 height: 52)
        
        passwordFeild.frame = CGRect(x: 30,
                                 y: emailFeild.bottom+10,
                                 width: scrollView.width-60,
                                 height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                 y: passwordFeild.bottom+10,
                                 width: scrollView.width-60,
                                 height: 52)
        
        facebookLoginButton.frame = CGRect(x: 30,
                                 y: loginButton.bottom+10,
                                 width: scrollView.width-60,
                                 height: 52)
        
        facebookLoginButton.frame.origin.y = loginButton.bottom+20
    }
    
    @objc private func loginButtonTapped() {
        
        emailFeild.resignFirstResponder()
        passwordFeild.resignFirstResponder()
        
        guard let email = emailFeild.text,
              let password = passwordFeild.text,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6
        else{
            alertUserloginError()
            return
        }
    
        //Firebase Login
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            guard let result = authResult, error == nil else{
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    
    
    func alertUserloginError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to log in.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    



}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailFeild{
            passwordFeild.becomeFirstResponder()
        }
        else if textField == passwordFeild {
            loginButtonTapped()
        }
        
        return true
    }
    
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to loogin with facebook")
            return
        }

       
            
            let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                             parameters: ["fields": "email, name"],
                                                             tokenString: token,
                                                             version: nil,
                                                             httpMethod: .get)

            facebookRequest.start(completion: { _, result, error in
                guard let result = result as? [String: Any], error == nil else {
                    print("Failed to make facebook graph request")
                    return
                }
                
                print("\(result)")
                guard let userName = result["name"] as? String,
                      let email = result["email"]
                
                let credential = FacebookAuthProvider.credential(withAccessToken: token)
                FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                    guard let strongSelf = self else {
                        return
                    }

                    guard authResult != nil , error == nil else {
                        if let error = error{
                        print("Facebook credentioal login failed, MFA may be needed - \(error)")
                        }
                        return
                    }
                    
                    print("Successfully logged user in")
                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        

        })
    }


}
