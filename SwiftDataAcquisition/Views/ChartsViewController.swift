//
//  ChartsViewController.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 25/05/2021.
//

import UIKit
import Charts

class ChartsViewController: UIViewController {


    @IBOutlet weak var barChart: BarChartView!

    func barChartUpdate()
    {
        let entry1 = BarChartDataEntry(x: 1.0, y: 2.5)
        let entry2 = BarChartDataEntry(x: 2.0, y: 2.5)
        let entry3 = BarChartDataEntry(x: 3.0, y: 2.5)
        
        let dataSet = BarChartDataSet(entries: [entry1,entry2,entry3], label: "Example data in bar chart")
        let data = BarChartData(dataSets: [dataSet])
        
        barChart.data = data
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barChartUpdate()

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
