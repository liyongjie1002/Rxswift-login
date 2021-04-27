//
//  NPLoginView.swift
//  NPMine
//
//  Created by 李永杰 on 2021/4/26.
//  Copyright © 2021 李永杰. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let kLeftMargin: CGFloat = 16
private let kInnerMargin: CGFloat = 13

private let kCountDown: Int = 59 // 计时器从0开始
private let kCodeTitle = "获取验证码"

class NPLoginView: UIView {
 
    let disposeBag = DisposeBag()
    
    var timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        configRx()
    }
    
    private func configRx() {
        let phoneValid = phoneField.rx.text.orEmpty.map {
            return $0.count == 11
        }
        let codeValid  = codeField.rx.text.orEmpty.map {
            return $0.count == 6
        }
        let sureValid = Observable.combineLatest(phoneValid, codeValid) {
            return  $0 && $1
        }
        // 确认按钮是否可用
        sureValid.subscribe(onNext: { [weak self] result in
            self?.sureButton.isEnabled = result
            if result {
                self?.sureButton.backgroundColor = HexColorAlpha("#126EFD")
            } else {
                self?.sureButton.backgroundColor = HexColorAlpha("#F9F9F9")
            }
        }).disposed(by: disposeBag)
        // 获取验证码是否可用
        phoneValid.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] result in
            let title = self?.codeButton.title(for: .disabled)!
            /*
             为什么有这个判断
             当timer发送序列时，切换输入框会调用到这里，导致timer和phoneValid同时修改按钮的冲突
             timer发送序列时，disabled的title动态改变，根据这个判断避免冲突
             */
            if title == kCodeTitle {
                self?.codeButton.isEnabled = result
                if result {
                    self?.codeButton.backgroundColor = HexColorAlpha("E8F1FF")
                } else {
                    self?.codeButton.backgroundColor = HexColorAlpha("#F9F9F9")
                }
            }
        }).disposed(by: disposeBag)

        // 点击发送验证码
        codeButton.rx.tap.debounce(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] in
            if self?.phoneField.text?.count != 11 {
                print("请输入正确的手机号")
                return
            }
            self?.codeField.becomeFirstResponder()
            // 开启定时器
            self?.configTimer()
        }).disposed(by: disposeBag)
        // 点击确认
        sureButton.rx.tap.subscribe(onNext: {
            print("确定点击了")
        }).disposed(by: disposeBag)
    }
    
    /*
     停止条件
     1. 在倒计时的时候又输入手机号
     2. 时间到了
     */
    private func configTimer() {
        let observe = timer.take(while: { [weak self] count in
            let result = self!.phoneField.text?.count == 11
            return count <= kCountDown && result
        })
        observe.subscribe(onNext: { [weak self] count in
            let title = "\(count+1)s"
            print(title)
            self?.codeButton.isEnabled = false
            self?.codeButton.setTitle(title, for: .disabled)
            self?.codeButton.backgroundColor = HexColorAlpha("#F9F9F9")
            let textWidth: CGFloat = (self?.codeButton.titleLabel?.text ?? "").widthWithFont(font: kFontRegularSize(12), fixedHeight: 30) + 22
            self?.codeButton.snp.remakeConstraints { (make) in
                make.width.equalTo(textWidth)
            }
        }, onError: { (error) in
            print(error)
        }, onCompleted: { [weak self] in
            let result = self!.phoneField.text?.count == 11
            if result {
                self?.codeButton.isEnabled = true
                self?.codeButton.backgroundColor = HexColorAlpha("E8F1FF")
                self?.codeButton.setTitle(kCodeTitle, for: .disabled)
            } else {
                self?.codeButton.isEnabled = false
                self?.codeButton.backgroundColor = HexColorAlpha("#F9F9F9")
                self?.codeButton.setTitle(kCodeTitle, for: .disabled)
            }
            let textWidth: CGFloat = (self?.codeButton.titleLabel?.text ?? "").widthWithFont(font: kFontRegularSize(12), fixedHeight: 30) + 22
            self?.codeButton.snp.remakeConstraints { (make) in
                make.width.equalTo(textWidth)
            }
            print("定时器完成了")
        }, onDisposed: {
            print("定时器释放了")
        }).disposed(by: disposeBag)
    }
    
    private func configUI() {
        
        addSubview(phoneLabel)
        addSubview(phoneField)
        addSubview(phoneLineView)
        addSubview(codeLabel)
        addSubview(codeField)
        addSubview(codeButton)
        addSubview(codeLineView)
        addSubview(sureButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        phoneLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(kLeftMargin)
            make.top.equalTo(100)
            make.width.equalTo(codeLabel)
        }
        phoneField.snp.remakeConstraints { (make) in
            make.left.equalTo(phoneLabel.snp.right).offset(34)
            make.centerY.equalTo(phoneLabel)
            make.right.equalTo(codeField)
        }
        phoneLineView.snp.remakeConstraints { (make) in
            make.top.equalTo(phoneLabel.snp.bottom).offset(kInnerMargin)
            make.left.equalTo(kLeftMargin)
            make.right.equalTo(-kLeftMargin)
            make.height.equalTo(1)
        }
        codeLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(kLeftMargin)
            make.width.equalTo(80)
            make.top.equalTo(phoneLineView.snp.bottom).offset(kInnerMargin)
        }
        codeField.snp.remakeConstraints { (make) in
            make.left.equalTo(codeLabel.snp.right).offset(34)
            make.centerY.equalTo(codeLabel)
            make.right.equalTo(codeButton.snp.left)
        }
        let textWidth: CGFloat = (codeButton.titleLabel?.text ?? "").widthWithFont(font: kFontRegularSize(12), fixedHeight: 30) + 22
        codeButton.snp.remakeConstraints { (make) in
            make.right.equalTo(-kLeftMargin)
            make.centerY.equalTo(codeLabel)
            make.height.equalTo(30)
            make.width.equalTo(textWidth)
        }
        codeLineView.snp.remakeConstraints { (make) in
            make.top.equalTo(codeLabel.snp.bottom).offset(12.5)
            make.left.equalTo(kLeftMargin)
            make.right.equalTo(-kLeftMargin)
            make.height.equalTo(1)
        }
        sureButton.snp.remakeConstraints { (make) in
            make.top.equalTo(codeLineView.snp.bottom).offset(80)
            make.left.equalTo(37.5)
            make.right.equalTo(-37.5)
            make.height.equalTo(44)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("登录view释放了")
    }
     
    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "手机号"
        label.textColor = HexColorAlpha("#262626")
        label.font = kFontRegularSize(16)
        return label
    }()
      
    private lazy var phoneField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString.init(string: "请输入手机号", attributes: [NSAttributedString.Key.foregroundColor: HexColorAlpha("#808080"), NSAttributedString.Key.font: kFontRegularSize(14)])
        field.font = kFontRegularSize(14)
        field.textColor = HexColorAlpha("#262626")
        field.keyboardType = .phonePad
        field.delegate = self
        return field
    }()
    
    private lazy var phoneLineView: UIView = {
        let view = UIView()
        view.backgroundColor = HexColorAlpha("#EBEBEB", 0.5)
        return view
    }()
    
    private lazy var codeField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString.init(string: "请输入短信验证码", attributes: [NSAttributedString.Key.foregroundColor: HexColorAlpha("#808080"), NSAttributedString.Key.font: kFontRegularSize(14)])
        field.font = kFontRegularSize(14)
        field.textColor = HexColorAlpha("#262626")
        field.keyboardType = .phonePad
        field.delegate = self
        return field
    }()
    
    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "短信验证码"
        label.textColor = HexColorAlpha("#262626")
        label.font = kFontRegularSize(16)
        return label
    }()
    
    private lazy var codeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(kCodeTitle, for: .normal)
        button.setTitleColor(HexColorAlpha("#126EFD"), for: .normal)
        button.setTitleColor(HexColorAlpha("#AFAFAF"), for: .disabled)
        button.titleLabel?.font = kFontRegularSize(12)
        return button
    }()
    
    private lazy var codeLineView: UIView = {
        let view = UIView()
        view.backgroundColor = HexColorAlpha("#EBEBEB", 0.5)
        return view
    }()
     
    private lazy var sureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确认修改", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(HexColorAlpha("#AFAFAF"), for: .disabled)
        button.titleLabel?.font = kFontRegularSize(16)
        return button
    }()
}

extension NPLoginView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        if textField == phoneField {
            if textField.text!.count >= 11 {
                return false
            }
        }
        if textField == codeField {
            if textField.text!.count >= 6 {
                return false
            }
        }
        return true
    }
}
