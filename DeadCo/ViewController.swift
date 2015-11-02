//
//  ViewController.swift
//  DeadCo
//
//  Created by Elaine Ou on 11/1/15.
//  Copyright © 2015 Elaine Ou. All rights reserved.
//

import UIKit
import Koloda
import pop

let BASE_URL: String = "https://www.sandhill.exchange"
let MARKET_URL: String = BASE_URL + "/market/json"
let PORTFOLIO_URL: String = BASE_URL + "/portfolio/json"

private var numberOfCards: UInt = 5

class ViewController: UIViewController, KolodaViewDataSource, KolodaViewDelegate {
    
    @IBOutlet weak var kolodaView: KolodaView!

    var companies = [Company]()
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
    }
    
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    //MARK: KolodaViewDataSource
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return numberOfCards
    }
    
    func kolodaViewForCardAtIndex(koloda: KolodaView, index: UInt) -> UIView {
        let data = NSData(contentsOfURL: companies[Int(index)].logoUrl!)
        return UIImageView(image: UIImage(data:data!))
    }
    func kolodaViewForCardOverlayAtIndex(koloda: KolodaView, index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CustomOverlayView",
            owner: self, options: nil)[0] as? OverlayView
    }
    
    //MARK: KolodaViewDelegate
    
    func kolodaDidSwipedCardAtIndex(koloda: KolodaView, index: UInt, direction: SwipeResultDirection) {
    //Example: loading more cards
        if index >= 3 {
            numberOfCards = 6
            kolodaView.reloadData()
        }
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
    //Example: reloading
        kolodaView.resetCurrentCardNumber()
    }
    
    func kolodaDidSelectCardAtIndex(koloda: KolodaView, index: UInt) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://yalantis.com/")!)
    }
    
    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldTransparentizeNextCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaBackgroundCardAnimation(koloda: KolodaView) -> POPPropertyAnimation? {
        return nil
    }

    
    func getMarketData() {
        //let session = NSURLSession.sharedSession()
        let url = NSURL(string: MARKET_URL)!
        let request = NSURLRequest(URL: url)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {response,data,error in
            if data != nil {
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                } catch {
                    fatalError()
                }
                
                //println(parsedResult)
                if let marketDictionary = parsedResult.valueForKey("data") as? NSArray {
                    
                    for m in marketDictionary {
                        var c = Company()
                        var logoUrl = NSURL(string:BASE_URL + "/gcs/" + (m[0] as! String))
                        c.logoUrl = logoUrl
                        c.key = m[1] as! String
                        c.symbol = m[2] as! String
                        c.name = m[3] as! String
                        c.quote = Quote(lastPrice: m[4] as! Float, dayChange: m[6] as! Float, volume: m[7] as! Int)
                        self.companies.append(c)
                        print("ok")
                    }
                    
                } else {
                    print("Cant find key 'data' in \(parsedResult)")
                }
            }
            
            if error != nil {
                let alert = UIAlertView(title:"Oops!",message:error!.localizedDescription, delegate:nil, cancelButtonTitle:"OK")
                alert.show()
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
    }

}

