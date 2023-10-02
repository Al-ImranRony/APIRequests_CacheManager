//
//  ViewController.swift
//  ConcurrentAPICaller
//
//  Created by Bitmorpher 4 on 8/27/23.
//

import Foundation
import Combine
import Alamofire


class ViewController: UIViewController {
        
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupView()
    }
    
    private func setupView() {
        self.view.backgroundColor = .darkGray
        
        label.text = "Go to API Caller"
        label.font = UIFont(name: "Helvetica", size: 21)
        label.textColor = .white
        label.center = CGPoint(x: (UIWindow().screen.bounds.width/2), y: UIWindow().screen.bounds.height/2)
        label.textAlignment = .center
        
        self.view.addSubview(label)
        
        button.center = CGPoint(x: (UIWindow().screen.bounds.width/2), y: (UIWindow().screen.bounds.height/2) + 80)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitle("Show", for: .normal)
        button.addTarget(self, action: #selector(showButtonAction), for: .touchUpInside)
        button.layer.cornerRadius = 4
        self.view.addSubview(button)
    }

    @objc func showButtonAction(sender: UIButton!) {
        let callerVC = CallerViewController()
        self.present(callerVC, animated: false)
    }
}

