//
//  HomeViewController.swift
//  Warehouse App
//
//  Created by Anh Dinh on 4/11/22.
//

import Foundation
import UIKit
import FirebaseDatabase

class HomeViewController: UIViewController {
    private var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    private let currentItemsLabel: UILabel = {
        let label = UILabel()
        label.text = Constant.shared.currentItemsInStore
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    lazy private var collectionView: UICollectionView = {
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 120)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HomePageCollectionViewCell.self, forCellWithReuseIdentifier: HomePageCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    var homePageViewModelArray: [HomePageViewModel] = []
    var dictionaryArray = [[String:Any]]()
    
    // deinit for NSNotificationCenter
    deinit {
        NotificationCenter.default
            .removeObserver(self, name:  NSNotification.Name("addNewItem"), object: nil)
    }

//MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpUI()
        getDataForViewModelArray()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: NSNotification.Name("addNewItem"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        currentItemsLabel.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 5, width: view.frame.width, height: 20)
        let navBarHeight = navigationController?.navigationBar.bounds.height ?? 0
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        collectionView.frame = CGRect(x: 0,
                                      y: view.safeAreaInsets.top + 30,
                                      width: view.frame.width,
                                      height: view.frame.height - navBarHeight - statusBarHeight - (self.tabBarController?.tabBar.frame.size.height)! ?? 0)
    }

    //=======================================================================================================
    //MARK: Functions
    //=======================================================================================================
    func setUpUI(){
        view.addSubview(collectionView)
        view.addSubview(currentItemsLabel)
    }
    
    func getDataForViewModelArray(){
        DatabaseManager.shared.readItems{ [weak self] (values,id) in
            if let values = values, let id = id {
                // print("values in HomeVC: \(values)") ---> print dong nay ra se thay dictionary tra ve la tung thang dictionary rieng re, ko hieu sao lai tra ve kieu nay thay vi la 1 whole dictionary
                // THOUGHT: values tra ve la tung thang dictionary, nen moi lan tra ve minh append vo array of homePageViewModel
                self?.homePageViewModelArray.append(HomePageViewModel(item: values,itemID: id))
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func reloadCollectionView(){
        self.collectionView.reloadData()
    }
}

//MARK: - Extensions CollectionView
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homePageViewModelArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePageCollectionViewCell.identifier, for: indexPath) as? HomePageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.deleage = self
        let model = homePageViewModelArray[indexPath.row]
        cell.configure(viewModel: model)
        return cell
    }

}

//MARK: - Extension Protocol Functions
extension HomeViewController: HomePageCollectionViewCellDelegate {
    func didTapUpdateButton(cell: HomePageCollectionViewCell) {
        if let item = cell.itemNameLabel.text, let itemQuantity = cell.itemQuantityLabel.text, let itemID = cell.itemID {
            let alert = UIAlertController(title: "Update", message: "Item: \(item)\nQuantity: \(itemQuantity)", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Update new quantity"
                textField.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { _ in
                
            }))
            alert.addAction(UIAlertAction(title: "Update", style: .destructive, handler: { _ in
                guard let fields = alert.textFields else {
                    return
                }
                let itemNewQuantiyField = fields[0]
                guard let itemNewQuantity = itemNewQuantiyField.text, !itemNewQuantity.isEmpty else {
                    print("Error TextField")
                    return
                }
                DatabaseManager.shared.updateNewQuantity(item: item,id: itemID, newQuantity: Int(itemNewQuantity) ?? 0){ [weak self]  success in
                    print("Success: \(success)")
                    if success {
                        DispatchQueue.main.async {
                            // clear array and refetch data
                            self?.homePageViewModelArray = []
                            self?.getDataForViewModelArray()
                        }
                    }
                }
            }))
            present(alert,animated: true)
        }
    }
}
