//
//  ThemeSelectionVC.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 28/10/21.
//

import UIKit

class ThemeSelectionVC: BaseVC {

    private var cellIdentifier = "GalleryCell"
    private var saveBtnIsEnabled: Bool = false {
        didSet {
            self.navigationItem.rightBarButtonItem?.isEnabled = saveBtnIsEnabled
        }
    }

    private var storageKey: FirebaseImages? = FirebaseStorageManager.shared.retrieveGalleryImage().key
    private var predefinedIndex: Int { /// This field is used for observing the pre-selected theme from current user.
        get {
            for (index, element) in FirebaseImages.allCases.enumerated() {
                if element.rawValue == storageKey?.rawValue {
                    return index + 1 // +1 because index -> 0 is the default state
                }
            }
            return 0
        }
    }

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 250)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGray6
        cv.showsVerticalScrollIndicator = false
        cv.isPrefetchingEnabled = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.selectItem(at: IndexPath(row: self.predefinedIndex, section: 0), animated: true, scrollPosition: [])
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

    private func saveThemeImage(_ key: FirebaseImages?, image: UIImage?) {
        FirebaseStorageManager.shared.saveGalleryImage(key: key, image: image)
        NotificationCenter.default.post(name: .didGalleryBGImageChanged, object: nil)
    }

    // MARK: - Actions
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func saveBtnTapped() {
        if let selectedItem = collectionView.indexPathsForSelectedItems?.first?.row {
            let cell = collectionView.cellForItem(at: IndexPath(row: selectedItem, section: 0)) as? GalleryCell

            let key = FirebaseImages.init(rawValue: cell?.accessibilityLabel ?? String())

            self.saveThemeImage(key, image: cell?.imageView?.image)
        }
        self.back()
    }

}

// MARK: - UICollectionView Delegates
extension ThemeSelectionVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GalleryCellDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FirebaseStorageManager.shared.availableImages.count + 1 // +1 for default image
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCell
        if indexPath.row == 0 {
            cell.imageView?.image = UIImage(named: "Pattern")
        } else {
            cell.loadFBStorageImage(indexPath.row)
        }

        cell.delegate = self
        cell.accessibilityLabel = FirebaseImages.allCases[safe: indexPath.row - 1]?.rawValue
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

    func didReceiveError(code: Int, message: String) {
        self.sendAnalytics("\(message) with code: \(code)")
        let alert = UIAlertController(title: "fb_error".localized(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        self.present(alert, animated: true, completion: {
            self.back()
        })
    }
}
