//
//  LocalCollection.swift
//  MakeFairytale
//
//  Created by ByungHoon Ann on 2020/04/17.
//  Copyright © 2020 ByungHoon Ann. All rights reserved.
//

import Firebase

public protocol DocumentSerializable {

  /// Initializes an instance from a Firestore document. May fail if the
  /// document is missing required fields.
  init?(document: QueryDocumentSnapshot)

  /// Initializes an instance from a Firestore document. May fail if the
  /// document does not exist or is missing required fields.
  init?(document: DocumentSnapshot)

  /// The documentID of the object in Firestore.
  var documentID: String { get }

  /// The representation of a document-serializable object in Firestore.
  var documentData: [String: Any] { get }

}

final class LocalCollection<T: DocumentSerializable> {
    
    private(set) var items: [T]
    private(set) var documents: [DocumentSnapshot] = []
    let query: Query
    
    private let updateHandler: ([DocumentChange]) -> ()
    
    private var listener: ListenerRegistration? {
        didSet {
            oldValue?.remove()
        }
    }
    
    var count: Int {
        return self.items.count
    }
    
    subscript(index: Int) -> T {
        return self.items[index]
    }
    
    init(query: Query, updateHandler: @escaping ([DocumentChange]) -> ()) {
        self.items = []
        self.query = query
        self.updateHandler = updateHandler
    }
    
    func index(of document: DocumentSnapshot) -> Int? {
        for i in 0 ..< documents.count {
            if documents[i].documentID == document.documentID {
                return i
            }
        }
        
        return nil
    }
    
    func listen() {
        guard listener == nil else { return }
        listener = query.addSnapshotListener { [unowned self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            let models = snapshot.documents.map { (document) -> T in
                if let model = T(document: document) {
                    return model
                } else {
                    // handle error
                    fatalError("Unable to initialize type \(T.self) with dictionary \(document.data())")
                }
            }
            self.items = models
            self.documents = snapshot.documents
            self.updateHandler(snapshot.documentChanges)
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }
}
