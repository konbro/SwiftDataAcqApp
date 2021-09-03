//
//  FilesView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/05/2021.
//

import UIKit

class FilesView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var files = [String] ()
    let fileHandler = CustomFilesHandler();
    var measurementGroupsList: Array<NSString> = [];
    var selectedIdsList: Set<Int> = [];
    
    
    //PART OF CODE RESPONSIBLE FOR DISPLAYING OF A TABLE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measurementGroupsList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as UITableViewCell;
        
        cell.textLabel?.text = measurementGroupsList[indexPath.row] as String;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!selectedIdsList.contains(indexPath.row))
        {
            selectedIdsList.insert(indexPath.row)
        }
        let selectedMeasurementGroup = measurementGroupsList[indexPath.row]
        print("Selected row at index \(indexPath.row)")
        print(selectedMeasurementGroup)
        print(selectedIdsList)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(selectedIdsList.contains(indexPath.row))
        {
            selectedIdsList.remove(indexPath.row)
        }
        
        let selectedMeasurementGroup = measurementGroupsList[indexPath.row]
        print("Deselected row at index \(indexPath.row)")
        print(selectedMeasurementGroup)
        print(selectedIdsList)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        print("Deleted")
        fileHandler.deleteFilesInGroup(fileGroup: measurementGroupsList[indexPath.row] as String);
        measurementGroupsList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
      }
    }
    
    
    @IBOutlet weak var fileTable: UITableView!
    {
        didSet{
            fileTable.dataSource = self;
            fileTable.allowsMultipleSelection = true;
        }
    }
    
    
    @IBOutlet weak var DeleteBtn: UIButton!
    
    @IBAction func DeleteBtnPressed(_ sender: UIButton) {
        
        var deletedMeasurementGroups = [String]();
        var rowsToBeDeleted = [IndexPath]();
        for id in selectedIdsList
        {
            deletedMeasurementGroups.append(measurementGroupsList[id] as String);
            rowsToBeDeleted.append(IndexPath(row: id, section: 0));
            measurementGroupsList.remove(at: id)
        }
        
        for mGroup in deletedMeasurementGroups{
            fileHandler.deleteFilesInGroup(fileGroup: mGroup)
        }
        selectedIdsList.removeAll();
        fileTable.deleteRows(at: rowsToBeDeleted, with: .automatic);
        updateResultList()
        
    }
    
    @IBOutlet weak var ShareBtn: UIButton!
    
    
    @IBAction func ShareBtnPressed(_ sender: UIButton) {
        var sharedMeasurementGroups = [String]();
        for id in selectedIdsList
        {
            sharedMeasurementGroups.append(measurementGroupsList[id] as String);
        }
        displayShareSheet(measurementGroups: sharedMeasurementGroups);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateResultList()
        self.fileTable.delegate = self;
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

    private func displayShareSheet(measurementGroups: Array<String>)
    {
        var filesToShare = [Any]();
        for measurementGroup in measurementGroups{
            let filesURLS = fileHandler.getFilesInGroup(fileGroup: measurementGroup);
            filesToShare.append(filesURLS)
        }
        print("Shared files:")
        print(filesToShare);
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
}
