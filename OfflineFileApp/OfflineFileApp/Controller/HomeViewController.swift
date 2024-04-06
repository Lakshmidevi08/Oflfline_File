//
//  HomeViewController.swift
//  OfflineFileApp
//
//  Created by VC on 05/04/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: - IBOutlet's
    
    @IBOutlet weak var addFolderBtn: UIButton!
    @IBOutlet weak var folderListCollectionView: UICollectionView!
    @IBOutlet weak var noFolderDisplayLbl: UILabel!
    @IBOutlet weak var createFolderView: UIView!
    @IBOutlet weak var createFolderOuterView: UIView!
    @IBOutlet weak var folderNameField: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var sortBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var colorListView: UIView!
    @IBOutlet weak var sortOuterView: UIView!
    @IBOutlet weak var colorListCollectionView: UICollectionView!
    
    //MARK: - Variable Declarations
    
    var folderNameArray: [Folder] = []
    var colorArray :[String] = ["black", "red", "yellow", "green", "blue", "brown", "purple", "orange"]
    var folderIndex = 0
    
    //MARK: - Lifecylce Methods
    
    override func viewDidLoad() {
        //        DatabaseHandler.sharedInstance.DeleteAllFromDataBase(Entityname: TableName.FolderData.rawValue)
        //DatabaseHandler.sharedInstance.DeleteAllFromDataBase(Entityname: TableName.FileData.rawValue)
        super.viewDidLoad()
        self.setDesignStyles()
        self.setupMethods()
        self.setupCollectionView()
    }
    
    //MARK: - Functions
    
    func setDesignStyles(){
        self.folderListCollectionView.isHidden = true
        self.createFolderView.isHidden = true
        self.createFolderOuterView.layer.cornerRadius = 10
        self.createBtn.isEnabled = false
        self.borderView.layer.borderColor = UIColor.black.cgColor
        self.borderView.layer.borderWidth = 1.0
        self.sortView.layer.cornerRadius = 10
        self.sortOuterView.isHidden = true
        self.colorListView.isHidden = true
    }
    
    func setupMethods(){
        self.folderNameField.delegate = self
        if let folders = DatabaseHandler.sharedInstance.fetchFolders(){
            folderNameArray = folders
        }
        if folderNameArray.count > 0{
            self.folderListCollectionView.isHidden = false
            self.noFolderDisplayLbl.isHidden = true
            self.sortBtn.isHidden = false
            self.searchBtn.isHidden = false
        }else{
            self.folderListCollectionView.isHidden = true
            self.noFolderDisplayLbl.isHidden = false
            self.sortBtn.isHidden = true
            self.searchBtn.isHidden = true
        }
        
    }
    
    func setupCollectionView(){
        self.folderListCollectionView.register(UINib(nibName: "FolderListCell", bundle: nil), forCellWithReuseIdentifier: "FolderListCell")
        self.colorListCollectionView.register(UINib(nibName: "ColorListCell", bundle: nil), forCellWithReuseIdentifier: "ColorListCell")
        self.folderListCollectionView.delegate = self
        self.folderListCollectionView.dataSource = self
        self.colorListCollectionView.delegate = self
        self.colorListCollectionView.dataSource = self
        self.folderListCollectionView.reloadData()
    }
    
    // Function to check if a folder name exists
    func isFolderNameExists(_ name: String) -> Bool {
        for folder in folderNameArray {
            if folder.name == name {
                return true
            }
        }
        return false
    }
    
    // Function to show an alert
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func getCurrentDate() -> (date: Date, formattedString: String) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: currentDate)
        return (currentDate, formattedDate)
    }
    
    //MARK: - Gesture Handler
    
    func gestureHandler(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.sortOuterView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.sortOuterView.isHidden = true
    }
    
    // MARK: - Keyboard Observers
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.createFolderOuterView.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.createFolderOuterView.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    deinit {
        // Remove observers when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Handling
    
    func animateTextField(up: Bool) {
        let movement: CGFloat = up ? -100 : 0
        UIView.animate(withDuration: 0.3) {
            self.createFolderView.transform = CGAffineTransform(translationX: 0, y: movement)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - IBActions
    
    @IBAction func didClickCancelBtn(_ sender: Any) {
        self.createFolderView.isHidden = true
        self.folderNameField.text = ""
        self.folderNameField.resignFirstResponder()
    }
    
    @IBAction func didClickCreateBtn(_ sender: Any) {
        self.folderNameField.resignFirstResponder()
        guard let text = folderNameField.text else {
            return
        }
        if isFolderNameExists(text) {
            showAlert(message: "Name already exists, enter another name")
        } else {
            self.sortBtn.isHidden = false
            self.searchBtn.isHidden = false
            self.createFolderView.isHidden = true
            self.folderNameField.text = ""
            let currentDateTuple = getCurrentDate()
            let formattedCurrentDate = currentDateTuple.formattedString
            let folderData = Folder(name: text, creationDate: formattedCurrentDate, color: "black", isFavorite: false)
            DatabaseHandler.sharedInstance.updateAndSaveFolders(folder: folderData)
        }
        
        if let folders = DatabaseHandler.sharedInstance.fetchFolders(){
            folderNameArray = folders
        }
        
        DispatchQueue.main.async {
            self.noFolderDisplayLbl.isHidden = true
            self.folderListCollectionView.isHidden = false
            self.folderListCollectionView.reloadData()
        }
    }
    
    @IBAction func didClickSortBtn(_ sender: Any) {
        self.sortOuterView.isHidden = !sortOuterView.isHidden
    }
    
    @IBAction func addFolderBtn(_ sender: Any) {
        self.createFolderView.isHidden = false
        self.folderNameField.becomeFirstResponder()
    }
    
    @IBAction func didClickNameDateSortBtn(_ sender: UIButton) {
        self.sortOuterView.isHidden = true
        if sender.tag == 0{
            folderNameArray.sort { $0.name < $1.name }
            self.folderListCollectionView.reloadData()
        }else{
            folderNameArray.sort { $0.creationDate < $1.creationDate }
            self.folderListCollectionView.reloadData()
        }
    }
    
    @IBAction func didClickCancelColorBtn(_ sender: Any) {
        self.colorListView.isHidden = true
    }
    
    @IBAction func didClickSearchBtn(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let nextPage = storyBoard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        nextPage.isFromFile = false
        self.navigationController?.pushViewController(nextPage, animated: true)
    }
    
    @objc func didClickFavouriteBtn(_ sender: UIButton){
        let folder = folderNameArray[sender.tag]
        DatabaseHandler.sharedInstance.updateAndSaveFolders(folderName: folder.name, newIsFavorite: !folder.isFavorite)
        if let folders = DatabaseHandler.sharedInstance.fetchFolders(){
            folderNameArray = folders
        }
        self.folderListCollectionView.reloadData()
    }
    
    @objc func didClickEditBtn(_ sender: UIButton){
        self.folderIndex = sender.tag
        self.colorListView.isHidden = false
        self.colorListCollectionView.reloadData()
    }
}

//MARK: - Textfield Delegate

extension HomeViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        createBtn.isEnabled = !(folderNameField.text?.isEmpty ?? true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if the replacement string is empty
        guard !string.isEmpty else {
            return true
        }
        // Check if the replacement string is being added at the beginning of the text
        if range.location == 0 {
            let capitalizedString = string.uppercased()
            textField.text = (textField.text as NSString?)?.replacingCharacters(in: range, with: capitalizedString)
            return false
        }
        
        let pattern = "^[a-zA-Z0-9]*$"
        if string.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil {
            return true
        }
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return false
        }
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        return !matches.isEmpty
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateTextField(up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateTextField(up: false)
    }
}

//MARK: - Collection View Delegate and Datasource

extension HomeViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == folderListCollectionView{
            return folderNameArray.count
        }else{
            return colorArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == folderListCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderListCell", for: indexPath) as! FolderListCell
            let folder = folderNameArray[indexPath.item]
            cell.folderName.text = folder.name
            cell.createdDateLbl.text = folder.creationDate
            cell.folderIcon.tintColor = UIColor.colorFromString(folder.color)
            cell.favouriteBtn.tag = indexPath.item
            cell.editBtn.tag = indexPath.item
            cell.favouriteBtn.addTarget(self, action: #selector(didClickFavouriteBtn(_:)), for: .touchUpInside)
            cell.editBtn.addTarget(self, action: #selector(didClickEditBtn(_:)), for: .touchUpInside)
            if folder.isFavorite == true{
                let image = UIImage(named: "fav_icon")
                cell.favouriteBtn.setImage(image, for: .normal)
            }else{
                let image = UIImage(named: "unfav_icon")
                cell.favouriteBtn.setImage(image, for: .normal)
            }
            
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorListCell", for: indexPath) as! ColorListCell
            
            cell.innerView.backgroundColor = UIColor.colorFromString(colorArray[indexPath.item])
            
            cell.innerView.layer.cornerRadius = cell.innerView.frame.size.height/2
            cell.outerView.isHidden = true
            
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == folderListCollectionView{
            let width = (collectionView.bounds.width - 30) / 2
            let height: CGFloat = 150
            return CGSize(width: width, height: height)
        }else{
            return CGSize(width: 80, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == folderListCollectionView{
            let storyBoard : UIStoryboard = UIStoryboard(name:"Main", bundle:Bundle.main)
            let secondViewController = storyBoard.instantiateViewController(withIdentifier: "FilesViewController") as! FilesViewController
            secondViewController.selectedFolderName = folderNameArray[indexPath.item].name
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }else{
            DatabaseHandler.sharedInstance.updateAndSaveFolders(folderName: folderNameArray[folderIndex].name, newColor: colorArray[indexPath.item])
            self.colorListView.isHidden = true
            if let folders = DatabaseHandler.sharedInstance.fetchFolders(){
                folderNameArray = folders
            }
            self.folderListCollectionView.reloadData()
        }
    }
}
