//
//  ViewModel.swift
//  JunctionProject3
//
//  Created by 塗木冴 on 2018/03/24.
//  Copyright © 2018年 SaeNuruki. All rights reserved.
//

import Foundation
import RxSwift

class ViewModel {

    fileprivate let bag = DisposeBag()

    let transactions$: Observable<[Transaction]>
    let transactions = Variable<[Transaction]>([])
    let transactionTrigger = PublishSubject<[Transaction]>()

    init() {

        transactions$ = Observable
            .of(
                Observable.just([]),
                transactionTrigger.asObservable()
            )
            .concat()
            .share(replay: 1)

        transactions$
            .subscribe(onNext: {[weak self] transactions in
                guard let wself = self else { return }
                wself.transactions.value = transactions
            })
            .disposed(by: bag)
    }
}
