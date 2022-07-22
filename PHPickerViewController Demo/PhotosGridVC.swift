//
//  PhotosGridVC.swift
//  PHPickerViewController Demo
//
//  Created by Osaretin Uyigue on 7/18/22.
//

import UIKit
import PhotosUI

class PhotosGridVC: UICollectionViewController {
    
    //MARK: - View's LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpCollectionView()
    }
    
    
    //MARK: - Properties
    fileprivate var images: [UIImage] = []
    
    
    
    //MARK: - Methods
    fileprivate func setUpCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.cellReuseIdentifier)
    }
    
    
    fileprivate func setUpNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "PHPickerViewController Demo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(setUpImagePicker))
    }
    
    
   @objc fileprivate func setUpImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .automatic
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}


//MARK: - PHPickerViewControllerDelegate
extension PhotosGridVC: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

           // it's the developer’s responsibility to dismiss the PHPickerViewController upon didFinishPicking completion
            dismiss(animated: true, completion: nil)
            guard !results.isEmpty else { return }
            
            
            for result in results {

                let itemProvider = result.itemProvider
                
                if itemProvider.canLoadObject(ofClass: UIImage.self) {

                    itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in

                        DispatchQueue.main.async {

                            if let image = image as? UIImage {

                                self.images.append(image)
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }

}



//MARK: - CollectionView Protocols
extension PhotosGridVC: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.cellReuseIdentifier, for: indexPath) as! PhotoCell
        cell.backgroundColor = .red
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimen = view.frame.width / 3 - 1
        return CGSize(width: dimen, height: dimen)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
