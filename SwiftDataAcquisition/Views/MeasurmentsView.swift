//
//  MeasurmentsView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/05/2021.
//

import UIKit

class MeasurmentsView: UIViewController {

    var viewModel: FilesHandlerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /* NOTE
     THIS IS A TEMPORARY LOCATION OF THIS METHOD IN ORDERT TO SHOW THAT FILES CREATION WORKS
     */
    
    @IBAction func startMeasurements(_ sender: Any)
    {
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd_hh-mm-ss"
        let now = date.string(from: Date())
        let fileName = now + "_Measurement_" + "A"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        print("FilePath: \(fileURL.path)")
        
        let fileTemporaryContent = "Lorem ipsume etcetera etiam eget nunc non nisl tincidunt fermentum. Phasellus congue."
        
        do {
            try fileTemporaryContent.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let error as NSError
        {
            print("Failed to write to file to URL: \(fileURL), Error: " + error.localizedDescription)
        }
        
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
