<?php
//zotero_to_json.php: ver. 07
//for more info, see scott.vanduyne@gmail.com (savd@stanford.edu)

//error_reporting(E_ALL);
error_reporting(0);

//get input file name
$in_filename = $argv[1];
$rdf = file_get_contents($in_filename);

//quick test to confirm it is an rdf file:
$rdfpos = strpos($rdf,'<rdf');
if ($rdfpos === false || $rdfpos > 128) {
  //this file is not rdf, so assuming it a pre-processed flat file
  echo $rdf;  //just return the input file;
  die();
}

//hide namespaces (crude but effective)
$s = ":";
$r = "w3X2y1Z0";  //$r is the colon substitution code.
$rdf = str_replace($s, $r, $rdf);

//LOAD XML
$xml = simplexml_load_string($rdf);

$crecords = array();
$NOTES_LEFT = 0;
$big_string = '';

foreach ($xml as $record) {
  //CHECK IF THIS IS A NOTE FOR PREVIOUS RECORD
  if ($NOTES_LEFT > 0) { 
    //still adding notes to previous
    $note = str_replace($r,$s,(string)$record->{"rdf{$r}value"});
    
    //replace p element with returns    
    $note = str_replace('<p>',"\n",$note);
    $note = str_replace('<\p>',"",$note);

    $note = str_replace('&nbsp;',' ',$note);  //get rid of this html tag


    //clear out other html tags
    $note = strip_tags($note);

    //normalize spaces and non printing characters
    $note = preg_replace('/[^A-Za-z\d\!\@\#\$\%\^\&\*\(\)\{\}\[\]\;\:\'\"\,\.\`\~\<\>\/\?\n]+/'," ",$note);
    $note = preg_replace('/[\s\n]*\n[\s\n]*/',"\n  ",$note); //make all line gaps one linefeed    
    $note = trim($note);

    $crecord['notes'] []= $note;
    $NOTES_LEFT--;
    if ($NOTES_LEFT == 0) $crecords []= $crecord;
    continue;
  }
  //ELSE START NEW RECORD
  $crecord = array();
  
  //DRUID
  //look for anything of druid format 'aa111aa1111' in 'about' or 'url'
  unset($match);
  if (isset($record->attributes()->{"rdf{$r}about"})) {
    $rdfabout = str_replace($r,$s,(string)$record->attributes()->{"rdf{$r}about"});
    preg_match('/[a-z]{2}\d{3}[a-z]{2}\d{4}/',$rdfabout,$match); 
  }
  if (!$match[0] && isset($record->{"dc{$r}identifier"}->{"dcterms{$r}URI"}->{"rdf{$r}value"})) {
    $rdfurl = str_replace($r,$s,(string)$record->{"dc{$r}identifier"}->{"dcterms{$r}URI"}->{"rdf{$r}value"});
    preg_match('/[a-z]{2}\d{3}[a-z]{2}\d{4}/',$rdfurl,$match); 
  }
  //then check Extra (dc:description):  simtool moves url to Extra if user selects email item type
  if (!$match[0] && isset($record->{"dc{$r}description"})) {
    $rdfextra = str_replace($r,$s,(string)$record->{"dc{$r}description"});
    preg_match('/[a-z]{2}\d{3}[a-z]{2}\d{4}/',$rdfextra,$match); 
  }
  $crecord['druid'] = $match[0];
  //if (!$crecord['druid']) continue; // no druid, its a note

  //TITLE
  if (isset($record->{"dc{$r}title"})) {
    $crecord['title'] = replace_html_tags(str_replace($r,$s,(string)$record->{"dc{$r}title"}));
  } else $crecord['title'] = '';

  //AUTHORS
  $crecord['originator'] = '';
  unset($authors_stem);
  if (isset($record->{"bib{$r}authors"})) {
    $authors_stem = $record->{"bib{$r}authors"}->{"rdf{$r}Seq"};
  }
  if (isset($record->{"bib{$r}editors"})) {
    $authors_stem = $record->{"bib{$r}editors"}->{"rdf{$r}Seq"};
  }
  if (isset($record->{"z{$r}programmers"})) {
    $authors_stem = $record->{"z{$r}programmers"}->{"rdf{$r}Seq"};
  }
  $a_arr = array();
  if (isset($authors_stem)) {
    for ($i = 0; $i < count($authors_stem->{"rdf{$r}li"}); $i++) {
      $a_arr []= str_replace($r,$s,get_author_from_li($authors_stem->{"rdf{$r}li"}[$i]));
    }
  }
  $crecord['originator'] = $a_arr;

  //DATE
  if (isset($record->{"dc{$r}date"})) {
    $crecord['date'] = str_replace($r,$s,(string)$record->{"dc{$r}date"});
  } else $crecord['date'] = '';
  
  //DOCUMENT TYPE
  if (isset($record->{"z{$r}itemType"})) {
    $crecord['document_type'] = str_replace($r,$s,(string)$record->{"z{$r}itemType"});
  } else $crecord['document_type'] = 'manuscript';

  //CHECK IF SUPPORTED DOC TYPE
  $crecord['document_subtype'] = ''; //concatenate item type to subtype if not allowed
  $supported_item_types = array('thesis',
                                'book',
				'manuscript',
                                'computerProgram',
                                'bookSection',
                                'report',
                                'letter',
                                'conferencePaper',
                                'journalArticle',
                                'email');
  if (!in_array($crecord['document_type'],$supported_item_types)) {
    //echo "BAD DOC TYPE".$crecord['document_type']."\n";
    $crecord['document_subtype'] = $crecord['document_type'];
    $crecord['document_type'] = 'manuscript';
  };
  
  //DOCUMENT SUBTYPE 
  if (isset($record->{"z{$r}type"})) 
    $crecord['document_subtype'] 
      //concatenating...
      .= ($crecord['document_subtype'] ? ': ' : '') . str_replace($r,$s,(string)$record->{"z{$r}type"});
  
  //CONTAINING WORK
  $crecord['containing_work'] = '';
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}title"})) {
    $crecord['containing_work'] 
      .= str_replace($r,$s,
		     (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}title"});
  }
  if ($crecord['document_type'] == 'conferencePaper') {
    if (isset($record->{"dc{$r}title"}[1])) {
      $crecord['containing_work'] .= ($crecord['containing_work'] ? ', ' : '') . 
	str_replace($r,$s,
		    (string)$record->{"dc{$r}title"}[1]);
    }
  }

  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dcterms{$r}alternative"})) {
    $crecord['containing_work'] .= ($crecord['containing_work'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dcterms{$r}alternative"});
  }

  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"dc{$r}title"})) {
    $crecord['containing_work'] 
      .= ($crecord['containing_work'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"dc{$r}title"});
  }

  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"bib{$r}Series"}->{"dc{$r}title"})) {
    $crecord['containing_work'] 
      .= ($crecord['containing_work'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"bib{$r}Series"}->{"dc{$r}title"});
  }
  if (isset($record->{"bib{$r}presentedAt"}->{"bib{$r}Conference"}->{"dc{$r}title"})) {
    $crecord['containing_work'] 
      .= ($crecord['containing_work'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"bib{$r}presentedAt"}->{"bib{$r}Conference"}->{"dc{$r}title"});
  }
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}title"})) {
    $crecord['containing_work'] 
      .= ($crecord['containing_work'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}title"});
  }
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}title"})) {
    $crecord['containing_work'] 
      .= ($crecord['containing_work'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}title"});
  }
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"dc{$r}title"})) {
    $crecord['containing_work'] 
      .= ($crecord['containing_work'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"dc{$r}title"});
  }
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dcterms{$r}alternative"})) {
    $crecord['containing_work'] 
      .= ($crecord['containing_work'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dcterms{$r}alternative"});
  }
  
  if (isset($record->{"z{$r}system"})) {
    $crecord['containing_work'] 
      .= ($crecord['containing_work'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"z{$r}system"});
  }
  
  //CORPORATE ENTITY
  if (isset($record->{"dc{$r}publisher"}->{"foaf{$r}Organization"}->{"foaf{$r}name"})) 
    $crecord['corporate_entity'] 
      = str_replace($r,$s,
		    (string)$record->{"dc{$r}publisher"}->{"foaf{$r}Organization"}->{"foaf{$r}name"});
  else $crecord['corporate_entity'] = '';
  
  //PLACE
  $crecord['place'] = '';
  if (isset($record->{"dc{$r}publisher"}->{"foaf{$r}Organization"}->
	    {"vcard{$r}adr"}->{"vcard{$r}Address"}->{"vcard{$r}locality"}))  
    $crecord['place'] 
      .= str_replace($r,$s,
		     (string)$record->{"dc{$r}publisher"}->{"foaf{$r}Organization"}->
		     {"vcard{$r}adr"}->{"vcard{$r}Address"}->{"vcard{$r}locality"});
  if (isset($record->{"bib{$r}presentedAt"}->
	    {"foaf{$r}Organization"}->{"foaf{$r}name"}))
    $crecord['place'] 
      .= ($crecord['place'] ? ', ' : '') . str_replace($r,$s,
		     (string) $record->{"bib{$r}presentedAt"}->{"foaf{$r}Organization"}->{"foaf{$r}name"});
		     
  //NUMBER ($crecord['number'] ? ', ' : '') .
  $crecord['number'] = '';
  if (isset($record->{"prism{$r}number"})) 
    $crecord['number'] .= 
      str_replace($r,$s,(string)$record->{"prism{$r}number"});
  if (isset($record->{"prism{$r}volume"})) 
    $crecord['number'] .= 
      ($crecord['number'] ? ', ' : '') .
      str_replace($r,$s,(string)$record->{"prism{$r}volume"});
  if (isset($record->{"prism{$r}edition"})) 
    $crecord['number'] .= 
      ($crecord['number'] ? ', ' : '') .
      str_replace($r,$s,(string)$record->{"prism{$r}edition"});
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"prism{$r}volume"}))
    $crecord['number'] .= 
      ($crecord['number'] ? ', ' : '') . 
      str_replace($r,$s,(string) $record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"prism{$r}volume"});

  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}identifier"}))
    $crecord['number'] .= ($crecord['number'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}identifier"});
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"bib{$r}Series"}->{"dc{$r}identifier"}))
    $crecord['number'] .= ($crecord['number'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Book"}->{"bib{$r}Series"}->{"dc{$r}identifier"});
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}identifier"}))
    $crecord['number'] .= ($crecord['number'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Series"}->{"dc{$r}identifier"});
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"prism{$r}volume"}))
    $crecord['number'] .= ($crecord['number'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"prism{$r}volume"});
  if (isset($record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"prism{$r}number"}))
    $crecord['number'] .= ($crecord['number'] ? ', ' : '') . 
      str_replace($r,$s,
		  (string)$record->{"dcterms{$r}isPartOf"}->{"bib{$r}Journal"}->{"prism{$r}number"});
  
  //EXTENT 
  $crecord['extent'] = '';
  if (isset($record->{"z{$r}numPages"})) 
    $crecord['extent'] .= str_replace($r,$s,(string)$record->{"z{$r}numPages"});
  if (isset($record->{"bib{$r}pages"})) 
    $crecord['extent'] .= ($crecord['extent'] ? ', ' : '') .
      str_replace($r,$s,(string)$record->{"bib{$r}pages"});

  //LANGUAGE 
  $crecord['language'] = '';
  if (isset($record->{"z{$r}language"})) 
    $crecord['language'] .= str_replace($r,$s,(string)$record->{"z{$r}language"});
  if (isset($record->{"z{$r}programmingLanguage"})) 
    $crecord['language'] .= str_replace($r,$s,(string)$record->{"z{$r}programmingLanguage"});

  //ABSTRACT 
  if (isset($record->{"dcterms{$r}abstract"})) 
    $crecord['abstract'] = str_replace($r,$s,(string)$record->{"dcterms{$r}abstract"});
  else $crecord['abstract'] = '';

  //TAGS and CALL NUMBER
  $tag_array = array();
  $call_number = '';
  $subjects = $record->{"dc{$r}subject"};
  if (isset($subjects)) {
    foreach ($subjects as $subject) {
      if (isset($subject->{"dcterms{$r}LCC"})) {
	//process the call number
	$call_number = str_replace($r,$s,(string)($subject->{"dcterms{$r}LCC"}->{"rdf{$r}value"}));
      } else {
	//process a tag
	$tag_array []= str_replace($r,$s,(string)$subject);
      }
    }
  }
  $crecord['EAF_hard_drive_file_name'] = $call_number;
  $crecord['tags'] = $tag_array;

  //NOTES
  $notes = array();
  if (isset($record->{"dcterms{$r}isReferencedBy"})) {
    $NOTES_LEFT = count($record->{"dcterms{$r}isReferencedBy"});
  }
  if ($NOTES_LEFT == 0)  $crecords []= $crecord;
}

$output = array();
$i = 0;
foreach ($crecords as $crec) {
  $output[$i] = $crec;
  $i++; 
}

$outLength = count($output);
 if ($outLength == 1) {
$json = json_encode($output[0]);
} else {
  $json = json_encode($output);
}
echo $json;
// file_put_contents($out_file, $json );


function replace_html_tags($str) {
  $str = preg_replace("/\s+/"," ",$str);
  $str = preg_replace("/<\/p>\s*|<br\s*\/>\s*/","\n",$str);
  $str = preg_replace("/<\/[a-zA-Z]+>|<[a-zA-Z]>/","",$str);
  return $str;
}


function get_author_from_li($stem) {
  global $r,$s;
   $pers = $stem->{"foaf{$r}Person"};
  $name = '';
  if ($pers->{"foaf{$r}givenname"} && $pers->{"foaf{$r}givenname"} != '') 
    $name = str_replace($r,$s,(string)$pers->{"foaf{$r}givenname"}) . ' ';
  $name .= str_replace($r,$s,(string)$pers->{"foaf{$r}surname"});
  return $name;
}



//define CSV headers:
/*********
title <dc:title> 
author <bib:authors> <bib:editors> <z.programmers> --> <rdf:Seq>  array(<rdf:li> <foaf:Person>  [<foaf:givenname> + " " +] <foaf:surname>
date   dc:date
document_type (enumerated)
document_subtype (free)  <z:type>
containing_work  <dcterms:isPartOf><bib:Series><dc:title>  <dcterms:isPartOf><bib:Book><dc:title>  <z:system>  <dcterms:isPartOf><bib:Series><dcterms:alternative>
corporate_entity  </dc:publisher></foaf:Organization><foaf:name>
place  <dc:publisher><foaf:Organization><vcard:adr><vcard:Address><vcard:locality>  <bib:presentedAt><bib:Conference><dc:title>Fifth Berkeley Symposium on Mathematical Statistics and Probablilty</dc:title>
number <prism:number> <prism:volume>  <dcterms:isPartOf><bib:Book><prism:volume> <prism:edition>
extent  <z:numPages> <bib:pages>
language <z:language> <z:programmingLanguage> 
abstract <dcterms:abstract>

druid?    top level attribute "rdf:about" e.g., <rdf:Description rdf:about="https://saltworks.stanford.edu/documents/druid:cm484yg4038/downloads?download_id=document.pdf">
*********/
/*
contianing work
-->second title is containing work
<dc:title>containing_work-1</dc:title>
*/
