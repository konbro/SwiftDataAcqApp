//
//  ChartsViewController.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 25/10/2021.
//

import UIKit
import Charts

class ChartsView: UIViewController {

    
    var maxLimit = ChartLimitLine(limit: 255, label: "Max error")
    
    var minLimit = ChartLimitLine(limit:0, label: "Min error");
    
    var barchartXAxisData: Array<Int>=[];
    
    var barchartYAxisData: Array<UInt16>=[];
    
    var dataHandler: MeasurementDataModel!;
    
    var chartUpdateTimer = Timer();
    
//    var barchartDataSet: BarChartDataSet!;
    var barchartDataSet = BarChartDataSet(entries: [], label: "")
    
    @IBOutlet weak var barChart: BarChartView!

    @IBOutlet weak var minThresholdVal: UISlider!
        
    @IBOutlet weak var maxThresholdVal: UISlider!

    @IBOutlet weak var minValueTextField: UITextField!
    
    @IBOutlet weak var maxValueTextField: UITextField!
    
    private func startTimer()
    {
        self.chartUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)
    }
        
    @objc func incrementTimer()
    {
        self.barchartYAxisData.removeAll();
        self.barchartYAxisData.append(contentsOf: dataHandler.getLastFrame());
        self.barChartUpdate();
    }
    
    @IBAction func maxValTextFieldValueEntered(_ sender: UITextField) {
        let senderValue = sender.text;
        if !(senderValue?.isEmpty ?? true)
        {
            maxLimit = ChartLimitLine(limit: Double(senderValue!)!, label: "Max error");
            maxThresholdVal.value = Float(senderValue!)!;
            barChartUpdateLimits();
        }
    }
    
    @IBAction func minValTextFieldValueEntered(_ sender: UITextField) {
        let senderValue = sender.text;
        if !(senderValue?.isEmpty ?? true)
        {
            minLimit = ChartLimitLine(limit: Double(senderValue!)!, label: "Min error");
            minThresholdVal.value = Float(senderValue!)!;
            barChartUpdateLimits();
        }
    }
    
    @IBAction func maxValSliderValueChanged(_ sender: UISlider) {
        let senderValue = sender.value;
        print("VALUE: \(senderValue) ROUNDED: \(senderValue.rounded())")
        maxLimit = ChartLimitLine(limit: Double(senderValue.rounded()), label: "Max error")
        maxValueTextField.text?.removeAll();
        var maxVal = String(senderValue.rounded())
        maxVal.remove(at: maxVal.index(before: maxVal.endIndex))
        maxVal.remove(at: maxVal.index(before: maxVal.endIndex))
        maxValueTextField.text? = maxVal;
        barChartUpdateLimits()
    }
    
    @IBAction func minValSliderValueChanged(_ sender: UISlider) {
        let senderValue = sender.value;
        print("VALUE: \(senderValue) ROUNDED: \(senderValue.rounded())")
        minLimit = ChartLimitLine(limit: Double(senderValue.rounded()), label: "Min error")
        minValueTextField.text?.removeAll()
        var minVal = String(senderValue.rounded());
        minVal.remove(at: minVal.index(before: minVal.endIndex))
        minVal.remove(at: minVal.index(before: minVal.endIndex))
        minValueTextField.text? = minVal;
        barChartUpdateLimits()
    }
    
    @IBAction func handleExit(_ segue:UIStoryboardSegue)
    {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "bigChartSegue"
        {
            let destination = segue.destination as! BigChartView
            destination.chartXAxisValues = barchartXAxisData;
            destination.chartYAxisData = barchartYAxisData;
            destination.maxValueLimit = maxLimit;
            destination.minValueLimit = minLimit;
        }
    }
    

    
    private func populateDataSet()
    {
        for i in barchartXAxisData
        {
            if(i<barchartYAxisData.count)
            {
                barchartDataSet.append(BarChartDataEntry(x: Double(i), y: Double(barchartYAxisData[Int(i)])))
            }
        }
    }
    
    
    
    func barChartUpdate()
    {
        populateDataSet();
        let data = BarChartData(dataSets: [barchartDataSet])
        barChart.data = data

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
        self.startTimer();
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
