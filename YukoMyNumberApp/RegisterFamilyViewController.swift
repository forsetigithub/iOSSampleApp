//
//  RegisterFamilyViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/09.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import RealmSwift

class RegisterFamilyViewController : UITableViewController,UITextFieldDelegate,
                                    UIPickerViewDelegate {
  
  fileprivate let realm = try! Realm()
  fileprivate let Properties = YukoMyNumberAppProperties.sharedInstance

  fileprivate var employeeeditdata:EmployeeData = EmployeeData()
  
  var EmployeeEditData:EmployeeData {
    set(newValue){
      employeeeditdata = newValue
    }
    get{
      return employeeeditdata
    }
  }
  
  @IBOutlet weak var FamilyNameTextField: UITextField!
  @IBOutlet weak var FirstNameTextField: UITextField!
  @IBOutlet weak var RelationName: UILabel!
  @IBOutlet weak var RelationPickerCell: UITableViewCell!
  @IBOutlet weak var RelationPickerView: UIPickerView!
  @IBOutlet weak var RegisterButton: UIButton!
  
  
  fileprivate let RelationPicker:RelationPickerViewController = RelationPickerViewController()
  
  // MARK: - Table View
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    self.FamilyNameTextField.delegate = self
    self.FirstNameTextField.delegate = self
    self.RelationPickerView.delegate = RelationPicker
    
    self.navigationItem.title = Properties.NavigationTitles["RegisterFamilyViewController"]
    self.FamilyNameTextField.placeholder = Properties.LabelItems["FamilyName"]
    self.FirstNameTextField.placeholder = Properties.LabelItems["FirstName"]
    
    RelationPicker.selectedRSCode = RelationPicker.pickerKeys[0]
    self.RelationName.text = RelationPicker.selectedRSName
    
    self.RegisterButton.addTarget(self, action: #selector(RegisterFamilyViewController.tapRegisterButton(_:)), for: UIControl.Event.touchUpInside)
    self.RegisterButton.setTitle(Properties.ButtonTitles["Register"], for: UIControl.State())
    
    NotificationCenter.default.addObserver(self, selector: #selector(RegisterFamilyViewController.updatePickerValue(_:)), name: NSNotification.Name(rawValue: "updatePickerNotification"), object: nil)

  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isToolbarHidden = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.FamilyNameTextField.becomeFirstResponder()
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    var height:CGFloat = YukoMyNumberAppProperties.sharedInstance.TableViewCellDefaultHeight
    if(indexPath.row == 3){
      height =  150
    }
    
    return height
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    let str = textField.text! + string
    
    switch (textField.tag) {
      case 1,2:
        if(str.characters.count > YukoMyNumberAppProperties.sharedInstance.EmployeeNameCharactersCount){
          return false
        }
        break
      default:
        break
    }
    
    return true
  }
  
  
  @IBAction func tapRegisterButton(_ sender: AnyObject) {
    
    var alertProp:[String:String] = [String:String]()
    
    //必須項目チェック
    if(self.FamilyNameTextField.text?.replacingOccurrences(of: " ", with: "").isEmpty == true ||
      self.FirstNameTextField.text?.replacingOccurrences(of: " ", with: "").isEmpty == true ||
      self.RelationName.text == RelationPicker.pickerValues[0]){
        
        alertProp = Properties.AlertMessages["RequiredItemValidError"] as! [String:String]
        
        let myAlert = UIAlertController(title: alertProp["Title"], message: alertProp["Message"], preferredStyle: UIAlertController.Style.alert)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: { (action:UIAlertAction) -> Void in
          
        })
        
        myAlert.addAction(OKAction)
        
        present(myAlert, animated: true, completion: nil)
        
        return
    }
    
    //続柄重複エラーチェック
    let rscodecheck = realm.objects(EmployeeData.self).filter("EmployeeCode = '\(self.EmployeeEditData.EmployeeCode)' and RSCode = '\(RelationPicker.selectedRSCode)'")
    
    if(rscodecheck.count != 0){
      
      alertProp = Properties.AlertMessages["DoubleCheckError"] as! [String:String]
      
      let myAlert = UIAlertController(title: alertProp["Title"], message: "「\(self.RelationName.text!)」は\(alertProp["Message"]!)", preferredStyle: UIAlertController.Style.alert)
      
      let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: { (action:UIAlertAction) -> Void in
        
      })
      
      myAlert.addAction(OKAction)
      
      present(myAlert, animated: true, completion: nil)
    
      return
      
    }
  
    try! realm.write({ () -> Void in
      let family = EmployeeData()
      family.FamilyName = self.FamilyNameTextField.text!
      family.FirstName = self.FirstNameTextField.text!
      family.RSCode = RelationPicker.selectedRSCode
      family.EmployeeCode = employeeeditdata.EmployeeCode
      family.JoinedDate = employeeeditdata.JoinedDate
      
      family.FamilySeqNo = (realm.objects(EmployeeData.self).filter("EmployeeCode = '\(family.EmployeeCode)'").sorted(byKeyPath: "FamilySeqNo",
        ascending: true).first?.FamilySeqNo)! + 1
            
      realm.add(family)
      
      self.navigationController?.popViewController(animated: true)
      
    })
    
  }

  @objc func updatePickerValue(_ notification:Foundation.Notification?){
    if((notification?.name as AnyObject) as! String == "updatePickerNotification"){
      self.RelationName.text = RelationPicker.pickerValues[RelationPicker.selectedPickerRow]
    }
  }
}
