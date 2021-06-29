//
//  SettingsVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import UIKit
import Photos

struct Section {
    let title: String
    let bottomTitle: String?
    let options: [SettingsOption]
}

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handle: (() -> Void)
}

class SettingsVC: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        return table
    }()
    
    var models = [Section]()
    let albumName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    private let appVersion = "Current version: \(UIApplication.appVersion)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.tabBarController?.tabBar.selectedItem?.title
        configure()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    /// #Create Setting Options for tableView
    func configure() {
        /// #Apperance
        models.append(Section(title: "Appearance", bottomTitle: nil, options: [
            SettingsOption(title: "Dark Mode", icon: UIImage(systemName: "moon.circle.fill"), iconBackgroundColor: .black, handle: {
                print("Tap0")
            })
        ]))
        /// #General
        models.append(Section(title: "General", bottomTitle: nil, options: [
            SettingsOption(title: "Find me on social", icon: UIImage(systemName: "link.circle"), iconBackgroundColor: UIColor(hexString: "#6dd5ed"), handle: {
                guard let url = URL(string: "https://www.linkedin.com/in/christos-petimezas/") else { return }
                
                let webView = WebPreviewVC(with: url)
                webView.modalPresentationStyle = .popover
                self.present(webView, animated: true)
            }),
            SettingsOption(title: "Share app", icon: UIImage(systemName: "square.and.arrow.up"), iconBackgroundColor: .link, handle: {
                self.shareApp()
            }),
            SettingsOption(title: "Review app", icon: UIImage(systemName: "star.circle.fill"), iconBackgroundColor: UIColor(hexString: "#43cea2"), handle: {
                StoreReviewHelper.requestReview()
            })
        ]))
        /// #Show custom album only if authorizationStatus is authorized.
        if getStatus() {
            models.append(Section(title: "\(albumName) ALBUM", bottomTitle: appVersion, options: [
                SettingsOption(title: "Edit album", icon: UIImage(systemName: "photo.fill"), iconBackgroundColor: UIColor(hexString: "#753a88"), handle: {
                    print("Tap4")
                })
            ]))
        }
    }
    
    private func getStatus() -> Bool {
        var status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else { // Fallback on earlier versions
            status = PHPhotoLibrary.authorizationStatus()
        }
        return (status == .authorized) ? true : false
    }
    
    // TODO: check again this func
    private func shareApp() {
        if let urlStr = NSURL(string: "https://itunes.apple.com/us/app/myapp/idxxxxxxxx?ls=1&mt=8") {
            let objectsToShare = [urlStr]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UITableView Delegates
extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = models[section]
        return section.bottomTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section].options[indexPath.row]
        model.handle()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
}
