"use strict";

/********************
 * keyValueAccess.js
 *
 * demonstration of CRUD operations against CouchDB
 * using pouchDB
 */


var PouchDB = require('pouchdb'),
  uuid = require('node-uuid');

var db = new PouchDB('http://localhost:5984/dataaccess');

exports.createDocument = function createNewDocument(documentValues) {

  var newDocument = {
    title: 'This is my title',
    message: 'Hello Interactive Developers of STL'
  };

  return db.post(newDocument)
    .then((result) => {
      console.log('I created a document!');
    });
};

exports.createDocumentWithId = function createDocumentWithId(id, documentValues) {
  documentValues._id = id;

  return db.put(documentValues)
    .then((result) => {
      console.log('I created a document with id: ' + id);
    });
};

var getDocumentById = exports.getDocumentById = function getDocumentById(id) {

  return db.get(id);

};

exports.updateDocument = function updateDocument(id, newValues) {

  
  return getDocumentById(id)
    .then((doc) => {
      newValues._id = doc._id;
      newValues._rev = doc._rev;
      return db.put(newValues);
    })
    .then((result) => {
      console.log('I updated a document');
    });

}



exports.deleteDocumentById = function deleteDocumentById(id) {

  return getDocumentById(id)
    .then((doc) => {
      return db.remove({
        _id: id,
        _rev: doc._rev
      });
    })
    .then((result) => {
      console.log('I removed your document');
      return result;
    });


};
