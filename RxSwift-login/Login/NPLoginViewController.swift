//
//  NPLoginViewController.swift
//
//
//  Created by 李永杰 on 2021/4/26.
//  Copyright © 2021 李永杰. All rights reserved.
//

import UIKit
import SnapKit

public class NPLoginViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    private func configUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(loginView)
        loginView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var loginView: NPLoginView = {
        let view = NPLoginView()
        return view
    }()
    
    deinit {
        print("登录页面释放了")
    }
}
