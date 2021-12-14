//
//  ViewController.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 12/10/2021.
//

import UIKit

class MainView: UIViewController {

    var viewModel: FilesHandlerViewModel!
    
    @IBAction func handleExit(_ segue:UIStoryboardSegue)
    {
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        if segue.identifier == "measurementsSegue"
//        {
//            let destination = segue.destination as! MeasurmentsView
////            destination.viewModel = viewModel
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

