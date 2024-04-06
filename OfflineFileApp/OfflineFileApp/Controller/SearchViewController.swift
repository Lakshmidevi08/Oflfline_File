//
//  SearchViewController.swift
//  OfflineFileApp
//
//  Created by VC on 05/04/24.
//

import UIKit

class SearchViewController: UIViewController {
    
    //MARK: - IBOutLet's
    @IBOutlet weak var searchListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var noSearchFoundLbl: UILabel!
    
    //MARK: - Variable Declarations
    var files : [File] = []
    var folders : [Folder] = []
    var selectedFile : [File] = []
    var selectedFolder : [Folder] = []
    var isFromFile = Bool()
    var fileName = String()
    
    //MARK: - LifeCyle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMethods()
    }
    
    //MARK: - Functions
    
    func setupMethods(){
        self.navigationItem.hidesBackButton = true
        if isFromFile == true{
            if let file = DatabaseHandler.sharedInstance.fetchFiles(folderName: fileName){
                files = file
            }
            folders = []
        }else{
            if let folder = DatabaseHandler.sharedInstance.fetchFolders(){
                folders = folder
            }
            if let file = DatabaseHandler.sharedInstance.fetchAllFiles(){
                files = file
            }
        }
        self.searchBar.becomeFirstResponder()
        self.navigationItem.hidesBackButton = true
        self.noSearchFoundLbl.isHidden = true
        self.searchBar.delegate = self
        self.setupTableView()
    }
    
    func setupTableView(){
        self.searchListTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        self.searchListTableView.delegate = self
        self.searchListTableView.dataSource = self
        self.searchListTableView.reloadData()
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
    
    func searchName(_ name: String) {
        let searchText = name.lowercased()
        self.selectedFile = files.filter { $0.name.lowercased().contains(searchText) }
            .map { file in
                let originalName = file.name
                if originalName.lowercased().contains(searchText) {
                    return file
                } else {
                    return nil
                }
            }
            .compactMap { $0 }
        self.selectedFolder = folders.filter { $0.name.lowercased().contains(searchText) }
            .map { folder in
                let originalName = folder.name
                if originalName.lowercased().contains(searchText) {
                    return folder
                } else {
                    return nil
                }
            }
            .compactMap { $0 }
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    
    func reloadData(){
        if selectedFile.isEmpty && selectedFolder.isEmpty{
            self.noSearchFoundLbl.isHidden = false
            self.searchListTableView.isHidden = true
        }else{
            self.noSearchFoundLbl.isHidden = true
            self.searchListTableView.isHidden = false
            self.searchListTableView.reloadData()
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func didClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - TextField Delegate

extension SearchViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchName(searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.contains(" ") {
            return false
        }
        return true
    }
}

//MARK: - TableView Delegate and Datasource Methods

extension SearchViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? selectedFolder.count : selectedFile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        if indexPath.section == 0{
            cell.imgView.image = UIImage(named: "add_file")
            cell.nameLbl.text = selectedFolder[indexPath.row].name
        }else{
            cell.imgView.image = UIImage(named: getDisplayImage(documentType: selectedFile[indexPath.row].type))
            cell.nameLbl.text = selectedFile[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print("section 0",indexPath.row)
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle:Bundle.main)
            let secondViewController = storyBoard.instantiateViewController(withIdentifier: "FilesViewController") as! FilesViewController
            secondViewController.selectedFolderName = selectedFolder[indexPath.row].name
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else{
            let fileDetails = selectedFile[indexPath.row]
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle:Bundle.main)
            let secondViewController = storyBoard.instantiateViewController(withIdentifier: "FilePreviewViewController") as! FilePreviewViewController
            secondViewController.selectedFile = fileDetails
            self.navigationController?.pushViewController(secondViewController, animated: true)
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}
