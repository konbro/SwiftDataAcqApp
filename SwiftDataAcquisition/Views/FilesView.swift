//
//  FilesView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/05/2021.
//

import UIKit

class FilesView: UIViewController, UITableViewDataSource {
    
    var files = [String] ()
    let fileHandler = CustomFilesHandler();
    var measurementGroupsList: Array<NSString> = [];

    //PART OF CODE RESPONSIBLE FOR DISPLAYING OF A TABLE
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
    
    
    
    @IBOutlet weak var ElementSwitch: UISwitch!
    
    @IBAction func ElementSwitchToggle(_ sender: UISwitch) {
        //WTF
//        fileHandler.getFilesInGroup(fileGroup: sender.)
    }
    

    
    @IBOutlet weak var ShareBtn: UIButton!
    
    
    @IBAction func ShareBtnPressed(_ sender: UIButton) {
        displayShareSheet(measurementGroup: "TEST")
    }
    /*override func numberOfSection(in tableView: UITableView)->Int
    {
        return 1;
    }*/
    override func viewDidLoad() {
        super.viewDidLoad()
        updateResultList()
        
        // Do any additional setup after loading the view.
    }
    
    private func updateResultList()
    {
        measurementGroupsList = fileHandler.listFilesGroups();
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func displayShareSheet(measurementGroup: String)
    {
        let filesURLS = fileHandler.getFilesInGroup(fileGroup: measurementGroup);
        
        var filesToShare = [Any]();
        filesToShare.append(filesURLS)
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
}
