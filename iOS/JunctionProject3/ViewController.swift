//
//  ViewController.swift
//  JunctionProject3
//
//  Created by 塗木冴 on 2018/03/24.
//  Copyright © 2018年 SaeNuruki. All rights reserved.
//

import UIKit
import Rswift
import RxSwift
import RxCocoa
import Alamofire
import ObjectMapper
import SwiftyJSON
import AlamofireObjectMapper

class ViewController: UIViewController {

    fileprivate let bag = DisposeBag()
    fileprivate let serverURL: String = "http://0.0.0.0:8545/getHistoriesFromBuyer"
    fileprivate(set) var viewModel = ViewModel()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

fileprivate extension ViewController {

    func configure() {
        tableView.register(R.nib.mainTableCell)
        tableView.separatorStyle = .none
        configurePullDownReload()
    }

    private func configurePullDownReload() {
        tableView.addPullRefresh { [weak self] in
            guard let wself = self else { return }
            print("再読込します")
            wself.getRequest()
            wself.tableView.stopPullRefreshEver()
        }
    }

    private func bindFromVM() {
        viewModel
            .transactions
            .asDriver()
            .drive(tableView.rx.items(
                cellIdentifier: R.reuseIdentifier.mainTableCell.identifier,
                cellType: MainTableCell.self
            )) { _, transaction, cell in
                cell.selectionStyle = .none
                cell.configure(by: transaction)
            }
            .disposed(by: bag)
    }

    private func getRequest() {

        let method = "POST"
        let body: [String: Any] = [
            "address": "0x5b57ccf99f0d4f731208c7fc64c2bd957dec5894"
            ]
        let httpBody: Data? = try? JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
        var urlRequest = URLRequest(url: URL(string: serverURL)!)
        urlRequest.httpMethod = method
        urlRequest.httpBody = httpBody
        request(urlRequest).responseJSON() { [weak self] response in
            guard let wself = self else { return }
            switch response.result {
            case .success(let json):
                let map = Map(mappingType: .fromJSON, JSON: json as? [String : Any] ?? [:])
                var transactions: [Transaction] = []
                transactions <- map["result"]
                wself.viewModel.transactionTrigger.onNext(transactions)
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.transactions.value.count
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.mainTableCell, for: indexPath) else { return UITableViewCell() }
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MainTableCell.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapしたよ")
    }
}

