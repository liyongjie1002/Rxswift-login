//
//  ViewController.swift
//  RxSwift-login
//
//  Created by 李永杰 on 2021/4/26.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .custom)
        button.setTitle("去登录", for: .normal)
        button.setTitleColor(.systemPurple, for: .normal)
        self.view.addSubview(button)
        button.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(45)
        }
        button.rx.tap.subscribe(onNext: {
            let loginVC = NPLoginViewController()
            self.navigationController?.pushViewController(loginVC, animated: true)
        }).disposed(by: disposeBag)
    }
}

