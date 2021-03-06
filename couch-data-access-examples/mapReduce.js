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
  return db.query(function (doc) {
    if (doc.price > 20) {
      emit(doc._id, doc);
    }
  });
};

exports.getPriceForOneOfEverything = function getPriceForOneOfEverything() {

  var mapReduce = {
    map: function(doc) {
      emit(doc.title, doc.price);
    },
    reduce: function(keys, values, rereduce) {
      if (rereduce) {
        return sum(values);
      } else {
        return sum(values);
      }
    }
  }

  return db.query(mapReduce, {reduce: true});


};
