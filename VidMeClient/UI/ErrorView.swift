//
//  ErrorView.swift
//  VidMeClient
//
//  Created by User on 13.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit

class ErrorView: UIView
{
    @IBOutlet weak var errorLabel: UILabel!
    {
        didSet
        {
            self.errorLabel.textColor = UIColor.white
        }
    }
}






























