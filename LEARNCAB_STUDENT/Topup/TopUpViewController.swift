//
//  TopUpViewController.swift
//  LearnCab
//
//  Created by Exarcplus on 28/11/18.
//  Copyright © 2018 Exarcplus. All rights reserved.
//

import UIKit
import ZRScrollableTabBar
import LGSideMenuController
import ActionSheetPicker_3_0
import SVProgressHUD
import Alamofire
import Razorpay

class TopUpViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,iCarouselDelegate,iCarouselDataSource,RazorpayPaymentCompletionProtocol {
    @IBOutlet weak var chapCollectionView : UICollectionView!
    @IBOutlet weak var Tabbarview: UIView!
    @IBOutlet weak var coursenameText: UITextField!
    @IBOutlet weak var emptylab: UILabel!
    var collectionindex : Int!
    var listarr = [Dictionary<String,AnyObject>]()
    var detailarr = [Dictionary<String,AnyObject>]()
    var packagearr = [Dictionary<String,AnyObject>]()
    var dataarr = [String]()
    var idarr = [String]()
    var mainidarr = [String]()
    var course_id : String!
    var course_name : String!
    var sub_course_id : String!
    var student_id : String!
//    var Tabbar:ZRScrollableTabBar!
    var items: [Int] = []
    var tokenstr : String!
    @IBOutlet var carousel: iCarousel!
    var package_id : String!
    @IBOutlet var scrollview: UIScrollView!
    
    
    var amount : String!
    var tax : String!
    var phoneno : String!
    var email : String!
    var namestr :String!
    var detailsdic : NSDictionary!
    var razorpay : Razorpay!
    var gstamount : Double!
    var paymentid :String!
    var program_id : String!
    var errormsg : String!
    var totalamount : String!
    var colors = [UIColor]()
    override func awakeFromNib() {
        super.awakeFromNib()
        for i in 0 ... 99 {
            items.append(i)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionindex = 0
        
        colors.append(UIColor(red: 0/255, green: 64/255, blue: 128/255, alpha: 1))
        colors.append(UIColor(red: 51/255, green: 153/255, blue: 51/255, alpha: 1))
        navigationController?.navigationBar.setGradientBackground(colors: colors)
        self.navigationController?.navigationBar.isHidden = false
        
        tokenstr = UserDefaults.standard.string(forKey: "tokens")
        print(tokenstr)
        if UserDefaults.standard.value(forKey: "Logindetail") != nil{
            
            let result = UserDefaults.standard.value(forKey: "Logindetail")
            let newResult = result as! Dictionary<String,AnyObject>
            print(newResult)
            student_id = newResult["_id"] as! String
            print(student_id)
            let fname = newResult["first_name"] as! String
            let lname = newResult["last_name"] as! String
            let name = fname + " " + lname
            print(name)
            namestr = name as! String
            email = newResult["email"] as! String
            phoneno = newResult["phone_number"] as! String
        }
        
        emptylab.isHidden = true
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .coverFlow
        carousel.isPagingEnabled = true
        self.courselink()
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func backclink (_ sender: UIButton)
    {
       self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return listarr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PackageCollectionViewCell", for: indexPath) as! PackageCollectionViewCell
        cell.name.text = self.listarr[indexPath.row]["course_name"] as! String
        if indexPath.item == collectionindex
        {
            
            cell.underLine.isHidden = false
        }
        else
        {
            cell.underLine.isHidden = true
        }
        return cell;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        collectionindex = indexPath.item
        self.chapCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        self.chapCollectionView.reloadData()
        self.course_id = self.listarr[indexPath.row]["_id"] as! String
        self.droupdownlink()
    }
    
    //package carousel
    func numberOfItems(in carousel: iCarousel) -> Int {
        return packagearr.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let sponser = Bundle.main.loadNibNamed("TopUpView", owner: self, options: nil)?[0] as! TopUpView
        sponser.frame = CGRect(x: 0, y: 0, width: 280, height: 360)
        
        sponser.layer.cornerRadius = 5.0;
        sponser.layer.masksToBounds = true;
        let rupeestr = self.packagearr[index]["amount"] as! String
        if rupeestr == nil || rupeestr == ""
        {
            sponser.amountlab.text = ""
        }
        else
        {
            sponser.amountlab.text = String(format: "%@/-", rupeestr)
        }
        
        let credit =  self.packagearr[index]["no_of_credits"] as! String
        if credit == nil || credit == ""
        {
            sponser.creditlab.text = ""
        }
        else
        {
            sponser.creditlab.text = String(format: "%@ credits", credit)
        }
        
        let totalcredit =  self.packagearr[index]["no_of_credits"] as? String
        if totalcredit == nil || totalcredit == ""
        {
            sponser.totalcreditlab.text = ""
        }
        else
        {
            sponser.totalcreditlab.text = String(format: "Access to extra %@ Lectures this month", totalcredit!)
        }
        
        sponser.packagelab.text = self.packagearr[index]["title"] as! String
        let packagestatus =  self.packagearr[index]["status"] as! String
        print(packagestatus)
        if packagestatus == "0"
        {
            sponser.getpackage.isHidden = true
        }
        else{
            sponser.getpackage.isHidden = false
        }
       
        return sponser;
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
    
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int)
    {
        let packagestatus = self.packagearr[index]["status"] as! String
        print(packagearr)
        print(packagestatus)
        if packagestatus == "0"
        {
        }else{
            let mainview = kmainStoryboard.instantiateViewController(withIdentifier: "RazorpayViewController") as! RazorpayViewController
            mainview.amount = self.packagearr[index]["amount"] as? String
            mainview.tax = self.packagearr[index]["tax"] as? String
            mainview.package_id = self.packagearr[index]["_id"] as? String
            mainview.courseid = self.course_id
            mainview.sub_courseid = self.sub_course_id
            mainview.packagetitle = self.packagearr[index]["title"] as? String
            mainview.titlestr = "Topup"
            self.present(mainview, animated:true, completion: nil)
        }
    }
    
    @objc func getpackagebutton(sender:UIButton!)
    {
        
        let myAlert = UIAlertController(title:"LearnCab", message: "Already registered using Email ID", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
        return
        
        
    }
    
    //Droupdown button function
    @IBAction func paper_clicked(_ sender: UIButton)
    {
        ActionSheetStringPicker.show(withTitle: "select the level", rows: dataarr , initialSelection: 0,doneBlock: {
            picker, value, index in
            
            print("value = \(value)")
            print("index = \(String(describing: index))")
            print("picker = \(String(describing: picker))")
            self.coursenameText.text = index as? String
            let index = self.dataarr.index(of: self.coursenameText.text!)
            self.sub_course_id = self.idarr[index!] as! String
            print(self.sub_course_id)
            self.course_id = self.mainidarr[index!] as! String
            print(self.course_id)
            
            self.packagelink()
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //main course link
    func courselink()
    {
        let params:[String:String] = ["token":tokenstr]
        SVProgressHUD.show()
        let kLurl = "\(kBaseURL)student_get_courseName"
        Alamofire.request(kLurl, method: .get, parameters: params).responseJSON { response in
            
            print(response)
            
            let result = response.result
            print(response)
            if let dat = result.value as? Dictionary<String,AnyObject>{
                if let list = dat["data"] as? [Dictionary<String,AnyObject>]{
                    self.listarr = list
                    print(self.listarr)
                    if self.listarr.count != 0
                    {
                        self.course_id = self.listarr[0]["_id"] as! String
                        self.chapCollectionView.reloadData()
                        self.droupdownlink()
                    }
                }
            }
            SVProgressHUD.dismiss()
            
        }
    }
    
    
    //droupdown link
    func droupdownlink()
    {
        let params:[String:String] = ["token":tokenstr]
        SVProgressHUD.show()
        let kLurl = "\(kBaseURL)course_levels/"
        Alamofire.request(kLurl+course_id+"/", method: .get, parameters: params).responseJSON { response in
            
            print(response)
            
            let result = response.result
            print(response)
            if let dat = result.value as? Dictionary<String,AnyObject>{
                if let list = dat["data"] as? [Dictionary<String,AnyObject>]{
                    self.detailarr = list
                    print(self.detailarr)
                    self.dataarr.removeAll()
                    self.idarr.removeAll()
                    self.mainidarr.removeAll()
                    self.coursenameText.text = self.detailarr[0]["course_name"] as! String
                    self.sub_course_id = self.detailarr[0]["course_id"] as! String
                    for c in 0 ..< self.detailarr.count
                    {
                        
                        let course = self.detailarr[c]["course_name"] as! String
                        self.dataarr.append(course)
                        let idstr = self.detailarr[c]["course_id"] as! String
                        self.idarr.append(idstr)
                        print(self.idarr)
                        let main_id =  self.detailarr[c]["main_course_id"] as! String
                        self.mainidarr.append(main_id)
                        print(self.mainidarr)
                    }
                    self.packagelink()
                }
            }
            SVProgressHUD.dismiss()
        }
    }
    
    //packages list link
    func packagelink()
    {
        let params:[String:String] = ["token":tokenstr]
        SVProgressHUD.show()
        let kLurl = "\(kBaseURL)student_package_topups/"
        let str = student_id+"&token="+tokenstr
        Alamofire.request(kLurl+course_id+"/?student_id="+str, method: .get, parameters: nil).responseJSON { response in
            print(response)
            
            let result = response.result
            print(response)
            
            if let dat = result.value as? Dictionary<String,AnyObject>{
                self.packagearr.removeAll()
                if let list = dat["data"] as? [Dictionary<String,AnyObject>]{
                    self.packagearr = list
                    print(self.packagearr)
                    
                    if self.packagearr.count != 0
                    {
                        self.carousel.reloadData()
                        self.emptylab.isHidden = true
                    }
                    else
                    {
                        self.emptylab.isHidden = false
                        self.carousel.reloadData()
                    }
                }
            }
            SVProgressHUD.dismiss()
            
        }
    }
    
    //Razorpay Payment
    func paylink()
    {
        let res : Double = (Double(amount)! / 100.0) * Double(tax)!
        print(res)
        let total : Double = Double(amount)! + res
        print(total)
        let totalAmount : Double = total * 100.0
        print(totalAmount)
        totalamount = String(totalAmount)
        gstamount = totalAmount
        razorpay = Razorpay.initWithKey("rzp_test_Sa6VEeEdzgl45e", andDelegate: self)
        self.showPaymentForm()
    }
    
    func showPaymentForm() {
        let options = [
            "amount" : gstamount,
            "name" : namestr,
            "prefill" : [
                "email" : email,
                "contact" : phoneno
            ],
            "theme": [
                "color": "#339933"
            ]
            ] as [String : Any]
        razorpay.open(options)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        UIAlertView.init(title: "Payment Successful", message: payment_id, delegate: self, cancelButtonTitle: "OK").show()
        paymentid = payment_id
        self.paymentUpdatelink()
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        UIAlertView.init(title: "Error", message: str, delegate: self, cancelButtonTitle: "OK").show()
        errormsg = str
    }
    
    
    func paymentUpdatelink()
    {
        print(tokenstr)
        print(paymentid)
        print(course_id)
        print(sub_course_id)
        print(totalamount)
        print(student_id)
        print(package_id)
        
        let params:[String:String] = ["payment_id":paymentid,"course_id":course_id,"course_level_id":self.sub_course_id,"package_id":package_id,"amount":totalamount,"student_id":student_id]
        SVProgressHUD.show()
        let kLurl = "\(kBaseURL)store_student_package/?token="
        Alamofire.request(kLurl+tokenstr+"", method: .post, parameters: params).responseJSON { response in
            
            print(response)
            
            let result = response.result
            print(response)
            if let dat = result.value as? Dictionary<String,AnyObject>{
                let res = dat["result"] as! String
                if res == "success"
                {
                    
                }
            }
            SVProgressHUD.dismiss()
            
        }
    }
    
}
