//
//  AppUtils.swift
//  MirrorflyUIkit
//
//  Created by User on 17/09/21.
//

import Foundation
import UIKit
import AVKit
import Photos
import FlyCommon
import SDWebImage
import FlyCore
import PhoneNumberKit

class AppUtils: NSObject {
    
    //Singleton class
    static let shared = AppUtils()
    
    //MARK: Get random string
    func getRandomString(length: Int) -> String? {
        let letters = "0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
        
    }
    
    //MARK: Image path from directory
    func saveInDirectory(with data: Data?, fileName: String?) -> String? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        let documentsDirectory = paths[0]
        let localFilePath = documentsDirectory + "/" + fileName!
        if let value = data {
            NSData(data: value).write(toFile: localFilePath, atomically: true)
        }
        return localFilePath
    }
    
    func currentMillisecondsToTime(milliSec: Double) -> String{
        let dateVar = Date.init(timeIntervalSince1970: TimeInterval(milliSec)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = chatTimeFormat
        return dateFormatter.string(from: dateVar)
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double, imageOrientation: UIImage.Orientation) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: imageOrientation)
        
        return image
    }
    
    
    func callPhoneNumber(phoneNumber: String) {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func openURLInBrowser(urlString: String) {
        var tempUrl = urlString
        if tempUrl.localizedCaseInsensitiveContains("http://") || tempUrl.localizedCaseInsensitiveContains("https://")  {
            openURL(tempURL: tempUrl)
            return
        } else {
            tempUrl = "https://" + tempUrl
            openURL(tempURL: tempUrl)
        }
    }
    
    func openURL(tempURL: String?) {
        if let url = URL(string: tempURL ?? "") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func getRandomColors() ->[UIColor?] {
        let colors = [Color.color1, Color.color2, Color.color3, Color.color4, Color.color5, Color.color6, Color.color7, Color.color8, Color.color9, Color.color10, Color.color11, Color.color12, Color.color13, Color.color14, Color.color15, Color.color16, Color.color17, Color.color18, Color.color19, Color.color20 ]
        return colors
    }
    
    func mobileNumberParse(phoneNo: String) -> String {
        var splittedMobileNumber:String = ""
        let phoneNumberKit = PhoneNumberKit()
        do {
            let phoneNumber = try phoneNumberKit.parse(phoneNo)
            splittedMobileNumber  = " +\(String(describing: phoneNumber.countryCode)) \(String(describing: phoneNumber.nationalNumber))"
        } catch {
        }
        return splittedMobileNumber
    }
    
    func setRandomColors(totalCount: Int) -> [UIColor?] {
        var colors : [UIColor?] = []
        while totalCount > 0 {
            colors.append(contentsOf: getRandomColors())
            if totalCount <= colors.count {
                return colors
            }
        }
        return getRandomColors()
    }
    
    func marqueeTextToWebKit(text : String) -> String{
        return "<html><body><marquee>" + text + "</marquee></body></html>"
    }
    
    func registerForegroundNotification() {
       // NotificationCenter.default.post(name:NSNotification.Name(foregroundNotification),object: nil)
    }
    
    func removeForegroundNotification() {
      //  NotificationCenter.default.removeObserver(self, name:  NSNotification.Name(foregroundNotification), object: nil)
    }
    
    func getErrorMessage(description: String) -> String {
        
        let split = description.components(separatedBy: "ErrorCode")
        let errorMessage = split.isEmpty ? description : split[0]
        return errorMessage
    }
}

public struct Units {
    
    public let bytes: Int64
    
    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    public init(bytes: Int64) {
        self.bytes = bytes
    }
    
    public func getReadableUnit() -> String {
        
        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.1f", kilobytes)) KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.1f", megabytes)) MB"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.1f", gigabytes)) GB"
        default:
            return "\(bytes) bytes"
        }
    }
}

func executeOnMainThread( codeBlock: @escaping () -> Void) {
    DispatchQueue.main.async {
        codeBlock()
    }
}

func executeInBackground( codeBlock: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async {
        codeBlock()
    }
}
    
func getUserName(jid : String, name : String , nickName : String, contactType : ContactType) -> String {
    FlyUtils.getUserName(jid: jid, name: name, nickName: nickName, contactType: contactType)
}

func getColor(userName : String) -> UIColor {
    return ChatUtils.getColorForUser(userName: userName)
}

func checkFileType(url: String, typeImageView: UIImageView!) {
    guard let urlString = URL(string: url) else { return }
    let urlExtension = urlString.pathExtension
    
   switch urlExtension {
    case FileType.pdf.rawValue:
        typeImageView.image = UIImage(named: "ic_pdf")
    case FileType.doc.rawValue:
        typeImageView.image = UIImage(named: "ic_doc")
    case FileType.xls.rawValue:
        typeImageView.image = UIImage(named: "ic_xls")
    case FileType.xlsx.rawValue:
        typeImageView.image = UIImage(named: "ic_xlxs")
    case FileType.ppt.rawValue:
        typeImageView.image = UIImage(named: "ic_ppt")
    case FileType.pptx.rawValue:
        typeImageView.image = UIImage(named: "ic_pptx")
    case FileType.txt.rawValue:
        typeImageView.image = UIImage(named: "ic_txt")
    case FileType.zip.rawValue:
        typeImageView.image = UIImage(named: "ic_zip")
    case FileType.rar.rawValue:
        typeImageView.image = UIImage(named: "ic_rar")
    case FileType.csv.rawValue:
        typeImageView.image = UIImage(named: "ic_csv")
    case FileType.docx.rawValue:
        typeImageView.image = UIImage(named: "ic_docx")
   default:
       break
    }
    print("urlExtension \(url)")
}

func checkFileType(urlExtension: String, typeImageView: UIImageView!) {
   switch urlExtension {
    case FileType.pdf.rawValue:
        typeImageView.image = UIImage(named: "ic_pdf")
    case FileType.doc.rawValue:
        typeImageView.image = UIImage(named: "ic_doc")
    case FileType.xls.rawValue:
        typeImageView.image = UIImage(named: "ic_xls")
    case FileType.xlsx.rawValue:
        typeImageView.image = UIImage(named: "ic_xlxs")
    case FileType.ppt.rawValue:
        typeImageView.image = UIImage(named: "ic_ppt")
    case FileType.pptx.rawValue:
        typeImageView.image = UIImage(named: "ic_pptx")
    case FileType.txt.rawValue:
        typeImageView.image = UIImage(named: "ic_txt")
    case FileType.zip.rawValue:
        typeImageView.image = UIImage(named: "ic_zip")
    case FileType.rar.rawValue:
        typeImageView.image = UIImage(named: "ic_rar")
    case FileType.csv.rawValue:
        typeImageView.image = UIImage(named: "ic_csv")
    case FileType.docx.rawValue:
        typeImageView.image = UIImage(named: "ic_docx")
   default:
       break
    }
    print("urlExtension \(urlExtension)")
}
    
func getPhoneNumberToUpdate(phoneNumber : String) -> String {
    
    if phoneNumber.isEmpty {
        return FlyDefaults.myMobileNumber
    }
    
    var tempMobileNumber = phoneNumber
    tempMobileNumber = tempMobileNumber.contains("+") ? tempMobileNumber.replacingOccurrences(of: "+", with: "")  : tempMobileNumber
    tempMobileNumber = tempMobileNumber.contains(" ") ? tempMobileNumber.replacingOccurrences(of: " ", with: "") : tempMobileNumber
    
    return tempMobileNumber
}

private func getIsBlockedByMe(jid: String) -> Bool {
    return ChatManager.getContact(jid: jid)?.isBlockedMe ?? false
}



extension UIImageView {
    func loadFlyImage(imageURL: String, name: String, chatType: ChatType = .singleChat, uniqueId: String = "", contactType : ContactType = .unknown,jid: String, isBlockedByAdmin: Bool = false, validateBlock: Bool = true){
        let urlString = FlyDefaults.baseURL + "media/" + imageURL + "?mf=" + FlyDefaults.authtoken
        var url = URL(string: urlString)
        var placeholder : UIImage?
        if validateBlock {
            switch chatType {
            case .groupChat:
                placeholder = UIImage(named: "smallGroupPlaceHolder")
            default:
                if uniqueId == FlyDefaults.myJid || contactType == .unknown || getIsBlockedByMe(jid: jid) || isBlockedByAdmin {
                    placeholder = UIImage(named: "ic_profile_placeholder")
                } else {
                    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    let ipimage = IPImage(text: trimmedName, radius: Double(self.frame.size.height), font: UIFont.font32px_appBold(),
                                          textColor: nil, color: getColor(userName: name))
                    placeholder = ipimage.generateInitialImage()
                    self.backgroundColor = ChatUtils.getColorForUser(userName: name)
                }
            }
        }
        if contactType == .deleted || getIsBlockedByMe(jid: jid) {
            placeholder = UIImage(named: "ic_profile_placeholder")
        }
        
        if isBlockedByAdmin {
            url = URL(string: "")
        }
        
        self.sd_setImage(with: url, placeholderImage: placeholder, options: [.continueInBackground,.decodeFirstFrameOnly,.highPriority,.scaleDownLargeImages], progress: nil){ (image, responseError, isFromCache, imageUrl) in
            if let error =  responseError as? NSError{
                if let errorCode = error.userInfo[SDWebImageErrorDownloadStatusCodeKey] as? Int {
                    if errorCode == 401{
                        FlyMessenger.refreshToken { [weak self] isSuccess, error, data in
                            if isSuccess{
                                self?.loadFlyImage(imageURL: imageURL, name: name, chatType : chatType, jid: jid)
                            }else{
                                self?.image = placeholder
                            }
                        }
                    }else{
                        self.image = placeholder
                    }
                }
            }else{
                self.image = image
            }
        }
    }
}
    
