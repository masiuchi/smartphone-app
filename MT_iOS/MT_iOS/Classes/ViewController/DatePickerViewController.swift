//
//  DatePickerViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/02.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate {
    func datePickerDone(_ controller: DatePickerViewController, date: Date)
}

class DatePickerViewController: BaseViewController {
    enum DateTimeMode: Int {
        case date = 0,
        time,
        dateTime
    }
    
    var date: Date = Date()
    var delegate: DatePickerViewControllerDelegate?
    var initialMode: DateTimeMode = DateTimeMode.dateTime
    var navTitle = NSLocalizedString("Date", comment: "Date")
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var dateTimeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var setNowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = Color.tableBg
        
        self.title = navTitle
        
        dateTimeSegmentedControl.setTitle(NSLocalizedString("Date", comment: "Date"), forSegmentAt: 0)
        dateTimeSegmentedControl.setTitle(NSLocalizedString("Time", comment: "Time"), forSegmentAt: 1)
        
        setNowButton.setTitle(NSLocalizedString("Set now", comment: "Set now"), for: UIControlState())
        
        datePicker.date = date
        
        self.dateChanged()

        switch initialMode {
        case .date:
            dateTimeSegmentedControl.setEnabled(true, forSegmentAt: DateTimeMode.date.rawValue)
            dateTimeSegmentedControl.setEnabled(false, forSegmentAt: DateTimeMode.time.rawValue)
            dateTimeSegmentedControl.selectedSegmentIndex = DateTimeMode.date.rawValue
        case .time:
            dateTimeSegmentedControl.setEnabled(false, forSegmentAt: DateTimeMode.date.rawValue)
            dateTimeSegmentedControl.setEnabled(true, forSegmentAt: DateTimeMode.time.rawValue)
            dateTimeSegmentedControl.selectedSegmentIndex = DateTimeMode.time.rawValue
        case .dateTime:
            dateTimeSegmentedControl.setEnabled(true, forSegmentAt: DateTimeMode.date.rawValue)
            dateTimeSegmentedControl.setEnabled(true, forSegmentAt: DateTimeMode.time.rawValue)
            dateTimeSegmentedControl.selectedSegmentIndex = DateTimeMode.date.rawValue
        }
        
        self.segmentValueChanged(dateTimeSegmentedControl)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(DatePickerViewController.doneButtonPushed(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_arw"), left: true, target: self, action: #selector(DatePickerViewController.backButtonPushed(_:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    fileprivate func dateChanged() {
        switch initialMode {
        case .date:
            dateTimeLabel.text = Utils.mediumDateStringFromDate(datePicker.date)
        case .time:
            dateTimeLabel.text = Utils.timeStringFromDate(datePicker.date)
        case .dateTime:
            dateTimeLabel.text = Utils.mediumDateTimeFromDate(datePicker.date)
        }
    }

    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case DateTimeMode.date.rawValue:
            datePicker.datePickerMode = UIDatePickerMode.date
        case DateTimeMode.time.rawValue:
            datePicker.datePickerMode = UIDatePickerMode.time
        default:
            break
        }
    }
    
    @IBAction func setNowButtonPushed(_ sender: AnyObject) {
        datePicker.date = Date()
        self.dateChanged()
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        self.dateChanged()
    }
    
    @IBAction func doneButtonPushed(_ sender: AnyObject) {
        self.delegate?.datePickerDone(self, date: datePicker.date)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonPushed(_ sender: UIBarButtonItem) {
        if date == datePicker.date {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        Utils.confrimSave(self)
    }
}
