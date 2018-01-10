//
//  LanguageVC.swift
//  RX
//
//  Created by Avtar Singh on 04/01/18.
//  Copyright © 2018 Avtar Singh. All rights reserved.
//

import UIKit
import RxSwift
class LanguageVC: UIViewController {

    let bag = DisposeBag()
    
    var viewModel: LanguageViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupBindings()
    }

    
    private func setupUI(){
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.title = "Choose a language"
        self.tableView.rowHeight = 48.0
    }
    private func setupBindings(){
        viewModel.languages
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "LanguageCell", cellType: UITableViewCell.self)){(_,language,cell) in
                cell.textLabel?.text = language
                cell.selectionStyle = .none
        }
        .disposed(by: bag)
        
        tableView.rx.modelSelected(String.self)
        .bind(to: viewModel.selectLanguage)
        .disposed(by: bag)
        
        cancelButton.rx
            .tap
            .bind(to: viewModel.cancel)
            .disposed(by: bag)
    }
}
