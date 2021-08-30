//
//  FilesView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/05/2021.
//

import UIKit

class FilesView: UIViewController, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measurementGroupsList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as UITableViewCell;
        cell.textLabel?.text = measurementGroupsList[indexPath.row] as String;
        return cell;
    }
    

    @IBOutlet weak var fileTable: UITableView!
    {
        didSet{
            fileTable.dataSource = self;
        }
    }
    
    var files = [String] ()
    var newFile: String = ""
    let fileHandler = CustomFilesHandler();
    var measurementGroupsList: Array<NSString> = [];
//    var filesList = fileHandler.listFilesGroups();
    
    
    /*override func numberOfSection(in tableView: UITableView)->Int
    {
        return 1;
    }*/
    override func viewDidLoad() {
        super.viewDidLoad()
        updateResultList()
        
        //var filesList = ["2021-05-20_10-23-25_Measurement_A.txt","2021-05-20_10-30-25_Measurement_A.txt","2021-05-20_10-50-25_Measurement_A.txt","2021-05-20_11-23-25_Measurement_A.txt"];
        
        // Do any additional setup after loading the view.
    }
    
    private func updateResultList()
    {
//        measurementGroupsList = fileHandler.listFilesGroups();
        measurementGroupsList = ["test1", "test2", "test3"];
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
