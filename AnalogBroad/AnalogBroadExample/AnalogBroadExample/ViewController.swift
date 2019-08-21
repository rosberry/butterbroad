//
//  ViewController.swift
//  AnalogBroadExample
//
//  Created by Nick Tyunin on 08/08/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad

final class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        navigationItem.title = "Analog"
    }
    
    @IBAction func log(_ sender: Any) {
        if let text = textField.text, text.isEmpty == false {
            Butter.common.log(.init(name: text))
            textField.text = ""
        }
    }
    
    @IBAction func showCurrentSessionEvents(_ sender: Any) {
        let controller = Butter.analog.module(for: .current)
        present(controller, animated: true)
    }
    
    @IBAction func showAllSessionsEvents(_ sender: Any) {
        let controller = Butter.analog.module(for: .all)
        present(controller, animated: true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

