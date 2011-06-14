<?php

//needs to be tested some more
//for more info, see scott.vanduyne@gmail.com 

//output file name
//$out_file = $argv[2];
//"FirstAccessionRT-json.txt";

//input file name
$in_filename = $argv[1];
//"/tmp/test.xml";

//READ IN THE COLLECTION RDF
$rdf = file_get_contents($in_filename);

//hide namespaces
$s1 = ":";
$r1 = "X1Y2Z3";  //$r1 is the colon substitution code.
$rdf = str_replace($s1, $r1, $rdf);

//LOAD XML
$xml = simplexml_load_string($rdf);
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
$crecords = array();
$NOTED_LEFT = 0;
$big_string = '';
foreach ($xml as $record) {
  
  //CHECK IF THIS IS A NOTE FOR PREVIOUS RECORD
  if ($NOTES_LEFT > 0) { //still adding notes to previous
    $note = (string)$record->{'rdf'.$r1.'value'};
    $crecord['notes'] []= $note;
    $NOTES_LEFT--;
    if ($NOTES_LEFT == 0) $crecords []= $crecord;
    continue;
  }
  //ELSE START NEW RECORD
  $crecord = array();
  
  //DRUID
  //  var_dump((string)$record->attributes()->{'rdf'.$r1.'about'});die();
  $rdfabout = (string)$record->attributes()->{'rdf'.$r1.'about'};
  preg_match("%(druid$r1.*?)/%",$rdfabout,$match); 
  $crecord['druid'] = str_replace( $r1, $s1, $match[1]);
  if (!$crecord['druid']) continue; // its a note

  //TITLE
  if (isset($record->{'dc'.$r1.'title'})) $crecord['title'] = (String)$record->{'dc'.$r1.'title'};
  else $crecord['title'] = '';

  //AUTHORS <bib:authors> <bib:editors> <z.programmers> --> <rdf:Seq>  array(<rdf:li> <foaf:Person>	[<foaf:givenname> + " " +] <foaf:surname>
  $crecord['originator'] = '';
  if (isset($record->{'bib'.$r1.'authors'})) $authors_stem = $record->{'bib'.$r1.'authors'}->{'rdf'.$r1.'Seq'};
  if (isset($record->{'bib'.$r1.'editors'})) $authors_stem = $record->{'bib'.$r1.'editorss'}->{'rdf'.$r1.'Seq'};
  if (isset($record->{'z'.$r1.'programmers'})) $authors_stem = $record->{'z'.$r1.'programmers'}->{'rdf'.$r1.'Seq'};
  $a_arr = array();
  for ($i = 0; $i < count($authors_stem->{'rdf'.$r1.'li'}); $i++) {
    $a_arr []= get_author_from_li($authors_stem->{'rdf'.$r1.'li'}[$i]);
  }
  //$crecord['originator'] = implode("|",$a_arr);
  $crecord['originator'] = $a_arr;
  //DATE
  if (isset($record->{'dc'.$r1.'date'})) $crecord['date'] = (String)$record->{'dc'.$r1.'date'};
  else $crecord['date'] = '';
  
  //DOCUMENT TYPE
  if (isset($record->{'z'.$r1.'itemType'})) $crecord['document_type'] = (String)$record->{'z'.$r1.'itemType'};
  else $crecord['document_type'] = '';

  //DOCUMENT SUBTYPE
  if (isset($record->{'z'.$r1.'type'})) $crecord['document_subtype'] = (String)$record->{'z'.$r1.'type'};
  else $crecord['document_subtype'] = '';

  //CONTAINING WORK
  $crecord['containing_work'] = '';
  if (isset($record->{'dcterms'.$r1.'isPartOf'}->{'bib'.$r1.'Series'}->{'dc'.$r1.'title'})) 
        $crecord['containing_work'] .= (String)$record->{'dcterms'.$r1.'isPartOf'}->{'bib'.$r1.'Series'}->{'dc'.$r1.'title'};
  if (isset($record->{'dcterms'.$r1.'isPartOf'}->{'bib'.$r1.'Book'}->{'dc'.$r1.'title'}))
        $crecord['containing_work'] .= (String)$record->{'dcterms'.$r1.'isPartOf'}->{'bib'.$r1.'Book'}->{'dc'.$r1.'title'};
  if (isset($record->{'dcterms'.$r1.'isPartOf'}->{'bib'.$r1.'Series'}->{'dcterms'.$r1.'alternative'}))
        $crecord['containing_work'] .= (String)$record->{'dcterms'.$r1.'isPartOf'}->{'bib'.$r1.'Seris'}->{'dcterms'.$r1.'alternative'};
  if (isset($record->{'z'.$r1.'system'})) $crecord['containing_work'] .= (String)$record->{'z'.$r1.'system'};

  //CORPORATE ENTITY
  if (isset($record->{'dc'.$r1.'publisher'}->{'foaf'.$r1.'Organization'}->{'foaf'.$r1.'name'})) 
        $crecord['corporate_entity'] = (String)$record->{'dc'.$r1.'publisher'}->{'foaf'.$r1.'Organization'}->{'foaf'.$r1.'name'};
  else $crecord['corporate_entity'] = '';

  //PLACE
  $record['place'] = '';
  if (isset($record->{'dc'.$r1.'publisher'}->{'foaf'.$r1.'Organization'}->{'vcard'.$r1.'adr'}->{'vcard'.$r1.'Address'}->{'vcard'.$r1.'locality'}))  
           $crecord['place'] .= 
              (String)$record->{'dc'.$r1.'publisher'}->{'foaf'.$r1.'Organization'}->{'vcard'.$r1.'adr'}->{'vcard'.$r1.'Address'}->{'vcard'.$r1.'locality'};
  if (isset($record->{'bib'.$r1.'presentedAt'}->{'foaf'.$r1.'Organization'}->{'foaf'.$r1.'name'}))
           $crecord['place'] .= (String) $record->{'bib'.$r1.'presentedAt'}->{'foaf'.$r1.'Organization'}->{'foaf'.$r1.'name'};

  //NUMBER 
  $record['number'] = '';
  if (isset($record->{'prism'.$r1.'number'})) $crecord['number'] .= (String)$record->{'prism'.$r1.'number'};
  if (isset($record->{'prism'.$r1.'volume'})) $crecord['number'] .= (String)$record->{'prism'.$r1.'volume'};
  if (isset($record->{'prism'.$r1.'edition'})) $crecord['number'] .= (String)$record->{'prism'.$r1.'edition'};
  if (isset($record->{'dcterms'.$r1.'isPartOf'}->{'bib'.$r1.'Book'}->{'prism'.$r1.'volume'}))
           $crecord['number'] = (String) $record->{'dcterms'.$r1.'isPartOf'}->{'bib'.$r1.'Book'}->{'prism'.$r1.'volume'};

  //EXTENT 
  $crecord['extent'] = '';
  if (isset($record->{'z'.$r1.'numPages'})) $crecord['extent'] .= (String)$record->{'z'.$r1.'numPages'};
  if (isset($record->{'bib'.$r1.'pages'})) $crecord['extent'] .= (String)$record->{'bib'.$r1.'pages'};

  //LANGUAGE 
  $crecord['language'] = '';
  if (isset($record->{'z'.$r1.'language'})) $crecord['language'] .= (String)$record->{'z'.$r1.'language'};
  if (isset($record->{'z'.$r1.'programmingLanguage'})) $crecord['language'] .= (String)$record->{'z'.$r1.'programmingLanguage'};

  //ABSTRACT 
  if (isset($record->{'dcterms'.$r1.'abstract'})) $crecord['abstract'] = (String)$record->{'dcterms'.$r1.'abstract'};
  else $crecord['abstract'] = '';

  //TAGS and CALL NUMBER
  $tag_array = array();
  $call_number = '';
  $subjects = $record->{'dc'.$r1.'subject'};
  //var_dump($subjects);
  if (isset($subjects)) {
    foreach ($subjects as $subject) {
      //var_dump($subject);
      if (isset($subject->{'dcterms'.$r1.'LCC'})) {
	//process the call number
	$call_number = (string)($subject->{'dcterms'.$r1.'LCC'}->{'rdf'.$r1.'value'});
	//echo "I am here"; var_dump($call_number);
      } else {
	//process a tag
	$tag_array []= (string)$subject;
      }
    }
  }
  $crecord['EAF_hard_drive_file_name'] = $call_number;
  //$crecord['tags'] = implode("|",$tag_array);
  $crecord['tags'] = $tag_array;


  //NOTES
  $notes = array();
  if (isset($record->{'dcterms'.$r1.'isReferencedBy'})) {
    $NOTES_LEFT = count($record->{'dcterms'.$r1.'isReferencedBy'});
  }

  if ($NOTES_LEFT == 0)  $crecords []= $crecord;
}

$output = array();
$i = 0;
foreach ($crecords as $crec) {
  $output[$i] = $crec;
  $i++; 
}

//print_r($crecords);
$outLength = count($output);
 
if ($outLength == 1) {
$json = json_encode($output[0]);
} else {
  $json = json_encode($output);
}
echo $json;
// file_put_contents($out_file, $json );


function get_author_from_li($stem) {
  global $r1;
  $pers = $stem->{'foaf'.$r1.'Person'};
  $name = '';
  if (!$pers->{'foaf'.$r1.'givenname'}) $name .= (String)$pers->{'foaf'.$r1.'givenname'} + " ";
  $name .= (String)$pers->{'foaf'.$r1.'surname'};
  return $name;
}




?>
