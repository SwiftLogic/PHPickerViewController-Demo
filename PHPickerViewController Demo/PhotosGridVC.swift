//
//  PhotosGridVC.swift
//  PHPickerViewController Demo
//
//  Created by Osaretin Uyigue on 7/18/22.
//

import UIKit
import PhotosUI
import AVKit
fileprivate let headerId = "headerid"
fileprivate let videosCellReUseid = "videosCellReUseid"
class PhotosGridVC: UICollectionViewController {
    
    //MARK: - View's LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpCollectionView()        
    }
    
    
    enum MediaSection: Int {
        case photos, livePhotos, videos
    }
    
    
    //MARK: - Properties
    fileprivate var images: [UIImage] = []
    fileprivate var livePhotos: [PHLivePhoto] = []
    fileprivate var videos: [VideoModel] = []
    fileprivate var mediaSections = [MediaSection.photos, .livePhotos, .videos]
    
    
    
    //MARK: - Methods
    fileprivate func setUpCollectionView() {
        
        collectionView.backgroundColor = .white
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.cellReuseIdentifier)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: videosCellReUseid)
        collectionView.register(LivePhotoCell.self, forCellWithReuseIdentifier: LivePhotoCell.cellReuseIdentifier)
        collectionView.register(TitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
    }
    
    
    fileprivate func setUpNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "PHPicker Demo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(setUpImagePicker))
    }
    
    

    @objc  fileprivate func setUpImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .any(of: [.images, .livePhotos, .videos])
        configuration.preferredAssetRepresentationMode = .automatic
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

}


//MARK: - PHPickerViewControllerDelegate
extension PhotosGridVC: PHPickerViewControllerDelegate {
    
    
    fileprivate func parseLivePhoto(using itemProvider: NSItemProvider) {
        if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
            itemProvider.loadObject(ofClass: PHLivePhoto.self) { [weak self] livePhoto, error in
                DispatchQueue.main.async {
                    if let livePhoto = livePhoto as? PHLivePhoto {
                        self?.livePhotos.insert(livePhoto, at: 0)
                        let indexPath = IndexPath(item: 0, section: 1)
                        self?.collectionView.insertItems(at: [indexPath])
                    }
                }
            }
        }
    }
    
    
    
    fileprivate func parsePhoto(using itemProvider: NSItemProvider) {
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self?.images.insert(image, at: 0)
                        let indexPath = IndexPath(item: 0, section: 0)
                        self?.collectionView.insertItems(at: [indexPath])
                    }
                }
            }
        }
    }


    
    fileprivate func parseVideo(using itemProvider: NSItemProvider) {
        
        let movieTypeIdentifier = UTType.movie.identifier
        
        if itemProvider.hasItemConformingToTypeIdentifier(movieTypeIdentifier) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: movieTypeIdentifier) {[weak self] url, error in
                guard error == nil, let url = url else {
                    print("error parsing video object: ", error?.localizedDescription ?? "")
                    return
                }
                let fileName = "\(Int(Date().timeIntervalSince1970)).\(url.pathExtension)"
                let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                try? FileManager.default.copyItem(at: url, to: newUrl)
                DispatchQueue.main.async {
                    let dimen = UIScreen.main.bounds.width / 2
                    let targetSize = CGSize(width: dimen, height: dimen)
                    let thumbnail = createThumbnailOfVideoFromRemoteUrl(url: newUrl.absoluteString, targetSize: targetSize) ?? UIImage()
                    let video = VideoModel(url: newUrl, thumbnail: thumbnail)
                    self?.videos.insert(video, at: 0)
                    let indexPath = IndexPath(item: 0, section: 2)
                    self?.collectionView.insertItems(at: [indexPath])
                }
            }
        }
       
    }
    
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // it's the developer’s responsibility to dismiss the PHPickerViewController upon didFinishPicking completion
        dismiss(animated: true, completion: nil)
        
        guard !results.isEmpty else { return }
        
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                // it's a video
                parseVideo(using: itemProvider)
            } else if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
                // it's a live photo
                parseLivePhoto(using: itemProvider)
            } else if itemProvider.canLoadObject(ofClass: UIImage.self) {
                // it's a photo
                parsePhoto(using: itemProvider)
            }
        }
            
    }

}



//MARK: - CollectionView Protocols
extension PhotosGridVC: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = mediaSections[indexPath.section]

        switch sectionType {
        case .photos:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.cellReuseIdentifier, for: indexPath) as! PhotoCell
            cell.imageView.image = images[indexPath.item]
            return cell
            
        case .livePhotos:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LivePhotoCell.cellReuseIdentifier, for: indexPath) as! LivePhotoCell
            cell.livePhotoView.livePhoto = livePhotos[indexPath.item]
            cell.livePhotoView.startPlayback(with: .full)
            return cell
        case .videos:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videosCellReUseid, for: indexPath) as! PhotoCell
            cell.imageView.image = videos[indexPath.item].thumbnail
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimen = view.frame.width / 3 - 1
        return CGSize(width: dimen, height: dimen)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = mediaSections[section]

        switch sectionType {
        case .photos:
            return images.count
            
        case .livePhotos:
            return livePhotos.count
            
        case .videos:
            return videos.count
        }
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return mediaSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    
    fileprivate func setUpHeaderTitleLabel(imageName: String, title: String) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: imageName)?.withTintColor(.black)
        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: " \(title) "))
        return fullString
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! TitleHeader
        let sectionType = mediaSections[indexPath.section]
        
        switch sectionType {
        case .photos:
            let attributedText = setUpHeaderTitleLabel(imageName: "photo", title: "Photos")
            header.titleLabel.attributedText = attributedText
            
        case .livePhotos:
            let attributedText = setUpHeaderTitleLabel(imageName: "livephoto", title: "Live Photos")
            header.titleLabel.attributedText = attributedText
            
        case .videos:
            let attributedText = setUpHeaderTitleLabel(imageName: "play", title: "Videos")
            header.titleLabel.attributedText = attributedText
        }
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let sectionType = mediaSections[section]
        
        switch sectionType {
        case .photos:
            let height: CGFloat = images.isEmpty ? 0 : 40
            return CGSize(width: view.frame.width, height: height)

            
        case .livePhotos:
            let height: CGFloat = livePhotos.isEmpty ? 0 : 40
            return CGSize(width: view.frame.width, height: height)

        case .videos:
            let height: CGFloat = videos.isEmpty ? 0 : 40
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    
   
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionType = mediaSections[indexPath.section]
        switch sectionType {
        case .photos:
            print("photos")

        case .livePhotos:
            guard let cell = collectionView.cellForItem(at: indexPath) as? LivePhotoCell else {return}
            cell.livePhotoView.startPlayback(with: .full)


        case .videos:
            let url = videos[indexPath.item].url
            playVideoOnFullScreen(with: url)
        }
       
                        
    }
    
    
    fileprivate func playVideoOnFullScreen(with url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        present(vc, animated: true) {
            vc.player?.play()
        }
    }
    
}




struct VideoModel {
    let url: URL
    let thumbnail: UIImage
}


func createThumbnailOfVideoFromRemoteUrl(url: String, targetSize: CGSize) -> UIImage? {
    let asset = AVAsset(url: URL(string: url)!)
    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
    assetImgGenerate.appliesPreferredTrackTransform = true
    //Can set this to improve performance if target size is known before hand
    assetImgGenerate.maximumSize = targetSize
    let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
    do {
        let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        let thumbnail = UIImage(cgImage: img)
        return thumbnail
    } catch {
      print(error.localizedDescription)
      return nil
    }
}

    
