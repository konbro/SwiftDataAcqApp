//
//  FilesView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/05/2021.
//

import UIKit

class FilesView: UIViewController {

    @IBOutlet weak var fileTable: UITableView!
    
    var files = [String] ()
    var newFile: String = ""
    /*override func numberOfSection(in tableView: UITableView)->Int
    {
        return 1;
    }*/
    override func viewDidLoad() {
        super.viewDidLoad()

        //var filesList = ["2021-05-20_10-23-25_Measurement_A.txt","2021-05-20_10-30-25_Measurement_A.txt","2021-05-20_10-50-25_Measurement_A.txt","2021-05-20_11-23-25_Measurement_A.txt"];
        
        // Do any additional setup after loading the view.
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
