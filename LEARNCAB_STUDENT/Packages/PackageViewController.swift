//
//  PackageViewController.swift
//  LearnCab
//
//  Created by Exarcplus on 16/04/18.
//  Copyright © 2018 Exarcplus. All rights reserved.
//

import UIKit
import ZRScrollableTabBar
import LGSideMenuController
import ActionSheetPicker_3_0
import SVProgressHUD
import Alamofire
import Razorpay
import KGModal

class PackageViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,ZRScrollableTabBarDelegate,iCarouselDelegate,iCarouselDataSource,RazorpayPaymentCompletionProtocol{
 
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
    var Tabbar:ZRScrollableTabBar!
    var items: [Int] = []
    var tokenstr : String!
    @IBOutlet var carousel: iCarousel!
    var package_id : String!
    var promo_codestr : String!
    var Sponsor : PromoCode!
    
    var pakage_title : String!
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
        
        let item1 = UITabBarItem.init(title:"My Course", image: UIImage.init(named:"mycourseuncolor"), tag: 1)
        item1.image = UIImage.init(named: "mycourseuncolor")?.withRenderingMode(.alwaysOriginal)
        item1.selectedImage = UIImage.init(named: "mycoursecolor")?.withRenderingMode(.alwaysOriginal)
        
        let item2 = UITabBarItem.init(title:"Lectures", image: UIImage.init(named:"lectureuncolor"), tag: 2)
        item2.image = UIImage.init(named: "lectureuncolor")?.withRenderingMode(.alwaysOriginal)
        item2.selectedImage = UIImage.init(named: "lecturecolor")?.withRenderingMode(.alwaysOriginal)
        
        let item3 = UITabBarItem.init(title:"Dashboard", image: UIImage.init(named:"dashboarduncolor"), tag: 3)
        item3.image = UIImage.init(named: "dashboarduncolor")?.withRenderingMode(.alwaysOriginal)
        item3.selectedImage = UIImage.init(named: "dashboardcolor")?.withRenderingMode(.alwaysOriginal)
        
        let item4 = UITabBarItem.init(title:"Packages", image: UIImage.init(named:"packageuncolor"), tag: 4)
        item4.image = UIImage.init(named: "packageuncolor")?.withRenderingMode(.alwaysOriginal)
        item4.selectedImage = UIImage.init(named: "packgecolor")?.withRenderingMode(.alwaysOriginal)
        
        let item5 = UITabBarItem.init(title:"Profile", image: UIImage.init(named:"profileuncolor"), tag: 5)
        item5.image = UIImage.init(named: "profileuncolor")?.withRenderingMode(.alwaysOriginal)
        item5.selectedImage = UIImage.init(named:"profilecolor")?.withRenderingMode(.alwaysOriginal)
        
        Tabbar = ZRScrollableTabBar.init(items: [item1,item2,item3,item4,item5])
        //       Tabbar.tintColor =  ("#000000")
        //Tabbar.backgroundColor = UIColor(red: 18/255, green: 98/255, blue: 151/255, alpha: 1)
//        Tabbar.tintColor = UIColor(red: 18/255, green: 98/255, blue: 151/255, alpha: 1)
        Tabbar.scrollableTabBarDelegate = self;
        Tabbar.selectItem(withTag: 4)
        Tabbar.frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.size.width, height: Tabbarview.frame.size.height);
        Tabbarview.addSubview(Tabbar)
        
       
        self.courselink()
        // Do any additional setup after loading the view.
    }
    
    func scrollableTabBar(_ tabBar: ZRScrollableTabBar!, didSelectItemWithTag tag: Int32) {
        if tag == 1
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let currentview = appDelegate.SideMenu.rootViewController as! UINavigationController
            appDelegate.SideMenu.hideLeftView(animated: true, completionHandler: nil)
            let mainview = kmainStoryboard.instantiateViewController(withIdentifier: "HomePageViewController") as! HomePageViewController
            currentview.pushViewController(mainview, animated: false)
        }
        else if tag == 2
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let currentview = appDelegate.SideMenu.rootViewController as! UINavigationController
            appDelegate.SideMenu.hideLeftView(animated: true, completionHandler: nil)
            let mainview = kmainStoryboard.instantiateViewController(withIdentifier: "LecturesListViewController") as! LecturesListViewController
            currentview.pushViewController(mainview, animated: false)
        }
        else if tag == 3
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let currentview = appDelegate.SideMenu.rootViewController as! UINavigationController
            appDelegate.SideMenu.hideLeftView(animated: true, completionHandler: nil)
            let mainview = kmainStoryboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
            currentview.pushViewController(mainview, animated: false)
        }
        else if tag == 5
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let currentview = appDelegate.SideMenu.rootViewController as! UINavigationController
            appDelegate.SideMenu.hideLeftView(animated: true, completionHandler: nil)
            let mainview = kmainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            currentview.pushViewController(mainview, animated: false)
        }
    }
    
    
    @IBAction func opensidemenu (_ sender: UIButton)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.SideMenu.showLeftView(animated: true, completionHandler: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
//        if (view == nil)
//        {
            let sponser = Bundle.main.loadNibNamed("PackageView", owner: self, options: nil)?[0] as! PackageView
            sponser.frame = CGRect(x: 0, y: 0, width: 280, height: 360)

            sponser.layer.cornerRadius = 5.0;
            sponser.layer.masksToBounds = true;
//            return sponser;
//        }
//        else
//        {
//            let sponser = view as! PackageView
            //sponser.amountlab.text = self.packagearr[index]["amount"] as? String
            let rupeestr = self.packagearr[index]["amount"] as! String
            if rupeestr == nil || rupeestr == ""
            {
                 sponser.amountlab.text = ""
            }
            else
            {
                sponser.amountlab.text = String(format: "Rs. %@/-", rupeestr)
            }
            
            let credit =  self.packagearr[index]["credits_per_month"] as! String
            if credit == nil || credit == ""
            {
                sponser.creditlab.text = ""
            }
            else
            {
                sponser.creditlab.text = String(format: "%@ credits / month", credit)
            }
            
            let totalcredit =  self.packagearr[index]["total_credits"] as? String
            if totalcredit == nil || totalcredit == ""
            {
                sponser.totalcreditlab.text = ""
            }
            else
            {
                sponser.totalcreditlab.text = String(format: "Total %@ Credits", totalcredit!)
            }
            
            sponser.packagelab.text = self.packagearr[index]["title"] as! String
            let packagestatus =  self.packagearr[index]["package_status"] as! Int
            print(packagestatus)
            if packagestatus == 1
            {
                sponser.getpackage.text = "PURCHASED"
                sponser.getpackage.textColor = UIColor.white
                sponser.getpackage.backgroundColor = UIColor.lightGray
            }
            else
            {
                sponser.getpackage.text = "GET PACKAGE"
                sponser.getpackage.textColor = UIColor.white
                sponser.getpackage.backgroundColor = UIColor(red: 18/255, green: 98/255, blue: 151/255, alpha: 1)
            }
//            sponser.totalcreditlab.text =  self.packagearr[index]["total_credits"] as? String
//            sponser.creditlab.text = self.packagearr[index]["credits_per_month"] as? String

            return sponser;
//        }
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
    
    

    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int)
    {
        let packagestatus = self.packagearr[index]["package_status"] as! Int
        print(packagearr)
        print(packagestatus)
        if packagestatus == 0
        {
            if self.packagearr[index]["promocode_status"] as! String == "Yes"{
                print(self.packagearr[index]["promocode_status"] as! String)
                Sponsor = Bundle.main.loadNibNamed("PromoCode", owner: self, options: nil)?[0] as! PromoCode
                //            sponser.layer.zPosition = 2
                Sponsor.layer.cornerRadius = 5.0
                Sponsor.layer.masksToBounds = true
                KGModal.sharedInstance().show(withContentView: Sponsor, andAnimated: true)
                KGModal.sharedInstance().tapOutsideToDismiss = true
                amount = self.packagearr[index]["amount"] as? String
                tax = self.packagearr[index]["tax"] as? String
                package_id = self.packagearr[index]["_id"] as? String
                pakage_title = self.packagearr[index]["title"] as? String
                
                Sponsor.applybtn.tag = index + 123
                Sponsor.payBtn.tag = index + 123
                Sponsor.applybtn.addTarget(self, action: #selector(PackageViewController.applybutton(sender:)), for: UIControl.Event.touchUpInside)
                Sponsor.payBtn.addTarget(self, action: #selector(PackageViewController.paybutton(sender:)), for: UIControl.Event.touchUpInside)
            }
            else{
                let mainview = kmainStoryboard.instantiateViewController(withIdentifier: "RazorpayViewController") as! RazorpayViewController
                mainview.amount = self.packagearr[index]["amount"] as? String
                mainview.tax = self.packagearr[index]["tax"] as? String
                mainview.package_id = self.packagearr[index]["_id"] as? String
                mainview.courseid = self.course_id
                mainview.sub_courseid = self.sub_course_id
                mainview.packagetitle = self.packagearr[index]["title"] as? String
                self.present(mainview, animated:true, completion: nil)
            //self.paylink()
            }
        }
        else{
            
        }
    }
    
    
    
    @objc func applybutton(sender:UIButton!)
    {
        if Sponsor.PromocodeText.text == ""{
            let myAlert = UIAlertController(title:"LearnCab", message: "Please Enter Promocode!", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
            return
        }else{
            self.promo_codestr = Sponsor.PromocodeText.text
            self.package_id = self.packagearr[sender.tag - 123]["_id"] as? String
            print(packagearr[sender.tag - 123])
            KGModal.sharedInstance().hide(animated: true)
            self.promoUpdatelink()
        }
        
    }
    @objc func paybutton(sender:UIButton!)
    {
        KGModal.sharedInstance().hide(animated: true)
        let mainview = kmainStoryboard.instantiateViewController(withIdentifier: "RazorpayViewController") as! RazorpayViewController
        mainview.amount = self.packagearr[sender.tag - 123]["amount"] as? String
        mainview.tax = self.packagearr[sender.tag - 123]["tax"] as? String
        mainview.package_id = self.packagearr[sender.tag - 123]["_id"] as? String
        mainview.courseid = self.course_id
        mainview.sub_courseid = self.sub_course_id
        mainview.packagetitle = self.packagearr[sender.tag - 123]["title"] as? String
        self.present(mainview, animated:true, completion: nil)
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
//        self.course_id = UserDefaults.standard.string(forKey: "course_id")
//        print(self.course_id)
        //let params:[String:String] = [ ]
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
         let kLurl = "\(kBaseURL)retrieve_student_packages/"
        Alamofire.request(kLurl+student_id+"/"+course_id+"/", method: .get, parameters: params).responseJSON { response in
            
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
//                        self.collectionview.reloadData()
//                        self.droupdownlink()
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
        //let img = UIImage.init(named: "studenticon.png")
        let options = [
            "amount" : gstamount,
            "name" : namestr,
            //"image" : img,
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
       
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        UIAlertView.init(title: "Error", message: str, delegate: self, cancelButtonTitle: "OK").show()
        errormsg = str
        //self.errorlink()
    }
    
    
    func promoUpdatelink()
    {
        print(package_id)
        print(promo_codestr)
       
        SVProgressHUD.show()
        let kLurl = "\(kBaseURL)check_promocode/"+promo_codestr+"/"+package_id
        let str = "/?token="+tokenstr+"&student_id="+student_id
        Alamofire.request(kLurl+str, method: .get, parameters: nil).responseJSON { response in
            
            print(response)
            
            let result = response.result
            print(response)
            if let dat = result.value as? Dictionary<String,AnyObject>{
                let res = dat["result"] as! String
                if res == "success"
                {
                    if dat["status"] as! Int == 1
                    {
                        let str = dat["response"] as! String
                        let discountstr = dat["discount"] as! String
                        print(discountstr)
                        let alert = UIAlertController(title: "LearnCab", message: str + " You got "+discountstr+"% discount", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "PROCEED", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                            let mainview = kmainStoryboard.instantiateViewController(withIdentifier: "RazorpayViewController") as! RazorpayViewController
                            mainview.amount = self.amount
                            mainview.tax = self.tax
                            mainview.package_id = self.package_id
                            mainview.courseid = self.course_id
                            mainview.sub_courseid = self.sub_course_id
                            mainview.packagetitle = self.pakage_title
                            mainview.discountstr = discountstr
                            self.present(mainview, animated:true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        let str = dat["response"] as! String
                        let myAlert = UIAlertController(title:"LearnCab", message: str, preferredStyle: UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
                        myAlert.addAction(okAction)
                        self.present(myAlert, animated: true, completion: nil)
                        return
                    }
                }
            }
            SVProgressHUD.dismiss()
        }
    }
    
}
