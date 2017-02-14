//
//  SQLite.swift
//  MoreSQL
//
//  Created by zhi zhou on 2017/1/17.
//  Copyright © 2017年 zhi zhou. All rights reserved.
//

import UIKit
import FMDB

class SQLite: NSObject {
    // MARK:- 属性
    static let shared = SQLite()
    
    /// 是否开启打印
    var isPrint = true
    
    /// 表名称
    fileprivate var tableName: String?
    
    /// 路径
    fileprivate var dbPath: String?
    
    /// 数据库
    fileprivate var db: FMDatabase?
    
    // MARK:- 方法
    // MARK: >>> 开启数据库
    /// 开启数据库
    /// - parameter pathName: 数据库存放路径
    /// - parameter tableName: 表名
    func openDB(pathName: String? = nil, tableName: String) -> Bool {
        if let pathName = pathName {
            return packOpen(pathName, tableName)
        } else {
            return packOpen("data", tableName)
        }
    }
    
    // 封装开启方法
    fileprivate func packOpen(_ pathName: String, _ tableName: String) -> Bool {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        path = path + "/" + pathName + ".sqlite"
        dbPath = path
        
        db = FMDatabase(path: path)
        if (db?.open())! {
            self.tableName = tableName
            _ = createTable()
            remind("数据库开启成功")
            return true
        } else {
            remind("数据库开启失败")
            return false
        }
    }
    
    // MARK: >>> 创建表
    /// 创建表
    fileprivate func createTable() -> Bool {
        db?.open()
        // "CREATE TABLE IF NOT EXISTS \(tableName!) (id INTEGER PRIMARY KEY AUTOINCREMENT,btnID TEXT,status TEXT,remark TEXT,title TEXT);"
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName!) (id INTEGER PRIMARY KEY AUTOINCREMENT,btnID TEXT,status BLOB,remarks BLOB,title TEXT);"
        
        if (db?.executeUpdate(sql, withArgumentsIn: nil))! {
            remind("创建表成功")
            db?.close()
            return true
        } else {
            remind("创建表失败")
            db?.close()
            return false
        }
    }
    
    // MARK: >>> 插入数据
    /// 插入数据
    /// - parameter objc: 传入非自定义类型
    /// - parameter inTable: 需要操作的表名
    func insert(id: String, statusDict: Any, remarksDict: Any, inTable: String? = nil) -> Bool {
        db?.open()
        db?.beginTransaction()
        
        var sql: String?
        if inTable == nil {
            sql = "INSERT INTO \(tableName!) (btnID,status,remarks,title) VALUES (?,?,?,?);"
        } else {
            sql = "INSERT INTO \(inTable!) (btnID,status,remarks,title) VALUES (?,?,?,?);"
        }
        let title = "nil"
        
        let status = toJson(objc: statusDict)
        let remarks = toJson(objc: remarksDict)
        
        if (db?.executeUpdate(sql, withArgumentsIn: [id, status!, remarks!, title]))! {
            remind("插入数据成功")
            db?.commit()
            db?.close()
            return true
        } else {
            remind("插入数据失败")
            db?.rollback()
            db?.close()
            return false
        }
    }
    
    func insert (title: String, inTable: String? = nil) -> Bool {
        db?.open()
        db?.beginTransaction()
        
        var sql: String?
        if inTable == nil {
            sql = "INSERT INTO \(tableName!) (title) VALUES (?);"
        } else {
            sql = "INSERT INTO \(inTable!) (title) VALUES (?);"
        }
        
        if (db?.executeUpdate(sql, withArgumentsIn: [title]))! {
            remind("插入数据成功")
            db?.commit()
            db?.close()
            return true
        } else {
            remind("插入数据失败")
            db?.rollback()
            db?.close()
            return false
        }
    }
    
    // MARK: >>> 查询数据
    /// 查询所有数据
    /// - parameter inTable: 需要操作的表名
    func queryAll(inTable: String? = nil) -> [Any]? {
        var sql: String?
        if inTable == nil {
            sql = "SELECT btnID,status,remarks FROM \(tableName!);"
        } else {
            sql = "SELECT btnID,status,remarks FROM \(inTable!);"
        }
        
        return packQuery(sql: sql!)
    }
    
    func queryAllTitle(inTable: String? = nil) -> [Any]? {
        var sql: String?
        if inTable == nil {
            sql = "SELECT title FROM \(tableName!);"
        } else {
            sql = "SELECT title FROM \(inTable!);"
        }
        
        return packQuery(sql: sql!, isFull: false)
    }
    
    /// 查询符合ID条件的数据
    /// - parameter inTable: 需要操作的表名
    /// - parameter id: 查询ID符合条件的数据
    func query(inTable: String? = nil, id: String) -> [Any]? {
        var sql: String?
        if inTable == nil {
            sql = "SELECT btnID,status,remarks FROM \(tableName!) WHERE btnID = '\(id)';"
        } else {
            sql = "SELECT btnID,status,remarks FROM \(inTable!) WHERE btnID = '\(id)';"
        }
        
        return packQuery(sql: sql!, isFull: true)
    }
    
    /// 封装查询
    /// - parameter sql: 查询语句
    /// - parameter isFull: 是否获取全部数据（默认：true）
    fileprivate func packQuery(sql: String, isFull: Bool = true) -> [Any]? {
        db?.open()
        
        let set = db?.executeQuery(sql, withArgumentsIn: nil)
        
        guard set != nil else {
            return nil
        }
        
        var tempArray = [Any]()
        while set!.next() {
            let id = set?.object(forColumnName: "btnID")
            let status = set?.object(forColumnName: "status")
            let remark = set?.object(forColumnName: "remarks")
            let title = set?.object(forColumnName: "title")
            if let id = id, let status = status, let remarks = remark, let title = title {
                if isFull {
                    let statusDict = jsonToAny(json: status as! String)
                    let remarksDict = jsonToAny(json: remarks as! String)
                    
                    tempArray.append(id)
                    tempArray.append(statusDict!)
                    tempArray.append(remarksDict!)
                } else {
                    if title as! String != "nil" {
                        tempArray.append(title)
                    }
                }
            }
        }
        
        db?.close()
        
        return tempArray
    }
    
    // MARK: >>> 更新数据
    /// 根据ID更新某个数据
    /// - parameter newValue: 传入非自定义类型
    /// - parameter inTable: 需要操作的表名
    func update(id: String, statusDict: Any, remarksDict: Any, inTable: String? = nil) -> Bool {
        db?.open()
        db?.beginTransaction()
        
        let status = toJson(objc: statusDict)
        let remarks = toJson(objc: remarksDict)
        
        // e.g.: 更新 ID = 6 的数据
        // "UPDATE \(tableName) SET js = '\(js!)'; WHERE ID = 6"
        // "UPDATE \(tableName!) SET js = '\(js!)' WHERE btnID = 'zz123';"
        var sql: String?
        if inTable == nil {
            sql = "UPDATE \(tableName!) SET status = ?, remarks = ? WHERE btnID = ?;"
        } else {
            sql = "UPDATE \(inTable!) SET status = ?, remarks = ? WHERE btnID = ?;"
        }
        
        if (db?.executeUpdate(sql, withArgumentsIn: [status!, remarks!, id]))! {
            remind("修改成功")
            db?.commit()
            db?.close()
            return true
        } else {
            remind("修改失败")
            db?.rollback()
            db?.close()
            return false
        }
    }
    
    // MARK: >>> 删除数据 (全部)
    /// 删除 (全部) 数据
    /// - parameter inTable: 需要操作的表名
    func deleteAll(inTable: String? = nil) -> Bool {
        db?.open()
        // 删除所有 或 where ..... 来进行判断筛选删除
        var sql: String?
        if inTable == nil {
            sql = "DELETE FROM \(tableName!);"
        } else {
            sql = "DELETE FROM \(inTable!);"
        }
        
        if (db?.executeUpdate(sql, withArgumentsIn: nil))! {
            remind("删除成功")
            db?.close()
            return true
        } else {
            remind("删除失败")
            db?.close()
            return false
        }
    }
    
}

// MARK:- 本地数据大小
extension SQLite {
    /// 本地数据大小
    func dataSize() -> String {
        var dataSize: Int = 0
        if let dbPath = dbPath {
            if FileManager.default.fileExists(atPath: dbPath) {
                if let dict = try? FileManager.default.attributesOfItem(atPath: dbPath) {
                    dataSize += dict[FileAttributeKey("NSFileSize")] as! Int
                }
            }
        }
        
        // KB
        let sizeKB = dataSize / 1024
        
        if sizeKB < 1024 {
            return "\(sizeKB)KB"
        } else if sizeKB >= 1024, sizeKB < 1024 * 1024 {
            // MB
            let sizeMB = simplification(value: sizeKB)
            return "\(String(format: "%.2f", sizeMB))MB"
        } else {
            // GB ~
            let sizeHuge = simplification(value: sizeKB)
            return "\(String(format: "%.2f", sizeHuge))GB"
        }
    }
    
    /// 简化显示
    fileprivate func simplification(value: Int) -> Double {
        if value < 1000 {
            return Double(value)
        } else {
            let simplificationValue = Double(value) * 0.001
            return simplificationValue
        }
    }

}

// MARK:- JSON、ANY 转换
extension SQLite {
    /// **Any** 转换为 **JSON** 类型
    /// - parameter objc: 传入非自定义类型
    func toJson(objc: Any) -> String? {
        let data = try? JSONSerialization.data(withJSONObject: objc, options: .prettyPrinted)
        if let data = data {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    /// **JSON** 转换为 **Any** 类型
    /// - parameter json: String 类型数据
    func jsonToAny(json: String) -> Any? {
        let data = json.data(using: .utf8)
        if let data = data {
            let anyObjc = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let anyObjc = anyObjc {
                return anyObjc
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
}

// MARK:- 自定义 print 打印
extension SQLite {
    /// 根据 **isPrint** 的值来决定是否打印
    /// - parameter message: 打印信息
    fileprivate func remind(_ message: String) {
        if isPrint {
            printDBug(message, isDetail: false)
        }
    }
    
    /// 仅在 Debug 模式下打印
    /// - parameter info: 打印信息
    /// - parameter fileName: 打印所在的swift文件
    /// - parameter methodName: 打印所在文件的类名
    /// - parameter lineNumber: 打印事件发生在哪一行
    /// - parameter isDetail: 是否打印详细信息 (默认: true)
    fileprivate func printDBug<T>(_ info: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line, isDetail: Bool = true) {
        let file = (fileName as NSString).pathComponents.last!
        #if DEBUG
            if isDetail {
                print("\(file) -> \(methodName) [line \(lineNumber)]: \(info)")
            } else {
                print(info)
            }
        #endif
    }
    
}
