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
    internal var errorView:ErrorView!
    
    internal var internetReachability: Reachability!
    fileprivate var videosArray = Array<VidMeVideo>()
    fileprivate var currentPlayingVideo: VidMeVideo?
    fileprivate var isUploading = false
    internal var isRefreshing = false
    fileprivate var hasMoreVideos = true
    {
            didSet
            {
                (self.collView.collectionViewLayout as! UICollectionViewFlowLayout).footerReferenceSize = CGSize(width: self.view.bounds.size.width, height: hasMoreVideos == true ? 70 : 0)
            }
    }

    fileprivate let errorViewHeight = 35
    fileprivate static var hasVideoSound: Bool = true
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSoundChange(_:)), name: Notification.Name(Constants.Notifications.soundChangeNotification) , object: nil)
        self.uploadVideos()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.currentPlayingVideo?.isVideoPlaying = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.currentPlayingVideo?.isVideoPlaying = false
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
        if isRefreshing == true
        {
            self.currentPlayingVideo?.isVideoPlaying = false
            self.currentPlayingVideo = nil
            self.refreshControl.endRefreshing()
            self.videosArray.removeAll()
            self.isRefreshing = false
        }
        let hadAnyVideo = self.videosArray.count != 0
        var noNewVideo = true
        var theCheckedVideoSet = Set<VidMeVideo>() //
        for vidMeVideo in videos {
            if noNewVideo == false || self.videosArray.index(of: vidMeVideo) == nil
            {
                noNewVideo = false
                theCheckedVideoSet.insert(vidMeVideo)
            }
        }
        self.hasMoreVideos = videos.count != 0
        self.videosArray.append(contentsOf: theCheckedVideoSet)
        self.isUploading = false
        self.collView.reloadData()
        DispatchQueue.main.async
        {
            if self.isRefreshing == true || hadAnyVideo == false
            {
                self.checkCellForPlaying(fromTop: true)
            }
        }
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
    
    func checkCellForPlaying(fromTop: Bool)
    {
        var path = self.collView.indexPathForItem(at: CGPoint(x:20, y: (self.collView.contentOffset.y + self.collView.frame.size.height / 2)))
        if fromTop == true
        {
            path = self.collView.indexPathForItem(at: CGPoint(x:20, y: (self.collView.bounds.size.height / 2)))
        }
        if (path != nil)
        {
            let video = self.videosArray[(path!.row)]
            if self.currentPlayingVideo == nil || (self.currentPlayingVideo != nil && self.currentPlayingVideo != video)
            {
                self.currentPlayingVideo?.isVideoPlaying = false
                self.currentPlayingVideo = video
                self.currentPlayingVideo?.isVideoPlaying = true
            }
        }
    }
    
    func receiveSoundChange(_ notification:Notification)
    {
        if let notifObject = notification.object as? Bool
        {
            VideoListVC.hasVideoSound = notifObject
        }
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
        cell.video.playingListener = cell
        cell.soundImageView.isUserInteractionEnabled = true
        cell.hasSound = VideoListVC.hasVideoSound
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let video = self.videosArray[indexPath.row]
        if video.smallestVideoUrlString != nil
        {
            let showVideoVC: ShowVideoVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowVideoVCID") as! ShowVideoVC
            showVideoVC.currentVideo = self.videosArray[indexPath.row]
            self.navigationController?.pushViewController(showVideoVC, animated: true)
        }
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
            cell?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width:self.view.bounds.size.width ,height: 1200))
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
            if self.hasMoreVideos == true
            {
                self.uploadVideos()
            }
        }
        self.checkCellForPlaying(fromTop: false)
    }
}































