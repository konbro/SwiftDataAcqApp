//
//  ViewController.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 12/05/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func handleExit(_ segue:UIStoryboardSegue)
    {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "measurementsSegue"
        {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

