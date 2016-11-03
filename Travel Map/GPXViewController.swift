//
//  GPXViewController.swift
//  Trax
//
//  Created by Sun liang on 1/30/16.
//  Copyright © 2016 Liam. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class GPXViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
  
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
          mapView.mapType  = .standard
          mapView.delegate = self
        }
    }
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    // MARK: - Public API
    var gpxURL: URL? {
        didSet {
            clearWaypoints()
            if let url = gpxURL {
                GPX.parse(url) {
                    if let gpx = $0 {
                        self.handleWaypoints(gpx.waypoints)
                    }
                }
            }
        }
    }

    // MARK: - Waypoints
    fileprivate func clearWaypoints() {
        if mapView?.annotations != nil { mapView.removeAnnotations(mapView.annotations as [MKAnnotation]) }
    }
    
    fileprivate func handleWaypoints(_ waypoints: [GPX.Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }
    
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            let waypoint = EditableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "New waypoint"
            //waypoint.links.append(GPX.Link(href: "https://www.nasa.gov/sites/default/files/thumbnails/image/20150409-10-sebastiansaarloos.jpg"))
            mapView.addAnnotation(waypoint)
        }
    }
    
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // if user's current location, return nil
        if annotation is MKUserLocation {
            return nil
        }
        
        // if waypoints, return custom view
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view?.isDraggable = annotation is EditableWaypoint
        
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                view?.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
            
            if annotation is EditableWaypoint {
                view?.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIButton
            }
   
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // if waypoints, add left and right callout
        if let waypoint = view.annotation as? GPX.Waypoint {
            if let url = waypoint.thumbnailURL {
                if view.leftCalloutAccessoryView == nil {
                    view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
                }
                if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                    if let imageData = try? Data(contentsOf: url as URL) {
                        if let image = UIImage(data: imageData) {
                            thumbnailImageButton.setImage(image, for: UIControlState())
                        }
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == UIButtonType.detailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegue(withIdentifier: Constants.EditWaypointSegue, sender: view)
            
        } else if let waypoint = view.annotation as? GPX.Waypoint {
            if waypoint.imageURL != nil {
                performSegue(withIdentifier: Constants.ShowImageSegue, sender: view)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer = MKPolylineRenderer(polyline: route)
        routeRenderer.lineWidth = 5.0
        routeRenderer.strokeColor = UIColor.blue
        return routeRenderer
    }
   
    
    // MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Configure Image Scence
        if segue.identifier == Constants.ShowImageSegue {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? GPX.Waypoint {
                if let wivc = segue.destination.contentViewController as? WaypointImageViewController {
                    wivc.waypoint = waypoint
                } else if let ivc = segue.destination.contentViewController as? ImageViewController {
                    ivc.imageURL = waypoint.imageURL
                    ivc.title = waypoint.name
                }
            }
        // Configure Waypoint Scence
        } else if segue.identifier == Constants.EditWaypointSegue {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? EditableWaypoint {
                if let ewvc = segue.destination.contentViewController as? EditWaypointViewController {
                    if let ppc = ewvc.popoverPresentationController {
                        let coordinatePoint = mapView.convert(waypoint.coordinate, toPointTo: mapView)
                        ppc.sourceRect = (sender as! MKAnnotationView).popoverSourceRectForCoordinatePoint(coordinatePoint)
                        let minimumSize = ewvc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                        ewvc.preferredContentSize = CGSize(width: Constants.EditWaypointPopoverWidth, height: minimumSize.height)
                        ppc.delegate = self
                    }
                    ewvc.waypointToEdit = waypoint
                }
            }
        // Configure Map
        }  else if segue.identifier  == Constants.ConfigureMapSegue {
            if let mapvc = segue.destination.contentViewController as? MapDetailViewController {
                mapvc.modalPresentationStyle = .custom
                mapvc.transitioningDelegate = mapDetailTransitionDelegate
                mapvc.mapView = self.mapView
            }
        }
        
    }
    
    // MARK: PresentationControllerdelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
    }
    
    // MARK: Search
    let searchBar = UISearchBar()
    var leftBarButtonItem: UIBarButtonItem?
    var rightBarButtionItem: UIBarButtonItem?
    var destLocation: CLLocationCoordinate2D!
    
    func searchhandler( _ placemarks: [CLPlacemark]?, error: NSError? ) -> Void {
        if let placemark = placemarks?.first {
            // get destination coordinate
            destLocation = CLLocationCoordinate2DMake(placemark.location!.coordinate.latitude, placemark.location!.coordinate.longitude)
            
            // add waypoint for destination
            let waypoint = EditableWaypoint(latitude: destLocation.latitude, longitude: destLocation.longitude)
            if let locationName = placemark.addressDictionary!["Name"] as? NSString {
                waypoint.name = locationName as String
            } else {
                waypoint.name = searchBar.text
            }
            mapView.addAnnotation(waypoint)
            
            let region = MKCoordinateRegionMake(destLocation, MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            mapView.setRegion(region, animated: true)
        }
    }
    
    func leftBarButtonItemTapped() {
        let request = MKDirectionsRequest()
    
        mapView.showsUserLocation = true
        let srcLocation = mapView.userLocation.coordinate
        
        // set startplace
        let srcPlacemark = MKPlacemark(coordinate: srcLocation, addressDictionary: nil)
        let srcMapItem = MKMapItem(placemark: srcPlacemark)
        request.source = srcMapItem
        
        // set destination
        let destPlacemark = MKPlacemark(coordinate: destLocation, addressDictionary: nil)
        let destMapItem = MKMapItem(placemark: destPlacemark)
        request.destination = destMapItem
        
        let direction = MKDirections(request: request)
        direction.calculate(completionHandler: {
            (response: MKDirectionsResponse?, error: NSError?) -> Void in
            if let DirResponse = response {
                if !DirResponse.routes.isEmpty {
                    let route: MKRoute = DirResponse.routes[0] as MKRoute
                    self.mapView.add(route.polyline)
                    
                    let center = CLLocationCoordinate2DMake((srcLocation.latitude + self.destLocation.latitude)/2.0, (srcLocation.longitude + self.destLocation.longitude)/2.0)
                    let span = MKCoordinateSpanMake(abs(self.destLocation.latitude - srcLocation.latitude)*1.2, abs(self.destLocation.longitude - srcLocation.longitude)*1.2 )
                    let region = MKCoordinateRegionMake(center, span)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        } as! MKDirectionsHandler)
    }

    func rightBarButtonItemTapped() {
        let textItem = "map"
        if let mapItem = mapView {
            let activityViewController = UIActivityViewController(activityItems: [textItem, mapItem], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func showNavigationBarButtonItem(_ showNavigationBarButton: Bool) {
        if showNavigationBarButton {
            leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation_arrow"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(GPXViewController.leftBarButtonItemTapped))
            rightBarButtionItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(GPXViewController.rightBarButtonItemTapped))
        } else {
            leftBarButtonItem = nil
            rightBarButtionItem = nil
        }
        
        navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
        navigationItem.setRightBarButton(rightBarButtionItem, animated: true)
    }
    
    // MAKR: UISearchDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showNavigationBarButtonItem(false)
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        showNavigationBarButtonItem(true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        mapView.removeAnnotations(self.mapView.annotations)
        mapView.removeOverlays(self.mapView.overlays)
        let geocoder = CLGeocoder()
  
        if let searchText = searchBar.text {
            geocoder.geocodeAddressString(searchText, completionHandler: searchhandler as! CLGeocodeCompletionHandler)
        }
        showNavigationBarButtonItem(true)
        
    }
    
    // Mark: Bar Hidden
    var shouldBeHidingBar: Bool = false {
        didSet {
            self.prefersStatusBarHidden
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return self.shouldBeHidingBar
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    func mapViewTapped() {
        self.shouldBeHidingBar = !self.shouldBeHidingBar
        if let nv = navigationController {
            nv.setNavigationBarHidden(shouldBeHidingBar, animated: true)
            nv.setToolbarHidden(shouldBeHidingBar, animated: true)
        }
    }
    
    
    // MARK: Tool Bar
    func addToolBarButtonItem() {
        let locationIcon = UIImage(named: "location_icon.png")
        let detailDisclosureIcon = UIImage(named: "detail_disclosure_icon.png")
        let toCurrentPositionButton = UIBarButtonItem(image: locationIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(GPXViewController.getCurrentLocation))
        let configureMapButton = UIBarButtonItem(image: detailDisclosureIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(GPXViewController.configureMap(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        self.toolbarItems = [toCurrentPositionButton,flexibleSpace,configureMapButton]
    }
    
    func configureMap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.ConfigureMapSegue, sender: sender)
    }
    
    func getCurrentLocation() {
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        //locManager.startUpdatingHeading()
        locManager.delegate = self
        
        mapView.userLocation.title = "Current Location"
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
    }
    
    // MARK: Current position
    let locManager = CLLocationManager()
    
    let mapDetailTransitionDelegate = MapDetailTransitioningDelegate()
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
        
        var mkCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        
        let currentSpan = mapView.region.span
        if (currentSpan.latitudeDelta < 0.05 && currentSpan.longitudeDelta < 0.05) {
            mkCoordinateSpan = currentSpan
        }
        
        let region = MKCoordinateRegionMake(center, mkCoordinateSpan)
        mapView.setRegion(region, animated: true)
        
        let geoCoder = CLGeocoder()
        if location != nil {
            geoCoder.reverseGeocodeLocation(location!, completionHandler: {
                (placemarks, error) -> Void in
                if let placemark = placemarks?.first {
                    if let name = placemark.addressDictionary?["Name"] as? NSString {
                        self.mapView.userLocation.title = name as String
                    }
                }
            })
        }
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: " + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    }
    
    
    // MARK: Custmize Gesture Recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is MKAnnotationView {
            return false
        }
        return true
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let appDelegate = UIApplication.shared.delegate
        
        center.addObserver(forName: NSNotification.Name(rawValue: GPXURL.Notification), object: appDelegate, queue: queue ) {
            notification in
            if let url = notification.userInfo?[GPXURL.Key] as? URL {
                self.gpxURL = url
            }
            
        }
        
        // Single Tap Gesture
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(GPXViewController.mapViewTapped))
        singleTap.delegate = self
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(singleTap)
        
        // Double Taps Gesture
        let doubleTap = UITapGestureRecognizer()
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
    }
 
    override func viewWillAppear(_ animated: Bool) {

        // Customize Navigation Bar
        showNavigationBarButtonItem(true)
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.placeholder = "Search for place or address"
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor(white: 0.9, alpha: 0.95)
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        // Customize Tool Bar
        if let toolBar = navigationController?.toolbar {
            if let navigationBar = navigationController?.navigationBar {
                toolBar.barStyle = navigationBar.barStyle
                toolBar.tintColor = navigationBar.tintColor
            }
        }
        
        addToolBarButtonItem()
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    // MARK: Constants
    fileprivate struct Constants {
        static let PartialTrackColor = UIColor.green
        static let FullTrackColor = UIColor.blue.withAlphaComponent(0.5)
        static let TrackLineWidth: CGFloat = 3.0
        static let ZoomCooldown = 1.5
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let ConfigureMapSegue = "Configure Map"
        static let EditWaypointSegue = "Edit Waypoint"
        static let EditWaypointPopoverWidth: CGFloat = 320
    }
    
}

// MAKR: Extensions
extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController!
        } else {
            return self
        }
    }
}

extension MKAnnotationView {
    func popoverSourceRectForCoordinatePoint(_ coordinatePoint: CGPoint) -> CGRect {
        var popoverSourceRectCenter = coordinatePoint
        popoverSourceRectCenter.x -= frame.width / 2 - centerOffset.x - calloutOffset.x
        popoverSourceRectCenter.y -= frame.height / 2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: popoverSourceRectCenter, size: frame.size)
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}


