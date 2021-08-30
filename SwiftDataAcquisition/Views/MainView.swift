//
//  ViewController.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 12/05/2021.
//

import UIKit

class MainView: UIViewController {

    var viewModel: FilesHandlerViewModel!
    
    @IBAction func handleExit(_ segue:UIStoryboardSegue)
    {
        
    }
    
    //TODO figure out how to present each measurement which consist of 4 files.
    //display in files view only done measurements which will be identified by date?
    //or presenting them as a individual files: problem when user shares them not in order or wrong group of files i.e. X1,X2,Y3,Y2
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "measurementsSegue"
        {
            let destination = segue.destination as! MeasurmentsView
            destination.viewModel = viewModel
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

