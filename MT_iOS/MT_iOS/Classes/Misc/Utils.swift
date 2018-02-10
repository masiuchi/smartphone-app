//
//  Utils.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/05/21.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import Foundation
import TMReachability

class Utils {
    class func userAgent()->String {
        let uName = "MTiOS"
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let userAgent = uName + "/" + version
        
        return userAgent
    }

    class func dateFromISO8601StringWithFormat(_ string: String, format: String)->Date? {
        if string.isEmpty {
            return nil
        }
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
    
    class func dateTimeFromISO8601String(_ string: String)->Date? {
        return Utils.dateFromISO8601StringWithFormat(string, format: "yyyy-MM-dd'T'HH:mm:ssZ")
    }

    class func dateFromISO8601String(_ string: String)->Date? {
        return Utils.dateFromISO8601StringWithFormat(string, format: "yyyy-MM-dd")
    }
    
    class func timeFromISO8601String(_ string: String)->Date? {
        return Utils.dateFromISO8601StringWithFormat(string, format: "HH:mm:ssZ")
    }
    
    class func ISO8601StringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return formatter.string(from: date) + "Z"
    }

    class func dateTimeFromString(_ string: String)->Date? {
        if string.isEmpty {
            return nil
        }
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss";
        return formatter.date(from: string)
    }

    class func dateTimeTextFromDate(_ date: Date)->String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss";
        return formatter.string(from: date)
    }

    class func dateTimeStringFromDate(_ date: Date, template: String)->String {
        let dateFormatter: DateFormatter = DateFormatter()
        let dateFormat: NSString = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)! as NSString
        dateFormatter.dateFormat = dateFormat as String
        return dateFormatter.string(from: date)
    }
    
    class func fullDateTimeFromDate(_ date: Date)->String {
        return Utils.dateTimeStringFromDate(date, template:"yMMMMdEE HHmm")
    }

    class func mediumDateTimeFromDate(_ date: Date)->String {
        return Utils.dateTimeStringFromDate(date, template:"yMMMMd HHmm")
    }
    
    class func dateTimeFromDate(_ date: Date)->String {
        return Utils.dateTimeStringFromDate(date, template:"yMMMMd HHmm")
    }

    class func dateStringFromDate(_ date: Date)->String {
        return Utils.dateTimeStringFromDate(date, template:"yMMMMdEEE")
    }

    class func mediumDateStringFromDate(_ date: Date)->String {
        return Utils.dateTimeStringFromDate(date, template:"yMMMMd")
    }

    class func timeStringFromDate(_ date: Date)->String {
        return Utils.dateTimeStringFromDate(date, template:"HHmm")
    }
    
    class func getTextFieldFromView(_ view: UIView)->UITextField? {
        for subview in view.subviews {
            if subview.isKind(of: UITextField.self) {
                return subview as? UITextField
            } else {
                let textField = self.getTextFieldFromView(subview)
                if (textField != nil) {
                    return textField
                }
            }
        }
        
        return nil
    }
    
    class func removeHTMLTags(_ html: String)-> String {
        var destination : String = html.replacingOccurrences(of: "<(\"[^\"]*\"|'[^']*'|[^'\">])*>", with:"", options:NSString.CompareOptions.regularExpression, range: nil)
        destination = destination.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return destination
    }
    
    class func performAfterDelay(_ block: @escaping ()->(), delayTime: Double) {
        let delay = delayTime * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: block)
    }
    
    class func resizeImage(_ image: UIImage, width: CGFloat)-> UIImage {
        //オリジナルサイズのとき
        if width == 0.0 {
            return image
        }
        
        var w = image.size.width
        var h = image.size.height
        let scale = width / w
        if scale >= 1.0 {
            return image
        }
        w = width
        h = h * scale
        let size = CGSize(width: w, height: h)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage!
    }
    
    class func convertImageToJPEG(_ image: UIImage, quality: CGFloat)-> Data {
        let imageData = UIImageJPEGRepresentation(image, quality)
        return imageData!
    }
    
    class func convertJpegData(_ image: UIImage, width: CGFloat, quality: CGFloat)->Data {
        let resizedImage = Utils.resizeImage(image, width: width)
        let jpeg = Utils.convertImageToJPEG(resizedImage, quality: quality)
        return jpeg
    }
    
    class func makeJPEGFilename(_ date: Date)-> String {
        let filename = String(format: "mt-%04d%02d%02d%02d%02d%02d.jpg", arguments: [(date as NSDate).year, (date as NSDate).month, (date as NSDate).day, (date as NSDate).hour, (date as NSDate).minute, (date as NSDate).seconds])
        return filename
    }
    
    class func hasConnectivity()-> Bool {
        let reachability = TMReachability.forInternetConnection()
        let networkStatus = reachability?.currentReachabilityStatus()
        return (networkStatus != NetworkStatus.NotReachable)
    }

    class func preferredLanguage()-> String {
        let languages = Locale.preferredLanguages
        let language = languages[0] 
        return language
    }
    
    class func confrimSave(_ vc: UIViewController, dismiss: Bool = false, block: (() -> Void)? = nil) {
        let alertController = UIAlertController(
            title: NSLocalizedString("Confirm", comment: "Confirm"),
            message: NSLocalizedString("Are you sure not have to save?", comment: "Are you sure not have to save?"),
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .destructive) {
            action in

            if let block = block {
                block()
            }
            
            if dismiss {
                vc.dismiss(animated: true, completion: nil)
            } else {
                _ = vc.navigationController?.popViewController(animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) {
            action in
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    class func trimSpace(_ src: String)-> String {
        return src.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    class func regexpMatch(_ pattern: String, text: String)-> Bool {
        let regexp = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        let matches = regexp.matches(in: text, options: [], range:NSMakeRange(0, text.characters.count))
        return matches.count > 0
    }
    
    class func validatePath(_ path: String)-> Bool {
        let pattern = "[ \"%<>\\[\\\\\\]\\^`{\\|}~]"
        let replaceString = path.replacingOccurrences(of: pattern, with: "", options: NSString.CompareOptions.regularExpression, range: nil)
        let api = DataAPI.sharedInstance
        let str = api.urlencoding(replaceString)
        if let _ = str?.range(of: "%") {
            return false
        }
        if let _ = path.range(of: "..") {
            return false
        }
        
        return true
    }
}
