//
//  EditViewController.swift
//  Trax
//
//  Created by Sun liang on 2/1/16.
//  Copyright © 2016 Liam. All rights reserved.
//

//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Sun liang on 1/31/16.
//  Copyright © 2016 Liam. All rights reserved.
//

import UIKit
import MobileCoreServices
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class EditWaypointViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var waypointToEdit: EditableWaypoint? { didSet { updateUI() } }
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet { nameTextField.delegate = self }
    }
    
    @IBOutlet weak var infoTextField: UITextField! {
        didSet { infoTextField.delegate = self }
    }
    
    func updateUI() {
        nameTextField?.text = waypointToEdit?.name
        infoTextField?.text = waypointToEdit?.info
        updateImage()
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTextFields()
    }
    
    var ntfObserver: NSObjectProtocol?
    var itfObserver: NSObjectProtocol?
    
    func observeTextFields() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nameTextField, queue: queue ) { notification in
            if let waypoint = self.waypointToEdit {
                waypoint.name = self.nameTextField.text
            }
        }
        
        center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: infoTextField, queue: queue ) { notification in
            if let waypoint = self.waypointToEdit {
                waypoint.info = self.infoTextField.text
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = ntfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = itfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    var imageView = UIImageView()
    
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet {
            imageViewContainer.addSubview(imageView)
        }
    }
    
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        print("if it is called")
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageView.image = image
        makeRoomForImage()
        saveImageInWaypoint()
        dismiss(animated: true, completion: nil)
    }
    
    func saveImageInWaypoint()
    {
        if let image = imageView.image {
            if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                let fileManager = FileManager()
                if let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let unique = Date.timeIntervalSinceReferenceDate
                    let url = docsDir.appendingPathComponent("\(unique).jpg")
                    if (try? imageData.write(to: url, options: [.atomic])) != nil {
                        waypointToEdit?.links = [GPX.Link(href: url.absoluteString)]
                    }
                }
            }
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        updateUI()
        
        let image = UIImage(named: "defaultPhoto")
        imageView.image = image
        
        let imageTapRecognizer = UITapGestureRecognizer(target: imageView, action: #selector(EditWaypointViewController.imageTapped(_:)))
        imageTapRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(imageTapRecognizer)
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension EditWaypointViewController
{
    func updateImage() {
        if let url = waypointToEdit?.imageURL {
            let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
            DispatchQueue.global(priority: qos).async { [weak self] in
                if let imageData = try? Data(contentsOf: url) {
                    if url == self?.waypointToEdit?.imageURL {
                        if let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self?.imageView.image = image
                                self?.makeRoomForImage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // all we do in makeRoomForImage() is adjust our preferredContentSize
    // we assume that our preferredContentSize is what is currently desired (pre-adjustment)
    // then we adjust it to make up for any differences in the size of our image view or its container
    // if our preferredContentSize change can be accomodated, our container will get taller
    // and more of our image will show
    // if not, we tried our best to show as much of the image as possible
    // because we use the entire width of our container view and
    // show an appropriate height depending on our image's aspect ratio
    // this is sort of a "quick and dirty" way to do this
    // in a real application, one would probably want to be more exacting here
    // (perhaps apply more sophisticated autolayout to the problem)
    
    func makeRoomForImage() {
        var extraHeight: CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        } else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRect.zero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}


