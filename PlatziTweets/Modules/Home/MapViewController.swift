//
//  MapViewController.swift
//  PlatziTweets
//
//  Created by Miguel Angel Gutierrez Maya on 20/10/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var mapContainer: UIView!
    
    // MARK: - Properties
    public var posts = [Post]()
    private var map: MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Do any additional setup after loading the view.
        setUpMap()
    }
    
    // MARK: - Functions
    private func setUpMap() {
        map = MKMapView(frame: mapContainer.bounds)
        mapContainer.addSubview(map ?? UIView())
        setupMarkers()
    }
    
    private func setupMarkers() {
        for post in posts {
            let marker = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: post.location?.latitude ?? 0, longitude: post.location?.longitude ?? 0)
            marker.title = post.text
            marker.subtitle = post.author.names
            map?.addAnnotation(marker)
        }
        
        // Find last post and show it
        guard let lastPost = posts.first else { return }
        
        let lastPostLocation = CLLocationCoordinate2D(latitude: lastPost.location?.latitude ?? 0, longitude: lastPost.location?.longitude ?? 0)
        
        guard let heading = CLLocationDirection(exactly: 12) else { return }
        
        map?.camera = MKMapCamera(
            lookingAtCenter: lastPostLocation,
            fromDistance: 30,
            pitch: 0,
            heading: heading
        )
    }
}
