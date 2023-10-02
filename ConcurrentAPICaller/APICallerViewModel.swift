//
//  APICallerViewModel.swift
//  ConcurrentAPICaller
//
//  Created by iMrn on 2/10/23.
//

import Foundation
import Combine


class APICallerViewModel {
    
    private let apiHandler: APIRequestHandler
    
    private var cancellables = Set<AnyCancellable>()
        
    var requestTags: [Int] = []
    var requestCounter: Int = 0
    var responseCounter: Int = 0
    
    private var initiatedCalls: Int {
        get { UserDefaults.standard.integer(forKey: UserDefaultOperation.initiatedCallsKey.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultOperation.initiatedCallsKey.rawValue) }
    }
    
    let context = CoreDataStack.shared.getContext()
    
    init(apiHandler: APIRequestHandler) {
        self.apiHandler = apiHandler
    }
    
    func updateCounters() {
        initiatedCalls += 1
        requestCounter += 1
        requestTags.append(requestCounter)
        
        UserDefaultsManager.shared.setAPIRequestTags(tags: requestTags)
    }
}

//MARK: API Requests Handler
extension APICallerViewModel {
    func subscribeRequestedResponse(methodType: HTTPMethodType, url: URL, parameters: Parameters?, onComplete: @escaping (_ methodType: HTTPMethodType)->()) {
        updateCounters()
        
        var params = Parameters(appID: "", quidd: "", name: "", params: "")
        if let parameters {
            params = parameters
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
                    
                    onComplete(methodType)
                case .failure(let error):
                    print(error.localizedDescription)
                    onComplete(methodType)
                }
            } receiveValue: { [weak self] data in
                if !data.isEmpty {
                    self?.responseCounter += 1
                }
            }
            .store(in: &cancellables)
        
    }
    
    func recallRemainingRequests(completion: @escaping (_ methodType: HTTPMethodType)->()) {
        var remainingCalls: Array<Int> = []
        remainingCalls = UserDefaultsManager.shared.getAPIRequestTags()
        
        print("Store Info Check: \(remainingCalls)")
        for callID in remainingCalls  {
            APIRequestInfo.fetchStoredInfo(requestTag: callID) { [weak self] fetchedInfo in
                
                if let url = URL(string: fetchedInfo.url) {
                    let params = fetchedInfo.parameters
                    
                    for type in HTTPMethodType.allCases {
                        if fetchedInfo.method == type.rawValue {
                            self?.subscribeRequestedResponse(methodType: type, url: url, parameters: params, onComplete: { methodType in
                                print("Stored Request completed")
                                
                                completion(methodType)
                            })
                        }
                    }
                } else {
                    print("Stored Request Info not adequate: \(fetchedInfo)")
                }
            }
        }
    }
}

//MARK: Cache Mechanism
extension APICallerViewModel {
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
