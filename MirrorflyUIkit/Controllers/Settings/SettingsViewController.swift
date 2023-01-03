//
//  SettingsViewController.swift
//  MirrorflyUIkit
//
//  Created by User on 08/12/21.
//

import Foundation
import UIKit
import FlyCore
import FlyCommon

class SettingsViewController : BaseViewController {
    @IBOutlet weak var tblSettings : UITableView!
    @IBOutlet weak var lblVersion: UILabel!
    //@IBOutlet weak var lblLatestRelease: UILabel!
    
    //private var settingsArr = ["Chats","Starred Messages","Notifications","Blocked Contacts","Archived Chats","About and Help","App Lock","Connection Label", "Logout"]
    
    //private var settingsArr = ["Chats","Notifications","Blocked Contacts","About and Help","App Lock","Delete My Account","Logout"]

    private var settingsArr = ["Chats","About and Help","Delete My Account","Logout"]

    override func viewDidLoad() {
        let info = Bundle.main.infoDictionary
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info?[kCFBundleVersionKey as String] as? String ?? "Unknown"
        
        let appVersionString = "Version \(appVersion)(\(appBuild))"
        self.lblVersion.text = appVersionString
        //   self.lblLatestRelease.isHidden = true
        self.tblSettings.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        self.tblSettings.delegate = self
        self.tblSettings.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ChatManager.shared.availableFeaturesDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppAlert.shared.onAlertAction = nil
        ChatManager.shared.availableFeaturesDelegate = nil
    }
    
    
    
 func onLogout() {
        let appAlert = AppAlert.shared
        appAlert.showAlert(view: self, title: nil, message: "Are you sure you want to logout?", buttonOneTitle: "YES", buttonTwoTitle: "NO")
        AppAlert.shared.onAlertAction = { [weak self] (result) ->
            Void in
            if result == 0 {
                if FlyDefaults.appLockenable == true{
                    let secondView = AuthenticationPINViewController(nibName: "AuthenticationPINViewController", bundle: nil)
                    secondView.logout = true
                    self?.navigationController?.pushViewController(secondView, animated: true)
                    
                }
                else{
                    self?.requestLogout()
                }
                
            }
        }
        
    }

}


extension SettingsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        cell.lblTitle.text = self.settingsArr[indexPath.row]
        cell.imgicon.image = UIImage(named: self.settingsArr[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsArr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.settingsArr[indexPath.row] {
            
        case "Chats":
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatSettingsViewController") as? ChatSettingsViewController {
                vc.clearBadgeCountDelegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case "Notifications":
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsViewController") as? NotificationsViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case "Blocked Contacts":
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BlockedContactsViewController") as? BlockedContactsViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case "About and Help":
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutandHelpViewController") as? AboutandHelpViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "App Lock":
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppLockViewController") as? AppLockViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }

            break
        case "Delete My Account":
            if let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "DeleteMyAccountVC") as? DeleteMyAccountVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case "ShareLog":
            let logFileURL = FlyLogWriter.sharedInstance.getLogFileURL()
            if let logFile = try? String(contentsOf: logFileURL){
                let activityVC = UIActivityViewController(activityItems: [logFile], applicationActivities: nil)
                present(activityVC, animated: true, completion: nil)
            }
            break
        case "Logout":
            self.onLogout()
            break
        default :
            break
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
}

extension SettingsViewController : AvailableFeaturesDelegate {
    
    func didUpdateAvailableFeatures(features: AvailableFeaturesModel) {
        
        let tabCount =  MainTabBarController.tabBarDelegagte?.currentTabCount()
        
        if (!(features.isGroupCallEnabled || features.isOneToOneCallEnabled) && tabCount == 5) {
            MainTabBarController.tabBarDelegagte?.removeTabAt(index: 2)
        }else {
            
            if ((features.isGroupCallEnabled || features.isOneToOneCallEnabled) && tabCount ?? 0 < 5){
                MainTabBarController.tabBarDelegagte?.resetTabs()
            }
        }
    }

}
extension SettingsViewController : ClearAllChatsDelegate{
    func clearAllConversations(isCleared: Bool) {
        self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue = nil

    }
    
    
}
