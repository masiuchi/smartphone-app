//
//  ImageViewController.swift
//  MT_iOS
//
//  Created by CHEEBOW on 2015/06/17.
//  Copyright (c) 2015年 Six Apart, Ltd. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var asset: Asset!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Color.black
        
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        view.addSubview(scrollView)
        
        imageView = UIImageView(frame: scrollView.bounds)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        scrollView.addSubview(imageView)
        
        self.title = asset.dispName()
        self.imageView.sd_setImage(with: URL(string: asset.url))
        
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ImageViewController.doubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(doubleTapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func doubleTap(_ gesture: UITapGestureRecognizer) -> Void {
        if scrollView.zoomScale < scrollView.maximumZoomScale {
            let scale = scrollView.maximumZoomScale
            scrollView.setZoomScale(scale, animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
}
