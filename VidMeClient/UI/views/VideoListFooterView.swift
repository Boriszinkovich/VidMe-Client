//
//  VideoListFooterView.swift
//  VidMeClient
//
//  Created by User on 16.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit

class VideoListFooterView: UICollectionReusableView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.frame = CGRect(origin: CGPoint(x:80, y:40), size: CGSize(width: 100, height: 100))
        activityIndicatorView.alpha = 1;
        activityIndicatorView.startAnimating()
        activityIndicatorView.snp.makeConstraints { (activityMake) in
            activityMake.width.equalTo(30)
            activityMake.height.equalTo(30)
            activityMake.top.equalTo(self.snp.top).offset(20)
            activityMake.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}






























