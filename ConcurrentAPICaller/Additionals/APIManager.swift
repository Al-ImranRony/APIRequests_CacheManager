//
//  APIManager.swift
//  ConcurrentAPICaller
//
//  Created by iMrn on 8/27/23.
//

import Foundation
import Combine
import Alamofire

class APIManager {
    
    static let shared = APIManager()
    
    let requestURL = URL(string: "http://5.161.127.61:8000/api/events")
    
    var callCount = 0
    
    private let initiatedCallsKey = "InitiatedCalls"
    
    private var initiatedCalls: Int {
        get { UserDefaults.standard.integer(forKey: initiatedCallsKey) }
        set { UserDefaults.standard.set(newValue, forKey: initiatedCallsKey) }
    }
    
    var cancellables = Set<AnyCancellable>()
    
    func makePostCall() -> Future<Int, NSError> {
        let postData = Event(appID: "81a7d665-0e97-4e78-8b74-625f1743f9a2",
                             quidd: "12as3213-s912-85m3-9m2p-31c5s124gq19",
                             name: "home_page",
                             params: Params(param1: "some val"))
        
        initiatedCalls += 1
        
        return Future<Int, NSError> { [self] promise in
            guard let requestURL else { return }
            let request = NSMutableURLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let jsonData = try JSONEncoder().encode(postData)
                request.httpBody = jsonData
            } catch {
                print("Error encoding data:", error)
                return
            }
            
            let session = URLSession.shared
            session.dataTaskPublisher(for: request as URLRequest)
                .receive(on: RunLoop.main)
                .tryMap { (data, response) -> () in
                    guard let response = response as? HTTPURLResponse,
                        response.statusCode >= 200 else {
                        throw NSError(domain: "Error", code: 500)
                    }
                    
                    return
                }
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.callCount += 1
                        self?.initiatedCalls -= 1
                        print("Network call completed")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] in promise(.success(self?.callCount ?? 0)) }
                .store(in: &cancellables)
        }
    }
    
    func makeRequestWithAlamofire(completion: @escaping () -> ()) {
        let parameters: [String: Any] = [
            "app_id": "81a7d665-0e97-4e78-8b74-625f1743f9a2",
            "quidd": "12as3213-s912-85m3-9m2p-31c5s124gq19",
            "name": "home_page",
            "params": [
                "param1": "some val"
            ]
        ]
        
        AF.request("http://5.161.127.61:8000/api/events",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default)
        .response(completionHandler: { response in
            print(response)
            completion()
        })
    }
}
