//
//  MeasurmentsView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/05/2021.
//

import UIKit

class MeasurmentsView: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let filesHandler = CustomFilesHandler();
    var viewModel: FilesHandlerViewModel!
    var pathToDocumentsDir: String = "";
    let userDefaults = UserDefaults.standard;

    
    @IBAction func handleExitMeasurements(_ segue:UIStoryboardSegue)
    {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startMeasurements(_ sender: Any)
    {
        let now = getCurrentTime();
        //DO MEASURING MAGIC
        
        //GET DATA HERE
        
        //END MEASURING MAGIC
        
        //ALSO BY THE USE OF MAGIC SOMEHOW DISPLAY THIS DATA ON A CHART
        filesHandler.saveDataBatch(dataToSave: "LoremIpsumPLACEHOLDER", timeOfMeasurement: now);
        
        
    }
    

    /**
     This method gets time when called
     
     - Returns: A new string with time of call
     */
    private func getCurrentTime() -> String
    {
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd_hh-mm-ss"
        return date.string(from: Date())
    }
     
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
