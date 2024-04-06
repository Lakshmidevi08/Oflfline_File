//
//  DatabaseHandler.swift
//  OfflineFileApp
//
//  Created by VC on 03/04/24.
//

import UIKit
import CoreData
public enum TableName : String{
    case FolderData = "FolderData"
    case FileData = "DocumentData"
}

class DatabaseHandler: NSObject {
    
    static let sharedInstance = DatabaseHandler()
    
    func getContext () -> NSManagedObjectContext {
        return AppDelegate.sharedInstance.persistentContainer.viewContext
    }
    
    //MARK: - Fetch Data
    func fetchFolders() -> [Folder]? {
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TableName.FolderData.rawValue)
        do {
            // Perform the fetch request
            let result = try context.fetch(fetchRequest)
            var folders: [Folder] = []
            
            // Process fetched results
            for data in result as? [NSManagedObject] ?? [] {
                if let name = data.value(forKey: "name") as? String,
                   let creationDate = data.value(forKey: "creationDate") as? String,
                   let color = data.value(forKey: "color") as? String,
                   let isFavorite = data.value(forKey: "isFavorite") as? Bool {
                    // Create a Folder object and append to the array
                    let folder = Folder(name: name, creationDate: creationDate, color: color, isFavorite: isFavorite)
                    folders.append(folder)
                }
            }
            return folders
        } catch {
            print("Failed to fetch folders: \(error)")
            return nil
        }
    }
    
    func fetchFiles(folderName:String) -> [File]? {
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TableName.FileData.rawValue)
        fetchRequest.predicate = NSPredicate(format: "folderName = %@", folderName)
        
        do {
            // Perform the fetch request
            let result = try context.fetch(fetchRequest)
            var files: [File] = []
            if result.count > 0 {
                // Process fetched results
                for data in result as? [NSManagedObject] ?? [] {
                    if let name = data.value(forKey: "name") as? String,
                       let path = data.value(forKey: "path") as? String,
                       let imageData = data.value(forKey: "imageData") as? Data,
                       let type = data.value(forKey: "type") as? String,
                       let folderName = data.value(forKey: "folderName") as? String {
                        // Create a Folder object and append to the array
                        let file = File(name: name, type: type,imageData: imageData, path: path, folderName: folderName)
                        files.append(file)
                    }
                }
            }
            return files
        } catch {
            print("Failed to fetch folders: \(error)")
            return nil
        }
    }
    
    func fetchAllFiles() -> [File]? {
        let context = self.getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TableName.FileData.rawValue)
        
        do {
            // Perform the fetch request
            let result = try context.fetch(fetchRequest)
            var files: [File] = []
            if result.count > 0 {
                // Process fetched results
                for data in result as? [NSManagedObject] ?? [] {
                    if let name = data.value(forKey: "name") as? String,
                       let path = data.value(forKey: "path") as? String,
                       let imageData = data.value(forKey: "imageData") as? Data,
                       let type = data.value(forKey: "type") as? String,
                       let folderName = data.value(forKey: "folderName") as? String {
                        // Create a Folder object and append to the array
                        let file = File(name: name, type: type,imageData: imageData, path: path, folderName: folderName)
                        files.append(file)
                    }
                }
            }
            return files
        } catch {
            print("Failed to fetch folders: \(error)")
            return nil
        }
    }
    
    
    //MARK: - Update and Save Data
    func updateAndSaveFolders(folder: Folder? = nil,folderName: String? = nil, newColor: String? = nil, newIsFavorite: Bool? = nil)
    {
        let context = getContext()
        //fetch the record
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: TableName.FolderData.rawValue, in: context)
        if let name = folderName{
            fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        }
        
        do
        {
            let fetchedResult = try context.fetch(fetchRequest)
            if fetchedResult.count > 0 && folder == nil{
                let objectUpdate = fetchedResult[0]  as! NSManagedObject
                if let color = newColor{
                    objectUpdate.setValue(color, forKey: "color")
                }
                if let fav = newIsFavorite{
                    objectUpdate.setValue(fav, forKey: "isFavorite")
                }
                
                do{
                    try context.save()
                }
                catch
                {
                    print(error)
                }
            }else{
                //save if record not exists
                let entity =    NSEntityDescription.entity(forEntityName: TableName.FolderData.rawValue, in: context)
                let folderObject = NSManagedObject(entity: entity!, insertInto: context)
                if let folder = folder{
                    do{
                        folderObject.setValue(folder.name, forKey: "name")
                        folderObject.setValue(folder.creationDate, forKey: "creationDate")
                        folderObject.setValue(folder.color, forKey: "color")
                        folderObject.setValue(folder.isFavorite, forKey: "isFavorite")
                    }
                }
                do {
                    try context.save()
                }
                catch let error {
                    print("the insert error is \(error.localizedDescription)")
                }
            }
        }
        catch
        {
            print(error)
        }
    }
    
    func updateAndSaveFiles(file:File, folderName:String? = nil){
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: TableName.FileData.rawValue, in: context)
        let entity =    NSEntityDescription.entity(forEntityName: TableName.FileData.rawValue, in: context)
        let folderObject = NSManagedObject(entity: entity!, insertInto: context)
        do{
            folderObject.setValue(file.name, forKey: "name")
            folderObject.setValue(file.path, forKey: "path")
            folderObject.setValue(file.type, forKey: "type")
            folderObject.setValue(file.imageData, forKey: "imageData")
            folderObject.setValue(file.folderName, forKey: "folderName")
        }
        do {
            try context.save()
        }
        catch let error {
            print("the insert error is \(error.localizedDescription)")
        }
    }
    
    func DeleteAllFromDataBase(Entityname:String?) {
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: Entityname!, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname!)
        fetchRequest.entity = entity
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}
