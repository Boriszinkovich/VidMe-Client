//
//  MainTabBarVC.swift
//  VidMeClient
//
//  Created by User on 16.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import Foundation

class MainTabBarVC: UITabBarController
{
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
}





























