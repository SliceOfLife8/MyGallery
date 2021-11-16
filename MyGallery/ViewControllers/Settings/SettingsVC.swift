//
//  SettingsVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import UIKit
import Photos

class SettingsVC: BaseVC {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        return table
    }()
    
    var models = [Section]()
    private var appVersion: String {
        get {
            "version".localized() + " \(AppConfig.appVersion)"
        }
    }
    private var greekSupported: Bool {
        get {
            Locale.current.regionCode == "GR"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(albumCreatedNotification), name: .didAlbumCreated, object: nil)
    }
    
    override func languageDidChange() {
        super.languageDidChange()
        self.title = self.tabBarController?.tabBar.selectedItem?.title
        configure()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.deleteLoafView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    /// #Create Setting Options for tableView
    func configure() {
        models.removeAll()

        /// #Apperance
        var apperanceOptions: [SettingsOption] = [SettingsOption(title: "dark_mode".localized(), icon: UIImage(systemName: "moon.circle.fill"), iconBackgroundColor: UIColor(named: "Black"), accessoryType: .disclosureIndicator, handle: {
            let darkModeVC = DarkModeSelectionVC()
            let navigationController = UINavigationController(rootViewController: darkModeVC)
            darkModeVC.modalPresentationStyle = .popover
            self.present(navigationController, animated: true)
        })]
        if greekSupported {
            apperanceOptions.append(SettingsOption(title: "languages".localized(), icon: UIImage(systemName: "globe"), iconBackgroundColor: UIColor(named: "DarkBlue"), accessoryType: .disclosureIndicator, handle: {
                let languageVC = LanguageSelectionVC()
                let navigationController = UINavigationController(rootViewController: languageVC)
                languageVC.modalPresentationStyle = .popover
                self.present(navigationController, animated: true)
            }))
        }
        apperanceOptions.append(SettingsOption(title: "choose_theme".localized(), icon: UIImage(systemName: "wand.and.stars"), iconBackgroundColor: UIColor(named: "DarkGray"), accessoryType: .disclosureIndicator, handle: {
            self.openThemeSelectionVC()
        }))

        models.append(Section(title: "appearance".localized(), bottomTitle: nil, options: apperanceOptions))

        /// #Sounds
        models.append(Section(title: nil, bottomTitle: nil, options: [
                                SettingsOption(title: "sounds_haptics".localized(), icon: UIImage(systemName: "speaker.wave.2.circle"), iconBackgroundColor: UIColor(named: "LightRed"), accessoryType: .disclosureIndicator, handle: {
                                    let soundsVC = SoundSettingsVC()
                                    let navigationController = UINavigationController(rootViewController: soundsVC)
                                    soundsVC.modalPresentationStyle = .popover
                                    self.present(navigationController, animated: true)
                                })]))

        /// #General
        models.append(Section(title: "general".localized(), bottomTitle: (getStatus() ? nil : appVersion), options: [
            SettingsOption(title: "find_me_on_social".localized(), icon: UIImage(systemName: "link.circle"), iconBackgroundColor: UIColor(named: "LightBlue"), accessoryType: .disclosureIndicator, handle: {
                /// #Open linkedinApp if it's available on phone. Otherwise open custom webView.
                if let url = URL(string: "linkedin://profile/christos-petimezas"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                }
                
                guard let url = URL(string: "https://www.linkedin.com/in/christos-petimezas/") else { return }
                
                let webView = WebPreviewVC(with: url)
                webView.modalPresentationStyle = .popover
                self.present(webView, animated: true)
            }),
            SettingsOption(title: "share_app".localized(), icon: UIImage(systemName: "square.and.arrow.up"), iconBackgroundColor: .link, accessoryType: .disclosureIndicator, handle: {
                self.shareApp()
            }),
            SettingsOption(title: "review_app".localized(), icon: UIImage(systemName: "star.circle.fill"), iconBackgroundColor: UIColor(hexString: "#43cea2"), accessoryType: .disclosureIndicator, handle: {
                self.rateApp()
            })
        ]))

        /// #Show custom album only if authorizationStatus is authorized.
        if getStatus() {
            models.append(Section(title: "\(AppConfig.albumName) " + "album".localized(), bottomTitle: appVersion, options: [
                SettingsOption(title: "edit_album".localized(), icon: UIImage(systemName: "photo.fill"), iconBackgroundColor: UIColor(named: "Purple"), accessoryType: .disclosureIndicator, handle: {
                    self.openEditAlbumVC()
                }),
                SettingsOption(title: "show_album".localized(), icon: UIImage(systemName: "photo.on.rectangle.angled"), iconBackgroundColor: UIColor(named: "LightPurple"), accessoryType: .disclosureIndicator, handle: {
                    self.showLoader()
                    PhotoService.shared.delegate = self
                    PhotoService.shared.fetchCustomAlbumPhotos()
                })
            ]))
        }
    }
    
    func getStatus() -> Bool {
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        return (status == .authorized) ? true : false
    }
    
    private func shareApp() {
        if let urlStr = URL(string: "https://apps.apple.com/us/app/id1593013678") {
            let activityVC = UIActivityViewController(activityItems: [urlStr], applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    @objc func albumCreatedNotification() {
        configure()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func openThemeSelectionVC() {
        let themeVC = ThemeSelectionVC()
        let navigationController = UINavigationController(rootViewController: themeVC)
        themeVC.modalPresentationStyle = .popover
        self.present(navigationController, animated: true)
    }

    func openEditAlbumVC() {
        let editAlbumVC = EditCustomAlbumVC()
        editAlbumVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(editAlbumVC, animated: true)
    }

    private func rateApp() {
        guard let productURL = URL(string: "https://itunes.apple.com/app/id1593013678") else {
            return
        }

        var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)

        components?.queryItems = [
            URLQueryItem(name: "action", value: "write-review")
        ]

        guard let writeReviewURL = components?.url else {
            return
        }

        UIApplication.shared.open(writeReviewURL)
    }

    func stopLoader(goToLightboxView status: Bool) {
        if let visibleVC = UIApplication.topViewController() as? UIAlertController {
            visibleVC.dismiss(animated: false, completion: {
                if status {
                    LightboxHelper.show()
                } else {
                    let alert = UIAlertController(title: "no_album_found".localized(), message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))

                    self.present(alert, animated: false, completion: nil)
                }
            })
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

extension SettingsVC: PhotoServiceDelegate {
    func didGetImages() {
        stopLoader(goToLightboxView: PhotoService.shared.images.count > 0)
    }
}
