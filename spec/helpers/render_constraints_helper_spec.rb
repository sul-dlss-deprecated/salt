require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include RenderConstraintsHelper


describe RenderConstraintsHelper do
  
  
  describe "#render_constraints_query" do
    
    it "should close out the span if no params are given" do
      helper.render_constraints_query.should == "</span>"
    end
    
    it "should return the proper html if params are given" do
      localized_params = {:q => "This is my query" }
      helper.render_constraints_query(localized_params).should == "<span class='search_terms'><span class='search_label'>Your Search: </span>\n<span class=\"appliedFilter constraint query\">\n        <span class=\"filterValue\">This</span>\n        <a href=\"/catalog?q=is+my+query\" alt=\"remove\" class=\"btnRemove imgReplace\">Remove constraint This</a>\n</span>\n\n<span class=\"appliedFilter constraint query\">\n        <span class=\"filterValue\">is</span>\n        <a href=\"/catalog?q=This+my+query\" alt=\"remove\" class=\"btnRemove imgReplace\">Remove constraint is</a>\n</span>\n\n<span class=\"appliedFilter constraint query\">\n        <span class=\"filterValue\">my</span>\n        <a href=\"/catalog?q=This+is+query\" alt=\"remove\" class=\"btnRemove imgReplace\">Remove constraint my</a>\n</span>\n\n<span class=\"appliedFilter constraint query\">\n        <span class=\"filterValue\">query</span>\n        <a href=\"/catalog?q=This+is+my\" alt=\"remove\" class=\"btnRemove imgReplace\">Remove constraint query</a>\n</span>\n"
    end
    
    it "should return the proper html if params are given with a search field" do
      localized_params = {:q => "This is my query", :search_field => "fulltext" }
      helper.render_constraints_query(localized_params).should ==  "<span class='search_terms'><span class='search_label'>Your Search: </span>\n<span class=\"appliedFilter constraint query\">\n        <span class=\"filterName\">Descriptions and Fulltext</span> \n        <span class=\"filterValue\">This</span>\n        <a href=\"/catalog?q=is+my+query&amp;search_field=fulltext\" alt=\"remove\" class=\"btnRemove imgReplace\">Remove constraint This: This</a>\n</span>\n\n<span class=\"appliedFilter constraint query\">\n        <span class=\"filterName\">Descriptions and Fulltext</span> \n        <span class=\"filterValue\">is</span>\n        <a href=\"/catalog?q=This+my+query&amp;search_field=fulltext\" alt=\"remove\" class=\"btnRemove imgReplace\">Remove constraint is: is</a>\n</span>\n\n<span class=\"appliedFilter constraint query\">\n        <span class=\"filterName\">Descriptions and Fulltext</span> \n        <span class=\"filterValue\">my</span>\n        <a href=\"/catalog?q=This+is+query&amp;search_field=fulltext\" alt=\"remove\" class=\"btnRemove imgReplace\">Remove constraint my: my</a>\n</span>\n\n<span class=\"appliedFilter constraint query\">\n        <span class=\"filterName\">Descriptions and Fulltext</span> \n        <span class=\"filterValue\">query</span>\n        <a href=\"/catalog?q=This+is+my&amp;search_field=fulltext\" alt=\"remove\" class=\"btnRemove imgReplace\">Remove constraint query: query</a>\n</span>\n"
    end
    
  end
  
  
  describe "#render_constraints_filters" do
    
    it "should return empty string if no para[:f] given" do
         helper.render_constraints_filters.should == ""
    end
  
    it "should return the right html if para[:f] given" do
         localized_params = {:f => { "City" => ["Stanford"]}}
         helper.render_constraints_filters(localized_params).should == "<div class='facet_terms'><span>Limited To: </span>\n<span class=\"appliedFilter constraint filter filter-city\">\n        <span class=\"filterValue\">Stanford</span>\n        <a href=\"/catalog?\" alt=\"remove\" class=\"btnRemove imgReplace\">Remove constraint Stanford</a>\n</span>\n\n</div>"
    end
    
   
    
  end
  
  describe "#get_search_breadcrumb_terms" do 
    
    it "should return return the search terms if quotes are present  are present" do
      helper.get_search_breadcrumb_terms('he said "Boo Yah, Brah"').should ==  ["\"Boo Yah, Brah\"", "he", "said"]
    end
    
    it "should return a split if not quotes are in the param[:f]" do
      helper.get_search_breadcrumb_terms('Boo Yah').should ==  ["Boo","Yah"]
    end
    
    
  end
  
  
end
