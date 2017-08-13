//
//  VideoListVC.swift
//  VidMeClient
//
//  Created by User on 13.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit
import SnapKit
import ReachabilitySwift

class VideoListVC: UIViewController
{
    fileprivate var collView: UICollectionView!
    fileprivate var activityIndicator: UIActivityIndicatorView!
    fileprivate var footerView: UICollectionReusableView!
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var errorHeightConstraint: Constraint? = nil
    fileprivate var errorView:ErrorView!
    
    fileprivate var internetReachability: Reachability!
    fileprivate var videosArray = Array<VidMeVideo>()
    fileprivate var isUploading = false
    fileprivate var isRefreshing = false
    
    fileprivate let errorViewHeight = 35
    
    fileprivate struct Cells
    {
        static let FooterIdent = "FooterView"
        static let VideoCellIdent = "videoCellIdent"
        static let VideoCellXibName = "VideoCellXib"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.createUI()
        let reachability = Reachability()!
        self.internetReachability = reachability
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async
            {
                self.hideErrorView()
                self.refreshVideos()
            }
        }
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async
            {
                self.showError(errorString: "No internet connection", continuously: true)
            }
        }
        do
        {
            try reachability.startNotifier()
        } catch {
        }
        self.uploadVideos()
    }
    
    func methodLoadVideos(offset:UInt)
    {
    }
    
    func showError(errorString: String, continuously: Bool)
    {
        self.errorView.errorLabel.text = errorString
        self.errorHeightConstraint?.update(offset: self.errorViewHeight)
        self.view.layoutIfNeeded()
    }
    
    func hideErrorView()
    {
        self.errorHeightConstraint?.update(offset: 0)
        self.view.layoutIfNeeded()
    }
    
    func handleErrorVideos(refreshing: Bool, error: Error)
    {
        if isRefreshing
        {
            self.refreshControl.endRefreshing()
            self.isRefreshing = false
        }
        self.isUploading = false
        let theError: NSError = error as NSError
        if theError.code == -1
        {
            self.showError(errorString: "Connection error", continuously: false)
        }
    }
    
    func handleNewVideos(videos: [VidMeVideo], refreshing: Bool)
    {
        if isRefreshing
        {
            self.refreshControl.endRefreshing()
            self.videosArray.removeAll()
            self.isRefreshing = false
        }
        var hasVideo = true
        for vidMeVideo in videos {
            if hasVideo == false || self.videosArray.index(of: vidMeVideo) == nil
            {
                hasVideo = false
                self.videosArray.append(vidMeVideo)
            }
        }
        self.isUploading = false
        self.collView.reloadData()
    }
    
    func uploadVideos()
    {
        if self.isUploading || self.isRefreshing
        {
            return
        }
        self.isUploading = true
        self.methodLoadVideos(offset: UInt(self.videosArray.count))
    }

    func refreshVideos()
    {
        if self.isRefreshing
        {
            return
        }
        self.isRefreshing = true
        self.methodLoadVideos(offset: 0)
    }
    
    func createUI()
    {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        layout.footerReferenceSize = CGSize(width: self.view.bounds.size.width, height: 70)
        collView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.view.addSubview(self.collView)
        self.collView.snp.makeConstraints({ (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        })
        self.collView.register(UINib(nibName: Cells.VideoCellXibName, bundle: nil), forCellWithReuseIdentifier: Cells.VideoCellIdent)
        self.collView.delegate = self
        self.collView.dataSource = self
        self.collView.backgroundColor = UIColor.white
        self.collView.register(VideoListFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: Cells.FooterIdent)
        
        self.collView.reloadData()
        
        let refreshControl = UIRefreshControl()
        self.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collView.addSubview(refreshControl)
        self.collView.alwaysBounceVertical = true
        
        let theObjectsArray = Bundle.main.loadNibNamed("ErrorView", owner: nil, options: nil)
        let errorView = theObjectsArray?.first as! ErrorView?
        self.errorView = errorView
        errorView?.clipsToBounds = true
        self.view.addSubview(errorView!)
        errorView?.snp.makeConstraints({ (maker) in
            maker.leading.equalToSuperview()
            maker.trailing.equalToSuperview()
            maker.top.equalTo(self.topLayoutGuide.snp.bottom)
            self.errorHeightConstraint = maker.height.equalTo(80).constraint
        })
    }
    
    func refresh()
    {
        self.refreshVideos()
    }
}

extension VideoListVC :  UICollectionViewDataSource
{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.videosArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : VideoCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.VideoCellIdent, for: indexPath) as! VideoCell
        cell.video = self.videosArray[indexPath.row]
        return cell
    }
    
     public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if kind.isEqual(UICollectionElementKindSectionFooter)
        {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cells.FooterIdent, for: indexPath)
            return reusableView;
        }
        return UICollectionReusableView();
    }
    
}

extension VideoListVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var cell: VideoCell? = collectionView.cellForItem(at: indexPath) as? VideoCell
        
        if (cell == nil)
        {
            let theObjectsArray = Bundle.main.loadNibNamed(Cells.VideoCellXibName, owner: nil, options: nil)
            cell = theObjectsArray?.first as! VideoCell?
            cell?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width:self.view.bounds.size.width ,height: 400))
            cell?.video = self.videosArray[indexPath.row]
            cell?.layoutIfNeeded()
        }
        let cellSize = cell?.systemLayoutSizeFitting(UILayoutFittingCompressedSize, withHorizontalFittingPriority: UILayoutPriorityDefaultHigh, verticalFittingPriority: UILayoutPriorityDefaultLow)
        return cellSize!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - self.view.bounds.size.height)
        {
            self.uploadVideos()
        }
    }
}

fileprivate class VideoListFooterView: UICollectionReusableView
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





























