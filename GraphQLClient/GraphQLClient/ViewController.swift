//
//  ViewController.swift
//  GraphQLClient
//
//  Created by Serkan Kayaduman on 22.05.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtResponse: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnSendRequestJson_click(_ sender: Any) {
        
        guard let url = URL(string: "https://spacex-production.up.railway.app/") else { return }
        
        let instance = GraphQL(baseUrl: url)
        let queryFile = "SampleQuery.graphQL"
        let sampleParams = [ "name": "users" ]
        
        instance.fetchJson(queryFileName: queryFile, parameters: sampleParams) { [weak self] data, error in
            if let err = error {
                self?.showAlert(message: err)
            } else if let dt = data as? [String:Any] {
                self?.txtResponse.text = "Success:\n\n \(dt.description)"
            }
        }
    }
    
    @IBAction func btnSendRequestData_click(_ sender: Any) {
        
        guard let url = URL(string: "https://spacex-production.up.railway.app/") else { return }
        
        let instance = GraphQL(baseUrl: url)
        let queryFile = "SampleQuery.graphQL"
        let sampleParams = [ "name": "users" ]
        
        instance.fetchData(queryFileName: queryFile, parameters: sampleParams) { [weak self] data, error in
            if let err = error {
                self?.showAlert(message: err)
            } else if let dt = data {
                guard let st = String(data: dt, encoding: .utf8) else { return }
                self?.txtResponse.text = "Success:\n\n \(st)"
            }
        }
    }
    
    private func showAlert(message:String) {
        let alertVC = UIAlertController(title: "GraphQL Test", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        self.present(alertVC, animated: true)
    }
}

