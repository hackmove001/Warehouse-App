//
//  DatabaseManager.swift
//  Warehouse App
//
//  Created by Anh Dinh on 4/10/22.
//

import Foundation
import UIKit
import FirebaseDatabase

final class DatabaseManager {
    public static let shared = DatabaseManager()
    private let database = Database.database().reference()
    private init() {}
    private var readDataValues: [String:Int] = [:]
    
    public func insertItems(item: String, quantity: Int, completion: @escaping (Bool)->Void){
        database.child("Items").childByAutoId().observeSingleEvent(of: .value) { [weak self] snapshot in
            // check if there's a node of "Items" and its value
            guard var itemsDictionary = snapshot.value as? [String:Any] else {
                // Nếu ko có "Items", tạo node "Items"
                // childByAutoID() generates an auto unique ID for each node of an item.
                self?.database.child("Items").childByAutoId().setValue(
                    [
                        "Item": item,
                        "Quantity":quantity
                    ]
                ){error,_ in
                    guard error == nil else {
                        // trả về false, case này là lần đầu tạo "Items" node
                        completion(false)
                        return
                    }
                    // Trả về true nếu tạo thành công "Items"
                    completion(true)
                }
                return
            }
            itemsDictionary["Item"] = item
            itemsDictionary["Quantity"] = quantity
            self?.database.child("Items").childByAutoId().setValue(itemsDictionary){ error,_ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    public func insertItems_2(item: String, quantity: Int, completion: @escaping (Bool)->Void){
        database.child("Items").observeSingleEvent(of: .value) { [weak self] snapshot in
            // check if there's a node of "Items" and its value
            guard var itemsDictionary = snapshot.value as? [String:Int] else {
                // Nếu ko có "Items", tạo node "Items"
                self?.database.child("Items").setValue(
                    [
                        item: quantity
                    ]
                ){error,_ in
                    guard error == nil else {
                        // trả về false, case này là lần đầu tạo "Items" node
                        completion(false)
                        return
                    }
                    // Trả về true nếu tạo thành công "Items"
                    completion(true)
                }
                return
            }
            itemsDictionary[item] = quantity
            self?.database.child("Items").setValue(itemsDictionary){ error,_ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
        
    public func readItems(completion: @escaping ([String:Any]?)->Void){
        // (withPath: "Items").observe(.childAdded) get what under "Items" including key and what underneath it
        // snaphot.values la tung thang dictionary rieng re
        Database.database().reference(withPath: "Items").observe(.childAdded){snapshot in
            // snaphost.value = what underneath the key ID
            guard let values = snapshot.value as? [String:Any]  else {
                print("Error reading data")
                return
            }
            print("values in DBManager call: \(values)")
            completion(values)
        }
    }
    
    public func update(){
        
    }
}
