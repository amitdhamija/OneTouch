import UIKit

class MasterViewController: UIViewController {
    
    var isAuthenticated = false
    var didReturnFromBackground = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //view.alpha = 0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillResignActive:", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        isAuthenticated = true
        //view.alpha = 1.0
    }
    
    func appWillResignActive(notification : NSNotification) {
        //view.alpha = 0
        isAuthenticated = false
        didReturnFromBackground = true
    }
  
    func appDidBecomeActive(notification : NSNotification) {
        if didReturnFromBackground {
            self.showLoginView()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        self.showLoginView()
    }
    
    func showLoginView() {
        if !isAuthenticated {
            self.performSegueWithIdentifier("loginView", sender: self)
        }
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        isAuthenticated = false
        self.performSegueWithIdentifier("loginView", sender: self)
    }
}