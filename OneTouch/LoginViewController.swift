import UIKit
import CoreData
import LocalAuthentication

class LoginViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var error: NSError?
    var context = LAContext()
    
    let MyKeychainWrapper = KeychainWrapper()
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check to see if the login is already stored for the user
        let hasLogin = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        
        if hasLogin {
            loginButton.setTitle("Log In", forState: UIControlState.Normal)
            loginButton.tag = loginButtonTag
            passwordTextField.tag = loginButtonTag
        } else {
            loginButton.setTitle("Create", forState: UIControlState.Normal)
            loginButton.tag = createLoginButtonTag
            passwordTextField.tag = createLoginButtonTag
        }
        
        // autofill the username field to username stored in NSUserDfaults
        if let storedUsername = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
            usernameTextField.text = storedUsername as String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        // if either the username or password is empty, then present an alert to the user and return from the method
        if (usernameTextField.text == "" || passwordTextField.text == "") {
            var alert = UIAlertView()
            alert.title = "You must enter both a username and password!"
            alert.addButtonWithTitle("Oops!")
            alert.show()
            return;
        }
        
        // dismiss the keyboard if it's visible
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        println(sender.tag)
        // if the login button’s tag is createLoginButtonTag, then proceed to create a new login
        if sender.tag == createLoginButtonTag {
            
            // check to see if the login is already stored for the user
            let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
            
            // if the username field is not empty and hasLoginKey indicates no login has already been saved,
            // then save the username to NSUserDefaults
            if hasLoginKey == false {
                NSUserDefaults.standardUserDefaults().setValue(self.usernameTextField.text, forKey: "username")
            }
            
            // save the password text to Keychain
            MyKeychainWrapper.mySetObject(passwordTextField.text, forKey:kSecValueData)
            MyKeychainWrapper.writeToKeychain()
            
            // set hasLoginKey in NSUserDefaults to true to indicate that a password has been saved to the keychain
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // set the login button’s tag to loginButtonTag
            loginButton.tag = loginButtonTag
            
            // dismiss login view
            performSegueWithIdentifier("dismissLogin", sender: self)
        } else if sender.tag == loginButtonTag {
            
            // verify user-provided credentials; dismiss login view if they match
            if checkLogin(usernameTextField.text, password: passwordTextField.text) {
                performSegueWithIdentifier("dismissLogin", sender: self)
            } else {
                
                // show alert message if authentication fails
                var alert = UIAlertView()
                alert.title = "Invalid username/password"
                alert.message = "You entered invalid username or password."
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        }
    }
    
    
    @IBAction func touchIDLoginAction(sender: AnyObject) {
        loginUsingTouchId()
    }
    
    func loginUsingTouchId() {
        // check whether the device is Touch ID capable
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            // begin policy evaluation; i.e., prompt the user for Touch ID authentication
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Scan your fingerprint below to enter your account",
                reply: { (success: Bool, error: NSError! ) -> Void in
                    
                    // NOTE: policy evaluation happens on private thread, so code jumps back to the main thread to update UI
                    // if the authentication was successful, call the segue that dismisses the login view
                    dispatch_async(dispatch_get_main_queue(), {
                        if success {
                            
                            self.performSegueWithIdentifier("dismissLogin", sender: self)
                        }
                        
                        if error != nil {
                            var message: String
                            var showAlert: Bool
                            
                            // set appropriate error messages for each error case, then present the user with an alert view
                            switch(error.code) {
                            case LAError.AuthenticationFailed.rawValue:
                                message = "There was a problem verifying your identity."
                                showAlert = true
                            case LAError.UserCancel.rawValue:
                                message = "You pressed cancel."
                                showAlert = false
                            case LAError.UserFallback.rawValue:
                                message = "You pressed password."
                                showAlert = false
                            default:
                                showAlert = true
                                message = "Touch ID may not be configured"
                            }
                            
                            var alert = UIAlertView()
                            alert.title = "Error"
                            alert.message = message
                            alert.addButtonWithTitle("OK")
                            if showAlert {
                                alert.show()
                            }
                            
                        }
                    })
                    
            })
        } else {
            
            // display a generic alert
            var alert = UIAlertView()
            alert.title = "Error"
            alert.message = "Touch ID not available"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func checkLogin(username: String, password: String) -> Bool {
        
        // check username against one stored in NSUserDefaults and password against one stored in Keychain
        if password == MyKeychainWrapper.myObjectForKey("v_Data") as? String &&
            username == NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
                return true
        } else {
            return false
        }
    }

}