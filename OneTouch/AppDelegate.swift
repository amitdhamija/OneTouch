import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let NavigationController = self.window!.rootViewController as! UINavigationController
        let Controller = NavigationController.topViewController as! MasterViewController
        
        self.prepareNavigationBarAppearance()
        return true
    }
  
    func prepareNavigationBarAppearance() {
        UINavigationBar.appearance().hidden = true
        UIStatusBarStyle.LightContent
    }
    
    func applicationWillResignActive(application: UIApplication) {
        UIApplication.sharedApplication().ignoreSnapshotOnNextApplicationLaunch()
    }
}