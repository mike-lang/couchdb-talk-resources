# couchdb-talk-resources
Materials for talk on building a sync solution with CouchDB, PouchDB, &amp; Couchbase Lite

Includes:
* [Keynote slides used during the talk](https://github.com/mike-lang/couchdb-talk-resources/blob/master/SyncTalkSlides.key)
* [Data Access demostration code used during the talk](https://github.com/mike-lang/couchdb-talk-resources/tree/master/couch-data-access-examples) - The skeletal form can be retrieved by checking out tag `pouchdb-access-demo-start` and the completed examples can be retrieved by checking out master's HEAD or `pouchdb-access-demo-end`.  All examples used node 4.x installed on OSX.  The customized interactive REPL that I used during this portion of the talk may be found here: https://github.com/thirdiron/promise-repl Technically I guess its a Read, Evaluate, Resolve, Print, Loop, but RERPL is a garbage acronym, so its named PREPL, short for Promise-REPL.
* [The Javascript todos tutorial app](https://github.com/mike-lang/couchdb-talk-resources/tree/master/pouchdb-getting-started-todo) used in the talk that is a slight modification of [the brilliant todos app](https://github.com/nolanlawson/pouchdb-getting-started-todo) that [Nolan Lawson](nolanlawson.com) put together with a fantastic [video tutorial](http://pouchdb.com/getting-started.html#video_tutorial) for the PouchDB project.
* [The Objective-C todos frankenstein app](https://github.com/mike-lang/couchdb-talk-resources/tree/master/ToDoLite-iOS) that I hacked out of the Couchbase Lite projects [ToDoLite demo app](https://github.com/couchbaselabs/ToDoLite-iOS) to make work with the pouchdb todos app.  Review their [original app](https://github.com/couchbaselabs/ToDoLite-iOS) to get a far better sense of the variety of functions their libraries provide and to see the couchbase lite functionality in action without the distraction of my messy efforts to redesign the app in a day or two.  
* A [Vagrantfile](https://www.vagrantup.com/) and a provisioning script to
set up couchdb within a Ubuntu VM via Vagrant & Virtual Box, if you're
not comfortable installing couchdb on your base machine via homebrew,
etc.
