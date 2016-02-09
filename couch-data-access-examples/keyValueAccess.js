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


};

exports.updateDocument = function updateDocument(id, newValues) {



}



exports.deleteDocumentById = function deleteDocumentById(id) {

};
