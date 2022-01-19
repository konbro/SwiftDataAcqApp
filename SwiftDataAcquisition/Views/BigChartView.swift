//
//  BigChartView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 23/12/2021.
//

import UIKit
import Charts

class BigChartView: UIViewController {

    @IBOutlet weak var bigChart: BarChartView!
    
    // values presented on chart
    public var chartXAxisValues: Array<Int>=[];
    public var chartYAxisData: Array<UInt16>=[];
    var dataHandler: MeasurementDataModel!;
    public var maxValueLimit: ChartLimitLine!;
    public var minValueLimit: ChartLimitLine!;
    
    var chartUpdateTimer = Timer();
    
    private var chartDataSet = BarChartDataSet(entries: [], label: "");
    
    private func startTimer()
    {
        self.chartUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)
    }
        
    @objc func incrementTimer()
    {
        self.chartYAxisData.removeAll();
        self.chartYAxisData.append(contentsOf: dataHandler.getLastFrame());
        self.barChartUpdate();
    }
    
    override var shouldAutorotate: Bool {
        return false;
    }
    
    private func populateDataSet()
    {
        for entry in chartXAxisValues
        {
            chartDataSet.append(BarChartDataEntry(x: Double(entry), y: Double(chartYAxisData[Int(entry)])));
        }
    }
    
    func barChartUpdate()
    {
        populateDataSet();
        let data = BarChartData(dataSets: [chartDataSet])
        bigChart.data = data

    }
    
    private func populateChart()
    {
        populateDataSet()
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
