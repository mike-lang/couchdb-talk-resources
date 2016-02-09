"use strict";

var PouchDB = require('pouchdb');

var db = new PouchDB('http://localhost:5984/map-reduce');

exports.getAllBooks = function getAllBooks() {
  return db.query(function (doc) {
    emit(doc._id, doc);
  });
};


exports.getAllBookTitles = function getAllBookTitles() {
  return db.query(function(doc) {
    emit(doc._id, doc.title);
  });
};

exports.getExpensiveBooks = function getExpensiveBooks() {

};

exports.getPriceForOneOfEverything = function getPriceForOneOfEverything() {

};
