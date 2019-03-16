//
//  LoginViewController.swift
//  TheMovieManager
//
 

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        TMDBClient.getRequestToken(completion: handleRequestTokenRespons(success:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        performSegue(withIdentifier: "completeLogin", sender: nil)
    }
    func handleRequestTokenRespons(success: Bool, error: Error?){
        if success {
            print(TMDBClient.Auth.requestToken)
        }
    }
    
    
    func handleLoginResponse (success: Bool, error: Error?) {
        if success {
            TMDBClient.login(
                username: self.emailTextField.text ?? "",
                password: self.passwordTextField.text ?? "",
                completion: handleLoginResponse(success:error:))
        }
    }
}
