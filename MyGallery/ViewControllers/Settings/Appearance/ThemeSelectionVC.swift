//
//  ThemeSelectionVC.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 28/10/21.
//

import UIKit

class ThemeSelectionVC: BaseVC {

    private var cellIdentifier = "GalleryCell"
    private var images: [UIImage] = []

    private var saveBtnIsEnabled: Bool = false {
        didSet {
            self.navigationItem.rightBarButtonItem?.isEnabled = saveBtnIsEnabled
        }
    }

    private var storageKey: FirebaseImages? = FirebaseStorageManager.shared.retrieveGalleryImage().key
    private var predefinedIndex: Int = 0 /// This field is used for observing the pre-selected theme from current user.

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 250)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGray6
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        if FirebaseStorageManager.shared.numOfCalls != 6 {
            showLoader()
        }
        getImages()
        setupCollectionView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.observeFBStorage),
                                               name: .didAllFirebaseImagesFetched,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if FirebaseStorageManager.shared.numOfCalls == 6 {
            self.collectionView.selectItem(at: IndexPath(row: self.predefinedIndex, section: 0), animated: true, scrollPosition: [])
        }
    }

    private func setupNavBar() {
        let backButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(back))
        let saveButton: UIBarButtonItem = UIBarButtonItem(title: "save".localized(), style: .plain, target: self, action: #selector(saveBtnTapped))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = saveButton
        saveBtnIsEnabled = false
        self.title = "themes".localized()
    }

    private func setupCollectionView() {
        collectionView.addExclusiveConstraints(superview: view, top: (view.safeAreaLayoutGuide.topAnchor, 0), bottom: (view.bottomAnchor, 0), left: (view.leadingAnchor, 0), right: (view.trailingAnchor, 0))
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SelectThemeHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SelectThemeHeaderView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func getImages() {
        if let defaultImage = UIImage(named: "Pattern") {
            images.append(defaultImage)
        }
        let storageImages = FirebaseStorageManager.shared.images.sorted { $0.key < $1.key } /// sorted by key
        images = images + storageImages.map { $0.value }

        for (index, element) in storageImages.enumerated() {
            if element.key == storageKey?.rawValue {
                predefinedIndex = index + 1 // +1 because index -> 0 is the default state
            }
        }
    }

    private func saveThemeImage(_ key: FirebaseImages?) {
        FirebaseStorageManager.shared.saveGalleryImage(key: key)
        NotificationCenter.default.post(name: .didGalleryBGImageChanged, object: nil)
    }

    private func stopLoader() {
        if let visibleVC = UIApplication.topViewController() as? UIAlertController {
            visibleVC.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Actions
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func saveBtnTapped() {
        if let selectedItem = collectionView.indexPathsForSelectedItems?.first?.row {
            var key: FirebaseImages?
            switch selectedItem {
            case 0:
                key = .none
            case 1:
                key = .desert
            case 2:
                key = .forest
            case 3:
                key = .mountain
            case 4:
                key = .sea
            case 5:
                key = .sunset
            default:
                key = .universe
            }
            self.saveThemeImage(key)
        }
        self.back()
    }

    /*
     We need to observe storage changes because users can enter early in this screen. In this way, we manage to have updated data for users.
     */
    @objc func observeFBStorage() {
        images.removeAll()
        self.stopLoader()
        getImages()
        collectionView.reloadData()
        self.collectionView.selectItem(at: IndexPath(row: predefinedIndex, section: 0), animated: true, scrollPosition: [])
    }

}

// MARK: - UICollectionView Delegates
extension ThemeSelectionVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCell
        cell.imageView?.image = images[safe: indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SelectThemeHeaderView.identifier,
            for: indexPath) as! SelectThemeHeaderView
        headerView.setupCell()

        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.cellForItem(at: indexPath)?.isSelected == true {
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            saveBtnIsEnabled = true
            return true
        }

        saveBtnIsEnabled = false
        return false
    }

}
