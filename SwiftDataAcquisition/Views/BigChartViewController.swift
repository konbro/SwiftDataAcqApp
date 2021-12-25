//
//  BigChartView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 23/12/2021.
//

import UIKit
import Charts

class BigChartViewController: UIViewController {

    @IBOutlet weak var bigChart: BarChartView!
    
    // values presented on chart
    public var chartXAxisValues: Array<UInt8>=[];
    public var chartYAxisValues: Array<UInt16>=[];
    public var maxValueLimit: ChartLimitLine!;
    public var minValueLimit: ChartLimitLine!;
    
    private var chartDataSet = BarChartDataSet(entries: [], label: "");
    

    
    override var shouldAutorotate: Bool {
        return false;
    }
    
    private func fillDataSet()
    {
        for entry in chartXAxisValues
        {
            chartDataSet.append(BarChartDataEntry(x: Double(entry), y: Double(chartYAxisValues[Int(entry)])));
        }
    }
    
    private func populateChart()
    {
        fillDataSet()
        let chartData = BarChartData(dataSets: [chartDataSet])
        bigChart.dragXEnabled = true;
        bigChart.dragYEnabled = true;
        bigChart.dragEnabled = true;
        bigChart.legend.drawInside = false;
        bigChart.leftAxis.addLimitLine(minValueLimit)
        bigChart.leftAxis.addLimitLine(maxValueLimit)
        bigChart.data = chartData;
//        bigChart
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateChart();
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

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
