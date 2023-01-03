//
//  MainTabBarController.swift
//  MirrorflyUIkit
//
//  Created by User on 11/08/21.
//

import UIKit
import FlyCore
import FlyDatabase
import FlyCommon
import Contacts

class MainTabBarController: UITabBarController{
    @IBOutlet weak var chatTabBars: UITabBar?
    
    var tabViewControllers : [UIViewController] = []
    
    static var isConnected = false
    
    var shouldShowCallTab = false
    
    var avilableFeatures = ChatManager.getAvailableFeatures()
    
    static var tabBarDelegagte : TabBarDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         if FlyDefaults.appFingerprintenable  && FlyDefaults.appLockenable  {
            let vc = FingerPrintPINViewController(nibName: "FingerPrintPINViewController", bundle: nil)
             self.navigationController?.pushViewController(vc, animated: true)
        }
        else if FlyDefaults.appLockenable && FlyDefaults.appFingerprintenable == false {
            let vc = AuthenticationPINViewController(nibName: "AuthenticationPINViewController", bundle: nil)
            vc.login = true
             self.navigationController?.pushViewController(vc, animated: true)
           
        }
        self.delegate = self
        if let vcs = self.viewControllers{
            tabViewControllers = vcs
        }
        MainTabBarController.tabBarDelegagte = self
        shouldShowCallTab = avilableFeatures.isOneToOneCallEnabled || avilableFeatures.isGroupCallEnabled
        if !shouldShowCallTab{
            setupUI()
            removeTabAt(index:2)
        }else{
            resetTabs()
        }
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUnReadMissedCallCount(notification:)), name: NSNotification.Name("updateUnReadMissedCallCount"), object: nil)
        handleBackgroundAndForground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelection()
        saveMyJidAsContacts()
        ChatManager.shared.connectionDelegate = self
        updateUnReadMissedCallBadgeCount()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Utility.saveInPreference(key: "safeAreaHeight", value: "\(view.safeAreaLayoutGuide.layoutFrame.height)")
        Utility.saveInPreference(key: "safeAreaWidth", value: "\(view.safeAreaLayoutGuide.layoutFrame.width)")
    }
    
    // MARK: - Functions
    func setupUI() {
        self.chatTabBars?.backgroundColor = Color.navigationColor
        navigationController?.setNavigationBarHidden(true, animated: true)
        guard let items = tabBar.items else { return }
        items[0].title = chat
        items[1].title = contact
        items[2].title = call
        items[3].title = profile
        items[4].title = setting
        //Mark:- You can also set any custom fonts in the code
        let fontAttributes = [NSAttributedString.Key.font: UIFont.font12px_appLight()]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
        self.chatTabBars?.backgroundColor = Color.navigationColor
    }
    
    func saveMyJidAsContacts() {
        let profileData = ProfileDetails(jid: FlyDefaults.myJid)
        profileData.name = FlyDefaults.myName
        profileData.nickName = FlyDefaults.myNickName
        profileData.mobileNumber  = FlyDefaults.myMobileNumber
        profileData.email = FlyDefaults.myEmail
        profileData.status = FlyDefaults.myStatus
        profileData.image = FlyDefaults.myImageUrl
        
        FlyDatabaseController.shared.rosterManager.saveContact(profileDetailsArray: [profileData], chatType: .singleChat, contactType: .live, saveAsTemp: false, calledBy: "")
    }
    
    @objc override func willCometoForeground() {
        updateUnReadMissedCallBadgeCount()
    }
    
    @objc func updateUnReadMissedCallCount(notification: NSNotification) {
        updateUnReadMissedCallBadgeCount()
    }
    
    func updateUnReadMissedCallBadgeCount() {
        
        if let item : UITabBarItem = chatTabBars?.items?[2] {
            let missedCallCount = FlyDefaults.unreadMissedCallCount
            item.badgeValue = (missedCallCount == 0) ? nil : "\(missedCallCount)"
        }
    }
    
}

extension MainTabBarController : ConnectionEventDelegate {
    func onConnected() {
        if FlyDefaults.isFriendsListSyncPending {
            ContactManager.shared.getRegisteredUsers(fromServer: true){isSuccess,_,_ in
                FlyDefaults.isFriendsListSyncPending = !isSuccess
            }
        }
        
    }
    
    func onDisconnected() {
        
    }
    
    func onConnectionNotAuthorized() {
        
    }
}

extension MainTabBarController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateSelection()
      }

      func updateSelection() {
        let normalFont = UIFont.font12px_appLight()
        let selectedFont = UIFont.font12px_appMedium()
        viewControllers?.forEach {
          let selected = $0 == self.selectedViewController
          $0.tabBarItem.setTitleTextAttributes([.font: selected ? selectedFont : normalFont], for: .normal)
        }
      }

}


extension MainTabBarController : TabBarDelegate{
    
    func currentTabCount() -> Int {
        self.viewControllers?.count ?? 0
    }

    
    func removeTabAt(index: Int) {
        avilableFeatures = ChatManager.getAvailableFeatures()
        if let vcs =  self.viewControllers{
            self.viewControllers?.remove(at: index)
            self.viewControllers = self.viewControllers
        }
    }
    
    func resetTabs(){
        avilableFeatures = ChatManager.getAvailableFeatures()
        self.viewControllers = tabViewControllers
        setupUI()
    }
    
}

public protocol TabBarDelegate {
    
    func removeTabAt(index : Int)
    
    func resetTabs()
    
    func currentTabCount() -> Int
}


