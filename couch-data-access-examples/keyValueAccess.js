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

};

exports.createDocumentWithId = function createDocumentWithId(id, documentValues) {

};

var getDocumentById = exports.getDocumentById = function getDocumentById(id) {


};

exports.updateDocument = function updateDocument(id, newValues) {



}



exports.deleteDocumentById = function deleteDocumentById(id) {

};
