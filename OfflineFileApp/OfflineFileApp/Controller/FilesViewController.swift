//
//  FilesViewController.swift
//  OfflineFileApp
//
//  Created by VC on 02/04/24.
//

import UIKit
import QuickLook
import WebKit


class FilesViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {
    
    //MARK: - IBOutlet's
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var photoFilesOuterView: UIView!
    @IBOutlet weak var photoFilesView: UIView!
    @IBOutlet weak var photoFilesBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var noFilesFoundLbl: UILabel!
    @IBOutlet weak var photosView: UIView!
    @IBOutlet weak var filesView: UIView!
    @IBOutlet weak var filesCollectionsView: UICollectionView!
    
    //MARK: - Variable Declarations
    var selectedImages: [UIImage] = []
    var selectedFolderName = String()
    var selectedFolderFiles : [File] = []
    var selectedURL: URL?
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUIDesignStyles()
        self.setupMethods()
    }
    
    //MARK: - Functions
    func setupMethods(){
        if let files = DatabaseHandler.sharedInstance.fetchFiles(folderName: selectedFolderName){
            selectedFolderFiles = files
        }
        headerLbl.text = selectedFolderName
        if selectedFolderFiles.isEmpty{
            self.noFilesFoundLbl.isHidden = false
            self.filesCollectionsView.isHidden = true
        }else{
            self.noFilesFoundLbl.isHidden = true
            self.filesCollectionsView.isHidden = false
        }
        self.setupGestureRecognizers()
        self.setupCollectionView()
    }
    
    func setupCollectionView(){
        self.filesCollectionsView.register(UINib(nibName: "FilesViewCell", bundle: nil), forCellWithReuseIdentifier: "FilesViewCell")
        self.filesCollectionsView.delegate = self
        self.filesCollectionsView.dataSource = self
        self.filesCollectionsView.reloadData()
        self.filesCollectionsView.isUserInteractionEnabled = true
    }
    
    func setUIDesignStyles(){
        self.navigationItem.hidesBackButton = true
        self.photoFilesBtn.layer.cornerRadius = self.photoFilesBtn.frame.size.height / 2
        self.photoFilesBtn.layer.borderColor = UIColor.black.cgColor
        self.photoFilesBtn.layer.borderWidth = 1.0
        self.photosView.layer.cornerRadius = 10
        self.filesView.layer.cornerRadius = 10
        self.photosView.layer.masksToBounds = true
        self.filesView.layer.masksToBounds = true
        self.photosView.layer.borderColor = UIColor.black.cgColor
        self.filesView.layer.borderColor = UIColor.black.cgColor
        self.photosView.layer.borderWidth = 1.0
        self.filesView.layer.borderWidth = 1.0
    }
    
    func getDisplayImage(documentType: String) -> String{
        switch documentType{
        case DocumentDataType.Pdf.rawValue:
            return "pdf_icon"
        case DocumentDataType.Word.rawValue:
            return "word_icon"
        case DocumentDataType.Excel.rawValue:
            return "excel_icon"
        case DocumentDataType.PowerPoint.rawValue:
            return "ppt_iocn"
        case DocumentDataType.Text.rawValue:
            return "text_icon"
        default:
            return "unknown_icon"
        }
    }
    
    func documentType(fromPath path: String) -> String? {
        let words = path.components(separatedBy: ["_", "."])
        if let type = words.last{
            switch type {
            case "pdf":
                return "Pdf"
            case "txt":
                return "Text"
            case "jpg", "jpeg", "png", "gif":
                return "Image"
            case "xlsx","xls":
                return "Excel"
            case "docx", "doc":
                return "Word"
            case "pptx":
                return "PowerPoint"
            case "zip":
                return "Zip"
            default:
                return "Others"
            }
        }else{
            return "Others"
        }
    }
    
    func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    //MARK: - Gesture Methods
    
    func setupGestureRecognizers(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        let tapPhotoGesture = UITapGestureRecognizer(target: self, action: #selector(handlePhotoTap(_:)))
        self.photosView.addGestureRecognizer(tapPhotoGesture)
        let tapFileGesture = UITapGestureRecognizer(target: self, action: #selector(handleFileTap(_:)))
        self.filesView.addGestureRecognizer(tapFileGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.photoFilesOuterView.isHidden = true
    }
    
    @objc  func handlePhotoTap(_ gesture: UITapGestureRecognizer) {
        print("View tapped!")
        self.photoFilesOuterView.isHidden = true
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc  func handleFileTap(_ gesture: UITapGestureRecognizer) {
        // Handle tap action here
        print("View tapped!")
        self.photoFilesOuterView.isHidden = true
        self.presentDocumentPicker()
    }
    
    //MARK: - IBAction's
    
    @IBAction func addPhotoFileBtn(_ sender: Any) {
        self.photoFilesOuterView.isHidden = false
    }
    
    @IBAction func didClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didClickSearchBtn(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let nextPage = storyBoard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        nextPage.isFromFile = true
        nextPage.fileName = selectedFolderName
        self.navigationController?.pushViewController(nextPage, animated: true)
    }
    
    @objc func selectedBtn(_ sender: UIButton){
        let fileDetails = selectedFolderFiles[sender.tag]
        if fileDetails.type == "Zip" || fileDetails.type == "Others"{
            self.showToast(message: "Unable to preview, Unsupported fie format")
        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle:Bundle.main)
            let secondViewController = storyBoard.instantiateViewController(withIdentifier: "FilePreviewViewController") as! FilePreviewViewController
            secondViewController.selectedFile = fileDetails
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    
    //MARK: - Image Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the URL of the picked image file
        
        if let imageData = info[.originalImage] as? UIImage,
           let data = imageData.jpegData(compressionQuality: 1.0),
           let imageUrl = info[.imageURL] as? URL
        {
            let imageName = imageUrl.lastPathComponent
            if  let documentType = documentType(fromPath: imageName){
                let file = File(name: imageName, type: documentType, imageData: data, path: imageUrl.absoluteString, folderName: selectedFolderName)
                DatabaseHandler.sharedInstance.updateAndSaveFiles(file: file, folderName: selectedFolderName)
                if let files = DatabaseHandler.sharedInstance.fetchFiles(folderName: selectedFolderName){
                    selectedFolderFiles = files
                }
                self.filesCollectionsView.isHidden = false
                self.filesCollectionsView.reloadData()
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -  UIDocumentPickerDelegate method
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            // No URL found
            print("No document selected")
            return
        }
        do {
            let documentData = try Data(contentsOf: url)
            // Extract file name from URL
            let fileName = url.lastPathComponent
            if let documentType = documentType(fromPath: fileName.lowercased()){
                print("Document type: \(documentType)")
                let data = File(name: fileName, type: documentType, imageData: documentData, path: url.absoluteString, folderName: selectedFolderName)
                DatabaseHandler.sharedInstance.updateAndSaveFiles(file: data)
                if let files = DatabaseHandler.sharedInstance.fetchFiles(folderName: selectedFolderName){
                    selectedFolderFiles = files
                }
                self.filesCollectionsView.isHidden = false
                self.filesCollectionsView.reloadData()
            } else {
                print("Unsupported document type")
            }
        } catch {
            print("Error reading document data: \(error)")
        }
    }
}

//MARK: - Collection view Delegate and Datasource
extension FilesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFolderFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilesViewCell", for: indexPath) as! FilesViewCell
        
        let fileDetails = selectedFolderFiles[indexPath.item]
        cell.nameLbl.text = fileDetails.name
        cell.isUserInteractionEnabled = true
        cell.selectedBtn.tag = indexPath.item
        cell.selectedBtn.tag = indexPath.item
        cell.selectedBtn.addTarget(self, action: #selector(selectedBtn(_:)), for: .touchUpInside)
        if fileDetails.type == DocumentDataType.Image.rawValue{
            cell.uploadImg.isHidden = false
            cell.documentView.isHidden = true
            cell.uploadImg.image = UIImage(data: fileDetails.imageData)
            cell.displayImg.image = UIImage(named: "image_icon")
        }
        else if fileDetails.type == DocumentDataType.Zip.rawValue{
            cell.uploadImg.isHidden = false
            cell.documentView.isHidden = true
            cell.uploadImg.image = UIImage(named: "zip_icon")
            cell.displayImg.image = UIImage(named: "zip1_icon")
        }
        else{
            cell.uploadImg.isHidden = true
            cell.documentView.isHidden = false
            if let documentURL = URL(string: fileDetails.path) {
                let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: cell.documentView.bounds.width, height: cell.documentView.bounds.height))
                webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                webView.load(URLRequest(url: documentURL))
                cell.documentView.addSubview(webView)
                cell.displayImg.image = UIImage(named: getDisplayImage(documentType: fileDetails.type))
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 40) / 2
        return CGSize(width: width, height: 200.0)
    }
}
