//
//  CallerViewController.swift
//  ConcurrentAPICaller
//
//  Created by iMrn on 8/30/23.
//

import UIKit
import Combine
import Alamofire


class CallerViewController: UIViewController {
    
    var requestTags: [Int] = []
    var requestCounter: Int = 0
    var responseCounter: Int = 0
    
    var storedRequestInfo: RequestInfo?
    
    let context = CoreDataStack.shared.getContext()
    
    private var initiatedCalls: Int {
        get { UserDefaults.standard.integer(forKey: UserDefaultOperation.initiatedCallsKey.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultOperation.initiatedCallsKey.rawValue) }
    }
    
    let apiManager = APIManager()
    let apiHandler = APIRequestHandler()
    
    private let viewModel = APICallerViewModel(apiHandler: APIRequestHandler())
    
    var requestURL: URL?
        
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
    let getCallButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: UIWindow().screen.bounds.width, height: 100))
    var counterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIWindow().screen.bounds.width, height: 550))
    
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
        let remainingCalls = UserDefaults.standard.integer(forKey: "InitiatedCalls")
        if remainingCalls > 0 {
            self.restoreAPIRequests(occurances: remainingCalls)
        }
        */
        
        viewModel.recallRemainingRequests { [weak self] methodType in
            self?.updateViewsOnCount(methodType: methodType)
        }
    }
    
    private func setupViews() {
        self.view.backgroundColor = .lightGray
        
        counterLabel.text = "0"
        counterLabel.font = UIFont(name: "Helvetica", size: 150)
        counterLabel.textColor = .purple
        counterLabel.center = CGPoint(x: (UIWindow().screen.bounds.width/2), y: UIWindow().screen.bounds.height/3)
        counterLabel.textAlignment = .center
        self.view.addSubview(counterLabel)
        
        label.text = #"Calling API 3 2 1 . . ."#
        label.font = UIFont(name: "Helvetica", size: 20)
        label.textColor = .purple
        label.center = CGPoint(x: (UIWindow().screen.bounds.width/2), y: UIWindow().screen.bounds.height/2)
        label.textAlignment = .center
        self.view.addSubview(label)
        
        button.center = CGPoint(x: (UIWindow().screen.bounds.width/2), y: (UIWindow().screen.bounds.height/2) + 80)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitle("Post", for: .normal)
        button.addTarget(self, action: #selector(postButtonAction), for: .touchUpInside)
        button.layer.cornerRadius = 4
        self.view.addSubview(button)
        
        getCallButton.center = CGPoint(x: (UIWindow().screen.bounds.width/2), y: (UIWindow().screen.bounds.height/2) + 140)
        getCallButton.backgroundColor = UIColor.systemIndigo
        getCallButton.setTitle("GET", for: .normal)
        getCallButton.addTarget(self, action: #selector(getButtonAction), for: .touchUpInside)
        getCallButton.layer.cornerRadius = 4
        self.view.addSubview(getCallButton)
    }
    
    @objc func postButtonAction(sender: UIButton!) {
        requestURL = URL(string: "http://5.161.127.61:8000/api/events")
        let params = Parameters(appID: "81a7d665-0e97-4e78-8b74-625f1743f9a2",
                                quidd: "12as3213-s912-85m3-9m2p-31c5s124gq19",
                                name: "home_page",
                                params: "some val")
        viewModel.subscribeRequestedResponse(methodType: .post, url: requestURL!, parameters: params) { [weak self] methodType in
            self?.updateViewsOnCount(methodType: methodType)
        }
    }
    
    @objc func getButtonAction(sender: UIButton!) {

        print("Get Tapped \(self.initiatedCalls) times")
        requestURL = URL(string: "https://jsonplaceholder.typicode.com/todos")
        viewModel.subscribeRequestedResponse(methodType: .get, url: requestURL!, parameters: nil) { [weak self] methodType in
            self?.updateViewsOnCount(methodType: methodType)
        }
    }
    
    func updateViewsOnCount(methodType: HTTPMethodType) {
        DispatchQueue.main.async { [weak self] in
            self?.counterLabel.pushTransition(0.2)
            if let responseCounter = self?.viewModel.responseCounter {
                self?.counterLabel.text = "\(responseCounter)"
                self?.label.text = "\(methodType.rawValue) Request: Total Calls: \(responseCounter) Times"
            }
        }
    }
}
