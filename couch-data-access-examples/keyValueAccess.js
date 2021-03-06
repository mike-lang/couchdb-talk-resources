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
  return db.post(documentValues)
    .then((result) => {
      console.log('I created a document!');
      return result;
    });
};

exports.createDocumentWithId = function createDocumentWithId(id, documentValues) {
  return db.get(id)
    .then((result) => {
      console.log('I retrieved a document!');
      return result;
    });
};

var getDocumentById = exports.getDocumentById = function getDocumentById(id) {

  return db.get(id)
    .then((result) => {
      console.log('I retrieved a document!');
      return result;
    });

};

exports.updateDocument = function updateDocument(id, newValues) {

  var getLatestRevision = getDocumentById(id);

  return getLatestRevision
    .then((doc) => {
      newValues._id = doc._id
      newValues._rev = doc._rev
      return db.put(newValues);
    })
    .then((result) => {
      console.log('I updated a document!');
      return result;
    });

}



exports.deleteDocumentById = function deleteDocumentById(id) {
  var getLatestRevision = getDocumentById(id);
  
  return getLatestRevision
    .then((doc) => {
      return db.remove(doc)
    })
    .then((result) => {
      console.log('I deleted a document!');
      return result;
    });
};
