//
//  RepositryListVCViewController.swift
//  RX
//
//  Created by Avtar Singh on 04/01/18.
//  Copyright © 2018 Avtar Singh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices
class RepositryListVC: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    
    
    enum SegueType:String{
        case languageList = "Show Language List"
    }
    
    private let chooseLanguageButton = UIBarButtonItem(barButtonSystemItem: .organize , target: nil, action: nil)
    
    private let refreshControl = UIRefreshControl()
    
    
     private let viewModel = RepositoryListViewModel(initialLanguage: "Swift")
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        refreshControl.sendActions(for: .valueChanged)
    }
    private func setupUI() {
        navigationItem.rightBarButtonItem = chooseLanguageButton
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.insertSubview(refreshControl, at: 0)
    }
    private func setupBindings() {
        
        // View Model outputs to the View Controller
        
        viewModel.repositories
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .bind(to: tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) { [weak self] (_, repo, cell) in
                self?.setupRepositoryCell(cell, repository: repo)
            }
            .disposed(by: disposeBag)
        
        viewModel.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.showRepository
            .subscribe(onNext: { [weak self] in self?.openRepository(by: $0) })
            .disposed(by: disposeBag)
        
        viewModel.showLanguageList
            .subscribe(onNext: { [weak self] in self?.openLanguageList() })
            .disposed(by: disposeBag)
        
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] in self?.presentAlert(message: $0) })
            .disposed(by: disposeBag)
        
        // View Controller UI actions to the View Model
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
        
        chooseLanguageButton.rx.tap
            .bind(to: viewModel.chooseLanguage)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(RepositoryViewModel.self)
            .bind(to: viewModel.selectRepository)
            .disposed(by: disposeBag)
    }
    
    private func setupRepositoryCell(_ cell: RepositoryCell, repository: RepositoryViewModel) {
        cell.selectionStyle = .none
        cell.setName(repository.name)
        cell.setDescription(repository.description)
        cell.setStarsCountTest(repository.starsCountText)
    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    // MARK: - Navigation
    
    private func openRepository(by url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        navigationController?.pushViewController(safariViewController, animated: true)
    }
    
    private func openLanguageList() {
        performSegue(withIdentifier: SegueType.languageList.rawValue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC: UIViewController? = segue.destination
        
        if let nvc = destinationVC as? UINavigationController {
            destinationVC = nvc.viewControllers.first
        }
        
        if let viewController = destinationVC as? LanguageListViewController, segue.identifier == SegueType.languageList.rawValue {
            prepareLanguageListViewController(viewController)
        }
    }
    
    /// Setups `LanguageListViewController` befor navigation.
    ///
    /// - Parameter viewController: `LanguageListViewController` to prepare.
    private func prepareLanguageListViewController(_ viewController: LanguageListViewController) {
        let languageListViewModel = LanguageListViewModel()
        
        let dismiss = Observable.merge([
            languageListViewModel.didCancel,
            languageListViewModel.didSelectLanguage.map { _ in }
            ])
        
        dismiss
            .subscribe(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: viewController.disposeBag)
        
        languageListViewModel.didSelectLanguage
            .bind(to: viewModel.setCurrentLanguage)
            .disposed(by: viewController.disposeBag)
        
        viewController.viewModel = languageListViewModel
    }
}
