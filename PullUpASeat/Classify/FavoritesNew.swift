//
//  FavoritesNew.swift
//  PullUpASeat
//
//  Created by Star on 2/21/17.
//  Copyright © 2017 Pull-Up-A-Seat. All rights reserved.
//

import UIKit
import Parse



// MARK: - FAVORITES CUSTOM CELL
class FavoritesCellNew: UITableViewCell {
    /* Views */
    @IBOutlet var adImage: UIImageView!
    @IBOutlet var adTitleLabel: UILabel!
    @IBOutlet var adDescrLabel: UILabel!
}


class FavoritesNew: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var favoritesArray = [PFObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.isNavigationBarHidden = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        
        if PFUser.current() != nil {
            queryFavAds()
        } else {
            simpleAlert("You must login/signup into your Account to add Favorites")
        }

        
    }
    
    // MARK: - QUERY FAVORITES
    func queryFavAds()  {
        favoritesArray.removeAll()
        
        let query = PFQuery(className: FAV_CLASS_NAME)
        query.whereKey(FAV_USERNAME, equalTo: PFUser.current()!.username!)
        query.includeKey(FAV_AD_POINTER)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.favoritesArray = objects!
                // Show details (or reload a TableView)
                self.tableView.reloadData()
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    
    
    // MARK: - TABLEVIEW DELEGATES
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCellNew", for: indexPath) as! FavoritesCellNew
        
        var favClass = PFObject(className: FAV_CLASS_NAME)
        favClass = favoritesArray[indexPath.row]
        
        // Get Ads as a Pointer
        let adPointer = favClass[FAV_AD_POINTER] as! PFObject
        adPointer.fetchIfNeededInBackground { (ad, error) in
            if error == nil {
                cell.adTitleLabel.text = "\(adPointer[CLASSIF_TITLE]!)"
                cell.adDescrLabel.text = "\(adPointer[CLASSIF_DESCRIPTION]!)"
                
                // Get image
                let imageFile = adPointer[CLASSIF_IMAGE1] as? PFFile
                imageFile?.getDataInBackground (block: { (imageData, error) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.adImage.image = UIImage(data:imageData)
                        }}})
                
            } else { self.simpleAlert("\(error!.localizedDescription)")
            }}
        
        
        return cell
    }
    
    
    // MARK: - SELECT AN AD -> SHOW IT
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var favClass = PFObject(className: FAV_CLASS_NAME)
        favClass = favoritesArray[indexPath.row]
        // Get favorite Ads as a Pointer
        let adPointer = favClass[FAV_AD_POINTER] as! PFObject
        adPointer.fetchIfNeededInBackground { (ad, error) in
            let showAdVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowSingleAdVC") as! ShowSingleAdVC
            // Pass the Ad Objedt to the Controller
            showAdVC.singleAdObj = adPointer
            self.navigationController?.pushViewController(showAdVC, animated: true)
        }
    }
    
    
    
    
    // MARK: - REMOVE THIS AD FROM YOUR FAVORITES
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete selected Ad
            var favClass = PFObject(className: FAV_CLASS_NAME)
            favClass = favoritesArray[indexPath.row]
            
            favClass.deleteInBackground {(success, error) -> Void in
                if error != nil {
                    self.simpleAlert("\(error!.localizedDescription)")
                }}
            
            // Remove record in favoritesArray and the tableView's row
            self.favoritesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}