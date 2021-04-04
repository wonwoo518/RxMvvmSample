//
//  ViewModel.swift
//  RxCleanSample
//
//  Created by 이원우 on 2021/04/05.
//

import Foundation
import RxSwift
import RxRelay

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
}

protocol RepositoryProtocol{
    associatedtype Entity
    init()
    func post() -> Observable<Entity>
    func save(entity: Entity)
}


class PushHistoryEntity {}
class MoyaRepository<T>: RepositoryProtocol {
    required init(){}
    func post() -> Observable<T>{
        Observable.create { (_) -> Disposable in
            return Disposables.create {}
        }
    }
    func save(entity: T){}
}

class PushListViewModel: ViewModelType {
    struct Input {
        let historyFetchTrigger: PublishRelay<Void>
    }
    struct Output {
        let realmNotificationRelay: PublishRelay<[String]>
        let historyList: PublishRelay<[String]>
    }

    private var useCase = PushHistoryUseCase<MoyaRepository<[String]>>()
    let input: Input
    let output: Output
    let bag: DisposeBag = DisposeBag()
    init(input: Input, output: Output) {
        self.input = input
        self.output = output
        
        input.historyFetchTrigger.subscribe( onNext: { [weak self] _ in
            guard let self = self else { return }
            self.useCase.repository.post().asSingle().subscribe(onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.output.realmNotificationRelay.accept(result)
                
            }).disposed(by: self.bag)
        }).disposed(by: bag)
        
        output.realmNotificationRelay.subscribe(onNext: { (result) in
            self.output.historyList.accept(result)
        }).disposed(by: bag)
    }
}

