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
        TMDBClient.getRequestToken { (success, error) in
            if success {
                DispatchQueue.main.async {
                  let data =   UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [ : ], completionHandler: nil)
               
                    print("data----\(data)")
                }
            }
        }
    }
    
 
    
    func handleRequestTokenRespons(success: Bool, error: Error?){
       
        DispatchQueue.main.async{
            if success {
                print(TMDBClient.Auth.requestToken)
                
                TMDBClient.login(
                    username: self.emailTextField.text ?? "",
                    password: self.passwordTextField.text ?? "",
                    completion: self.handleLoginResponse(success:error:))
                 self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
        }
        print("\(self.emailTextField.text)\(self.passwordTextField.text)")
    }
    
    
    func handleLoginResponse (success: Bool, error: Error?) {
        print("login response------")
        if success {
            print(TMDBClient.Auth.requestToken)
          //  TMDBClient.sessionId(comletion: handleSessionResponse(success:error:)) // not working need to fix
            TMDBClient.createSessionId { (success, error) in
                if success {
                    print(" sessionId response------")

                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "completeLogin", sender: nil)
                    }
                }
            }
        }
    }
    
    func handleSessionResponse(success: Bool, error: Error?) {
        print("next controller...")
        if success {
           
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            
        }else {
            print("user and pass dont match")
        }
    }
    
    

    
    
}
