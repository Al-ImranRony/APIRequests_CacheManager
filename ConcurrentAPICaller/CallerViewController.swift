//
//  CallerViewController.swift
//  ConcurrentAPICaller
//
//  Created by Bitmorpher 4 on 8/30/23.
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
    
    var requestURL: URL?
        
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
    let getCallButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    var counterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIWindow().screen.bounds.width, height: 550))
    
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        recallRemainingRequests()
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
        label.font = UIFont(name: "Helvetica", size: 21)
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
        initiatedCalls += 1
        requestCounter += 1
        requestTags.append(requestCounter)
        
        UserDefaultsManager.shared.setAPIRequestTags(tags: requestTags)

        print("Post Tapped \(self.initiatedCalls) times")
        requestURL = URL(string: "http://5.161.127.61:8000/api/events")
        subscribeRequestedResponse(methodType: .post, url: requestURL!)
    }
    
    @objc func getButtonAction(sender: UIButton!) {
        initiatedCalls += 1
        requestCounter += 1
        requestTags.append(requestCounter)
        
        UserDefaultsManager.shared.setAPIRequestTags(tags: requestTags)

        print("Get Tapped \(self.initiatedCalls) times")
        requestURL = URL(string: "https://jsonplaceholder.typicode.com/todos")
        subscribeRequestedResponse(methodType: .get, url: requestURL!)
    }
}

//MARK: API Requests Handler
extension CallerViewController {
    func subscribeRequestedResponse(methodType: HTTPMethodType, url: URL) {
        var params = Parameters(appID: "", quidd: "", name: "", params: "")
        if methodType == .post {
            params = Parameters(appID: "81a7d665-0e97-4e78-8b74-625f1743f9a2",
                                    quidd: "12as3213-s912-85m3-9m2p-31c5s124gq19",
                                    name: "home_page",
                                    params: "some val")
        }
        let storedInfo: APIRequestInfo = storeRequestInfo(methodType: methodType, url: url, parameters: params)
        
        apiHandler.makeRequest(method: methodType, url: url)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("Network call completed")
                    self?.removeTagsFromUserDefault()
                    self?.initiatedCalls -= 1
                    self?.removeStoredRequestInfo(requestInfo: storedInfo)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] data in
                if !data.isEmpty {
                    self?.responseCounter += 1
                }
                
                DispatchQueue.main.async {
                    self?.counterLabel.pushTransition(0.2)
                    if let responseCounter = self?.responseCounter {
                        self?.counterLabel.text = "\(responseCounter)"
                        self?.label.text = "Requested \(responseCounter) times"
                        print("\(methodType.rawValue) Called \(responseCounter) times")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func recallRemainingRequests() {
        var remainingCalls: Array<Int> = []
        remainingCalls = UserDefaultsManager.shared.getAPIRequestTags()
        
        print("Store Info Check: \(remainingCalls)")
        for callID in remainingCalls  {
            APIRequestInfo.fetchStoredInfo(requestTag: callID) { [weak self] fetchedInfo in
                self?.storedRequestInfo = fetchedInfo
                
                if let url = URL(string: fetchedInfo.url) {
                    for type in HTTPMethodType.allCases {
                        if fetchedInfo.method == type.rawValue {
                            self?.subscribeRequestedResponse(methodType: type, url: url)
                        }
                    }
                } else {
                    print("Store Info remained: \(fetchedInfo)")
                }
            }
        }
    }
}

//MARK: Cache Mechanism
extension CallerViewController {
    func removeStoredRequestInfo(requestInfo: APIRequestInfo) {
        APIRequestInfo.removeFromDB(requestInfo: requestInfo) {
            print("Removing successfull")
        }
    }
    
    func storeRequestInfo(methodType: HTTPMethodType, url: URL, parameters: Parameters) -> APIRequestInfo {
        let requestInfo = APIRequestInfo(context: context!)
        requestInfo.id = Int32(initiatedCalls)
        requestInfo.url = url.absoluteString
        requestInfo.methodType = methodType.rawValue
        requestInfo.params = parameters
        
        APIRequestInfo.saveToDB(requestInfo: requestInfo) {
            print("Saving successfull")
        }
        return requestInfo
    }
    
    func removeTagsFromUserDefault() {
        if requestTags.count > 0 {
            requestTags.removeLast()
            UserDefaultsManager.shared.setAPIRequestTags(tags: requestTags)
        }
    }
}

//MARK: APIManager with given parameters
extension CallerViewController {
    func makeAPIRequest() {
        APIManager.shared.makePostCall()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Call Completed")
                case .failure(let error):
                    print("Data fetching error: \(String(describing: error.localizedDescription))")
                }
            }, receiveValue: { [weak self] response in
                self?.counterLabel.pushTransition(0.2)
                self?.label.text = "Requested \(APIManager.shared.callCount) times"
                print("API Called \(APIManager.shared.callCount) times")
            })
            .store(in: &cancellables)
    }
    
    func restoreAPIRequests(occurances: Int) {
        for _ in 1...occurances {
            APIManager.shared.makeRequestWithAlamofire {
                self.counterLabel.pushTransition(0.2)
                self.label.text = "Requested \(APIManager.shared.callCount) times"
                print("ReCalled \(APIManager.shared.callCount) times")
            }
        }
    }
}
