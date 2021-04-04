//
//  ViewController.swift
//  RxCleanSample
//
//  Created by 이원우 on 2021/03/29.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {

    var disposeBag: DisposeBag = {
        return DisposeBag()
    }()
    var viewModel: PushListViewModel!
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupSubview()
        setupBinding()
    }
    
    func setupSubview(){
        tableView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    func setupBinding(){
        let fetchTrigger = PublishRelay<Void>()
        tableView.rx.contentOffset.subscribe (onNext: { [fetchTrigger] point in
            //adds a case to fecth
            fetchTrigger.accept(())
        }).disposed(by: disposeBag)

        let historyListObservable = PublishRelay<[String]>()
        historyListObservable.subscribe(onNext: { [tableView] _ in
            tableView.reloadData()
        }).disposed(by: disposeBag)
        
        let realmNotificationObservable = PublishRelay<[String]>()
        realmNotificationObservable
            .bind(to: historyListObservable)
            .disposed(by: disposeBag)
        
        self.viewModel = PushListViewModel(input: PushListViewModel.Input(historyFetchTrigger: fetchTrigger),
                                           output: PushListViewModel.Output(realmNotificationRelay: realmNotificationObservable, historyList: historyListObservable))
    }
}

extension ViewController: UITableViewDelegate {
    
}
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
    }
}

