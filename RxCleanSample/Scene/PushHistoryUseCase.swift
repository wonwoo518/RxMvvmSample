//
//  PushHistoryUseCase.swift
//  RxCleanSample
//
//  Created by 이원우 on 2021/04/05.
//

import Foundation
import RxSwift

protocol UseCase {
    associatedtype Entity
    func post() -> Observable<Entity>
}

struct PushHistoryUseCase<RepositoryType: RepositoryProtocol>: UseCase {
    private let bag = DisposeBag()
    var repository: RepositoryType = RepositoryType()
    func post() -> Observable<[String]>{
        Observable.create { observer -> Disposable in
            repository.post().asSingle().subscribe( onSuccess: {result in
                observer.onNext(["aa","bb", "cc"])
            }, onFailure: { (Error) in
                observer.onError(NSError())
            }).disposed(by: bag)

            return Disposables.create()
        }
    }
}
