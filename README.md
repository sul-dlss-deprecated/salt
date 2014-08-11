## SALT Application

https://consul.stanford.edu/display/SALT/SALT+Home

There have been several version of the SALT web application. This one was created in Spring 2011 to replace the original ActiveFedora/Mediashelf application built in Fall 2009. It removed all the CRUD functionality and is pretty much just a modified version of Blacklight. Metadata is stored in Fedora, but not the document assets (jp2000s, pdfs, full text, etc.) Editing functionality is now handled by Zotero, with a scripted import process used to update the Fedora metadata.

See below for more details. 

## Deploying

```
$ git clone git@github.com:sul-dlss/saltworks.git
```

For dev and testing, you will need a version of Fedora and Solr to test against, such as the one provided in the hydra-jetty project. After you have either installed a instance of fedora or downloaded the hydra jetty, you will need to start the server and ingest the test objects, located in RAILS_ROOT/spec/fixtures/fedora_objects directory. You can use the ingest script that comes with fedora, which is located in the fedora/default/client/bin directory. The documentation on this script is currently out of date, but you can populate Fedora like so:
```
$ ./fedora-batch-ingest.sh /tmp/saltworks/spec/fixtures/fedora_objects/ /tmp xml info:fedora/fedora-system:FOXML-1.1 localhost:8983 fedoraAdmin fedoraAdmin http
```

The syntax appears to be:
```
$ fedora-batch-ingest.sh {DIRECTORY WITH OBJECTS TO BE INGESTED} {LOG DIRECTORY} {LOG FORMAT} {FOXML VERSION (use 1.1)} {SERVER:PORT} {USERNAME}  {PASSWORD} {HTTP or HTTPS} 
```

You only need to do this once, unless you change your fedora objects. 

Once you have the objects in Fedora, you can index them using the following command in the RAILS_ROOT directory:
```
$ rake salt:index
```

This process checks the RAILS_ROOT/doc directory for a pids.txt file, which has a list of the objects in Fedora to be indexed. 

Once you've done that, you should be ready to run the tests. The easiest way to do that is:
```
$ rake
```
which will run the tests and generate the coverage report. Run rake --describe to see all the options. 


To start the ingest script, use `ruby script/background/zotero_directory_watcher.rb start .` See below for some more details. 

## Ingest

As mentioned above, the editing now takes place in local versions of Zotero. When The User wants to update 
the metadata in Fedora, they can place a file on an AFS directory located in `/afs/ir/group/salt_project/zotero_dropoff` . 


The process works as follows: there is a script that checks the AFS directory. A copy of this script can be found in `script/import_directory_script.rb`. The lyberadmin user has a AFS keytab that allow it to access the AFS directory. This script moves files from AFS to the `tmp` directory. That's all it does.

The `script/background/zotero_directory_watcher.rb` daemon then process the Zotero XML file moved from AFS into the tmp directory. It updates fedora, then indexes the objects. It keeps track of the files processed in the database, which can be viewed at [https://app-url/zotero_ingests]. 

## Term Authority

This is a small featured added recently to clean up some of the bad values in the facets. In `lib/stanford/term_authority.yaml` dictionary file is a list of values to be replaced by other canonical values. For example:

```yaml
Andreus Bechtolscheim: null
Authors: REMOVE
Avron : Avron Barr
```

When ingest finds a value of "Andreus Bechtolscheim", it keeps the default value (null = do nothing, which is this case means index "Andreus Bechtolscheim"). When it finds a values of "Authors", it removes it from the list of values to be indexed (the "REMOVE" means remove the value form the Solr document ). When it finds "Avron", it changes the value to the canonical name ("Avron Barr"). 

This feature was only added for a few hundred of the most common errors in the index in order to clean up the faceted strings. 



 
