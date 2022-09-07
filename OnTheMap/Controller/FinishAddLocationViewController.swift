//
//  FinishAddLocationViewController.swift
//  OnTheMap
//
//  Created by minhdat on 06/09/2022.
//

import UIKit
import MapKit

class FinishAddLocationViewController: UIViewController {
    @IBOutlet weak var mapViewing: MKMapView!
    @IBOutlet weak var actionGuide: UIActivityIndicatorView!
    @IBOutlet weak var finisAdd: UIButton!
    
    var studentInformation: StudentInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let studentAddress = studentInformation {
            let studentLocation = Location(
                objectId: studentAddress.objectId ?? "",
                uniqueKey: studentAddress.uniqueKey,
                firstName: studentAddress.firstName,
                lastName: studentAddress.lastName,
                mapString: studentAddress.mapString,
                mediaURL: studentAddress.mediaURL,
                latitude: studentAddress.latitude,
                longitude: studentAddress.longitude,
                createdAt: studentAddress.createdAt ?? "",
                updatedAt: studentAddress.updatedAt ?? ""
            )
            showLocations(location: studentLocation)
        }
    }

    @IBAction func finishAddLocation(_ sender: UIButton) {
        self.setLoading(true)
        if let studentLocation = studentInformation {
            if UdacityService.shared().auth?.objectId?.isEmpty ?? true {
                UdacityService.shared().addStudentLocation(information: studentLocation) { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                self.setLoading(true)
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(message: error?.localizedDescription ?? "", title: "Error")
                                self.setLoading(false)
                            }
                        }
                    }
            } else {
                let alertViewController = UIAlertController(title: "", message: "This student has already posted a location. Would you like to overwrite this location?", preferredStyle: .alert)
                alertViewController.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action: UIAlertAction) in
                    UdacityService.shared().updateStudentAddress(information: studentLocation) { (finish, error) in
                        if finish {
                            DispatchQueue.main.async {
                                self.setLoading(true)
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(message: error?.localizedDescription ?? "", title: "Error")
                                self.setLoading(false)
                            }
                        }
                    }
                }))
                alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
                    DispatchQueue.main.async {
                        self.setLoading(false)
                        alertViewController.dismiss(animated: true, completion: nil)
                    }
                }))
                self.present(alertViewController, animated: true)
            }
        }
    }
    
    private func showLocations(location: Location) {
        mapViewing.removeAnnotations(mapViewing.annotations)
        if let coordinate = extractCoordinate(location: location) {
            let annotation = MKPointAnnotation()
            annotation.title = location.locationLabel
            annotation.subtitle = location.mediaURL ?? ""
            annotation.coordinate = coordinate
            mapViewing.addAnnotation(annotation)
            mapViewing.showAnnotations(mapViewing.annotations, animated: true)
        }
    }
    
    private func extractCoordinate(location: Location) -> CLLocationCoordinate2D? {
        if let lat = location.latitude, let lon = location.longitude {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return nil
    }

    func setLoading(_ loading: Bool) {
        if loading {
            DispatchQueue.main.async {
                self.actionGuide.startAnimating()
                self.buttonEnabled(false, button: self.finisAdd)
            }
        } else {
            DispatchQueue.main.async {
                self.actionGuide.stopAnimating()
                self.buttonEnabled(true, button: self.finisAdd)
            }
        }
        DispatchQueue.main.async {
            self.finisAdd.isEnabled = !loading
        }
    }
    
}
