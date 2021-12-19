//
//  ChartsViewController.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 25/10/2021.
//

import UIKit
import Charts

class ChartsViewController: UIViewController {

    
    var maxLimit = ChartLimitLine(limit: 255, label: "Max error")
    
    var minLimit = ChartLimitLine(limit:0, label: "Min error");
    
    var barchartXaxis: Array<UInt8>=[];
    
    var barchartYaxis: Array<UInt16>=[];
    
//    var barchartDataSet: BarChartDataSet!;
    var barchartDataSet = BarChartDataSet(entries: [], label: "")
    
    
    
    @IBOutlet weak var barChart: BarChartView!

    @IBOutlet weak var minThresholdVal: UISlider!
        
    @IBOutlet weak var maxThresholdVal: UISlider!
    
    @IBAction func maxValChanged(_ sender: UISlider) {
        print("VALUE: \(sender.value) ROUNDED: \(sender.value.rounded())")
        maxLimit = ChartLimitLine(limit: Double(sender.value.rounded()), label: "Max error")
        barChartUpdateLimits()
    }
    
    @IBAction func minValChanged(_ sender: UISlider) {
        print("VALUE: \(sender.value) ROUNDED: \(sender.value.rounded())")
        minLimit = ChartLimitLine(limit: Double(sender.value.rounded()), label: "Min error")
        barChartUpdateLimits()
    }
    
    private func populateDataSet()
    {
        for i in barchartXaxis
        {
            barchartDataSet.append(BarChartDataEntry(x: Double(i), y: Double(barchartYaxis[Int(i)])))
        }
//        barchartDataSet.label = "test data";
    }
    
    
    
    func barChartUpdate()
    {
//        let entry1 = BarChartDataEntry(x: 1.0, y: 55.5)
//        let entry2 = BarChartDataEntry(x: 2.0, y: 200.0)
//        let entry3 = BarChartDataEntry(x: 3.0, y: 256.5)
//
//        let dataSet = BarChartDataSet(entries: [entry1,entry2,entry3], label: "Example data in bar chart")
//        let data = BarChartData(dataSets: [dataSet])
        populateDataSet();
        let data = BarChartData(dataSets: [barchartDataSet])
        
        
        barChart.data = data
//        barChartUpdateLimits()

    }
    func barChartUpdateLimits()
    {
        barChart.rightAxis.removeAllLimitLines();
        barChart.rightAxis.addLimitLine(maxLimit)
        
        barChart.leftAxis.removeAllLimitLines();
        barChart.leftAxis.addLimitLine(minLimit)
        barChartUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maxThresholdVal.value = 65535;
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
