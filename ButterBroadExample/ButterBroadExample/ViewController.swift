//
//  ViewController.swift
//  AnalogBroadExample
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import ButterBroad

final class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        navigationItem.title = "Butterbroad"
    }

    @IBAction func logButtonPressed(_ sender: Any) {
        if let text = textField.text, text.isEmpty == false {
            Butter.common.log(.init(name: text))
            textField.text = ""
        }
    }

    @IBAction func showCurrentSessionEventsPressed(_ sender: Any) {
//        let controller = Butter.analog.logger.currentEventsModule()
//        present(controller, animated: true)
    }

    @IBAction func showAllSessionsButtonPressed(_ sender: Any) {
//        let controller = Butter.analog.logger.sessionsModule()
//        present(controller, animated: true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
