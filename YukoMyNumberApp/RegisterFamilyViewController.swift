//
//  RegisterFamilyViewController.swift
//  YukoMyNumberApp
//
//  Created by 木村正徳 on 2016/01/09.
//  Copyright © 2016年 yukobex. All rights reserved.
//

import Foundation
import RealmSwift

class RegisterFamilyViewController : UITableViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
  
  let realm = try! Realm()

  // MARK: - Table View

  private var eployeeeditdata:EmployeeData = EmployeeData()
  
  var EmployeeEditData:EmployeeData {
    set(newValue){
      eployeeeditdata = newValue
    }
    get{
      return eployeeeditdata
    }
  }
  
  @IBOutlet weak var FamilyNameTextField: UITextField!
  @IBOutlet weak var FirstNameTextField: UITextField!
  
  @IBOutlet weak var RelationNamesPickerView: UIPickerView!

  @IBOutlet weak var RelationName: UILabel!
  
  private let pickerItems:[String:String] = YukoMyNumberAppProperties.sharedInstance.RelationItems
  
  /*
    ["続柄を選択":"-1",
      "夫":"01",
      "妻":"02",
      "長男":"11",
      "次男":"12",
      "三男":"13",
      "四男":"14",
      "五男":"15",
      "六男":"16",
      "七男":"17",
      "八男":"18",
      "九男":"19",
      "長女":"21",
      "次女":"22",
      "三女":"23",
      "四女":"24",
      "五女":"25",
      "六女":"26",
      "七女":"27",
      "八女":"28",
      "九女":"29",
      "父":"31",
      "母":"32",
      "義父":"33",
      "義母":"34",
      "兄":"41",
      "弟":"42",
      "姉妹の配偶者":"43",
      "配偶者の兄弟":"44",
      "その他の兄弟":"45",
      "兄弟":"46",
      "姉":"51",
      "妹":"52",
      "兄弟の配偶者":"53",
      "配偶者の姉妹":"54",
      "その他の姉妹":"55",
      "姉妹":"56",
      "祖父":"61",
      "祖母":"62",
      "義祖父":"65",
      "義祖母":"66",
      "孫":"71",
      "おじ":"74",
      "おば":"75",
      "おい":"76",
      "めい":"77",
      "曽祖父母":"81",
      "養子（男）":"91",
      "養子（女）":"92",
      "子（女）の夫":"93",
      "子（男）の妻":"94",
      "その他の子（女）":"96",
      "その他":"97"]
*/
  var pickerKeys:[String] = [String]()
  var pickerValues:[String] = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    self.RelationNamesPickerView.delegate = self
    self.RelationName.text = "続柄"
    
    self.FamilyNameTextField.delegate = self
    self.FirstNameTextField.delegate = self
    
    pickerKeys = Array(pickerItems.values).sort()
    
    for pikcerkey in pickerKeys {
      for (key,val) in pickerItems{
        if(pikcerkey == val){
           pickerValues.append(key)
        }
      }
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {

  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height:CGFloat = 44
    if(indexPath.row == 3){
      height =  150
    }
    
    return height
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  //MARK: UIPickerView
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerItems.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
    return pickerValues[row] as String
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    if(row != 0){
      self.RelationName.text = pickerValues[row]
    }
    
  }
  
  @IBAction func tapSaveButton(sender: UIBarButtonItem) {
    
    try! realm.write({ () -> Void in
      let family = EmployeeFamilyData()
      family.Name = self.FamilyNameTextField.text! + "　" + self.FirstNameTextField.text!
      family.RSName = self.RelationName.text!
      family.RSCode = self.pickerItems[self.RelationName.text!]!
      eployeeeditdata.families.append(family)
      
      self.navigationController?.popViewControllerAnimated(true)
      
    })
  }
  
  
}