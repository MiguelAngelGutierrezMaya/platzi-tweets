//
//  AddPostViewController.swift
//  PlatziTweets
//
//  Created by Keybe on 20/06/23.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD
import FirebaseStorage
import AVFoundation
import AVKit
import MobileCoreServices
import CoreLocation

class AddPostViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func addPostAction() {
        if currentVideoURL != nil {
            return uploadVideoToTweetsService()
            //uploadVideoToFirebase()
        }
        
        if previewImageView.image != nil {
            return uploadPhotoToTweetsService()
            //uploadPhotoToFirebase()
        }
        
        return savePost(imageUrl: nil, videoUrl: nil)
    }
    
    @IBAction func openPreviewAction() {
        guard let currentVideoURL = currentVideoURL else {
            return
        }
        
        // Get video taken
        let avPlayer = AVPlayer(url: currentVideoURL)
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    
    @IBAction func openCameraAction() {
        let alert = UIAlertController(
            title: "Camera",
            message: "Select an option",
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(
                title: "Photo",
                style: .default,
                handler: { (_) in
                    self.openCamera()
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Video",
                style: .default,
                handler: { (_) in
                    self.openVideoCamera()
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .destructive,
                handler: nil
            )
        )
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoURL: URL?
    private var locationManager: CLLocationManager?
    private var userLocation: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        videoButton.isHidden = true
        requestLocation()
    }
    
    private func requestLocation() {
        // 1. Validate if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    private func openVideoCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func openCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func uploadPhotoToFirebase() {
        // 1. Ensure file exist
        
        // 2. Compress image and convert on Data
        guard let imageSaved = previewImageView.image,
              let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
            return
        }
        SVProgressHUD.show()
        
        // 3. Config to save file on firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        // 4. Get reference to firebase storage
        let storage = Storage.storage()
        
        // 5. Create name for file
        let imageName = Int.random(in: 100...1000)
        
        // 6. Create reference to save file
        let storageReference = storage.reference(withPath: "\(GlobalVars.folderImagetweets)/\(imageName).jpg")
        
        // 7. Save file on firebase
        DispatchQueue.global(qos: .background).async {
            storageReference.putData(imageSavedData, metadata: metaDataConfig) { (result: Result<StorageMetadata, Error>) in
                DispatchQueue.main.async {
                    // Stop loader
                    SVProgressHUD.dismiss()
                    
                    switch result {
                    case .success(_):
                        storageReference.downloadURL { (url: URL?, error: Error?) in
                            let urlDownloaded = url?.absoluteString ?? ""
                            self.savePost(imageUrl: urlDownloaded, videoUrl: nil)
                        }
                    case .failure(let error):
                        NotificationBanner(
                            title: "Error",
                            subtitle: "Error al subir la imagen \(error.localizedDescription)",
                            style: .warning
                        ).show()
                    }
                }
            }
        }
    }
    
    private func uploadPhotoToTweetsService() {
        // 1. Ensure file exist
        // 2. Compress image and convert on Data
        guard let imageSaved = previewImageView.image,
              let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        let imageBase64String: String = imageSavedData.base64EncodedString()
        
        SVProgressHUD.show()
        
        SN.post(endpoint: Endpoints.files,
                model: UploadImageRequest(file: imageBase64String)) { (response: SNResultWithEntity<String, ErrorResponse>) in
            SVProgressHUD.dismiss()
            
            switch response {
            case .success(let uploadImageResponse):
                self.savePost(imageUrl: uploadImageResponse, videoUrl: nil)
            case .error(let error):
                NotificationBanner(
                    title: "Error",
                    subtitle: "Error al subir la imagen \(error.localizedDescription)",
                    style: .warning
                ).show()
            case .errorResult(let errorResponse):
                NotificationBanner(
                    title: "Error",
                    subtitle: "Error al subir la imagen \(errorResponse.error)",
                    style: .warning
                ).show()
            }
        }
    }
    
    private func uploadVideoToFirebase() {
        // 1. Ensure file exist
        // 2. Convert video to Data
        guard let currentVideoSavedURL = currentVideoURL,
              let videoSavedData: Data = try? Data(contentsOf: currentVideoSavedURL)else {
            return
        }
        
        SVProgressHUD.show()
        
        // 3. Config to save file on firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "video/mp4"
        
        // 4. Get reference to firebase storage
        let storage = Storage.storage()
        
        // 5. Create name for file
        let videoName = Int.random(in: 100...1000)
        
        // 6. Create reference to save file
        let storageReference = storage.reference(withPath: "\(GlobalVars.folderVideotweets)/\(videoName).mp4")
        
        // 7. Save file on firebase
        DispatchQueue.global(qos: .background).async {
            storageReference.putData(videoSavedData, metadata: metaDataConfig) { (result: Result<StorageMetadata, Error>) in
                DispatchQueue.main.async {
                    // Stop loader
                    SVProgressHUD.dismiss()
                    
                    switch result {
                    case .success(_):
                        storageReference.downloadURL { (url: URL?, error: Error?) in
                            let urlDownloaded = url?.absoluteString ?? ""
                            self.savePost(imageUrl: nil, videoUrl: urlDownloaded)
                        }
                    case .failure(let error):
                        NotificationBanner(
                            title: "Error",
                            subtitle: "Error al subir la imagen \(error.localizedDescription)",
                            style: .warning
                        ).show()
                    }
                }
            }
        }
    }
    
    private func uploadVideoToTweetsService() {
        // 1. Ensure file exist
        // 2. Convert video to Data
        guard let currentVideoSavedURL = currentVideoURL,
              let videoSavedData: Data = try? Data(contentsOf: currentVideoSavedURL)else {
            return
        }
        
        SVProgressHUD.show()
        
        let videoBase64String: String = videoSavedData.base64EncodedString()
        
        SVProgressHUD.show()
        
        SN.post(endpoint: Endpoints.files,
                model: UploadImageRequest(file: videoBase64String)) { (response: SNResultWithEntity<String, ErrorResponse>) in
            SVProgressHUD.dismiss()
            
            switch response {
            case .success(let uploadVideoResponse):
                self.savePost(imageUrl: nil, videoUrl: uploadVideoResponse)
            case .error(let error):
                NotificationBanner(
                    title: "Error",
                    subtitle: "Error al subir el video \(error.localizedDescription)",
                    style: .warning
                ).show()
            case .errorResult(let errorResponse):
                NotificationBanner(
                    title: "Error",
                    subtitle: "Error al subir el video \(errorResponse.error)",
                    style: .warning
                ).show()
            }
        }
    }
    
    private func savePost(imageUrl: String?, videoUrl: String?) {
        // Crear location request
        var postLocation: PostRequestLocation?
        
        if let userLocation = userLocation {
            postLocation = PostRequestLocation(
                latitude: userLocation.coordinate.latitude,
                longitude: userLocation.coordinate.longitude
            )
        }
        
        // 1. Create request
        guard let text = postTextView.text, !text.isEmpty else {
            NotificationBanner(
                title: "Error",
                subtitle: "Debes ingresar un texto",
                style: .danger
            ).show()
            return
        }
        
        let request = PostRequest(
            text: text,
            imageUrl: imageUrl,
            videoUrl: videoUrl,
            location: postLocation
        )
        
        // 2. Show data loading
        SVProgressHUD.show()
        
        // 3. Make request
        SN.post(endpoint: Endpoints.posts,
                model: request) {(response: SNResultWithEntity<Post, ErrorApiResponse>) in
            // 4. Close loader indicator
            SVProgressHUD.dismiss()
            
            switch response {
            case .success:
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
                NotificationBanner(
                    subtitle: "Error = \(error.localizedDescription)",
                    style: .danger
                ).show()
            case .errorResult(let errorResponse):
                NotificationBanner(
                    subtitle: "Error = \(errorResponse.errorType.message)",
                    style: .danger
                ).show()
            }
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Close camera
        imagePicker?.dismiss(animated: true, completion: nil)
        
        // Capture image
        if info.keys.contains(.originalImage) {
            previewImageView.isHidden = false
            
            // Get image taken
            previewImageView.image = info[.originalImage] as? UIImage
        }
        
        // Capture video url
        if info.keys.contains(.mediaURL), let recordedVideoURL = (info[.mediaURL] as? URL)?.absoluteURL {
            videoButton.isHidden = false
            currentVideoURL = recordedVideoURL
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension AddPostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let bestLocation = locations.last else {
            return
        }
        
        // We have a location 📍
        userLocation = bestLocation
    }
}
