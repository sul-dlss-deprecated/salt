require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include SaltHelper

   

describe SaltHelper do
  include SaltHelper
  

  
  describe "#index_results_box" do
    it "should call index_group_results if there's a grouping facet" do
       helper.stubs(:grouping_facet).returns('year_facet')
       helper.expects(:index_grouped_results).with('year_facet').once
       helper.expects(:index_ungrouped_results).never
       helper.index_results_box
    end
    
    it "should call index_ungrouped_results if there's not a grouping facet" do
       helper.stubs(:grouping_facet).returns(nil)
       helper.expects(:index_grouped_results).never
       helper.expects(:index_ungrouped_results).once
       helper.index_results_box
    end   
  end
  
  describe "#index_grouped_results" do
    it "should render the partial correctly with the proper locals" do
      @response = mock("SolrResponse")
      
      docs = mock("SolrDocuments")
      grouping = [["1990", "docs"]] 
      docs.expects(:group_by).returns(grouping).once
      @response.expects(:docs).returns(docs).once
      helper.stubs(:viewing_context).returns("gallery")
      helper.expects(:render_partial).with('catalog/_index_partials/group',{ :docs => "docs", :facet_name => "year_facet", :facet_value => "1990", :view_type => 'gallery' } ).returns("").once
      helper.index_grouped_results('year_facet')
    end    
  end
  
  describe "#index_ungrouped_results" do
    it "should render the partial correctly with the proper locals" do
      @response = mock("SolrResponse")
      docs = mock("SolrDocuments")
      @response.expects(:docs).returns(docs).once
      helper.stubs(:viewing_context).returns("gallery")
      helper.expects(:render_partial).with('catalog/_index_partials/group',{ :docs => docs, :facet_name => nil, :facet_value => nil, :view_type => 'gallery' } ).once
      helper.index_ungrouped_results()
    end
  end
  
  describe "#render_partial" do
    it "should render the partial with the local params passed in" do
      helper.expects(:render).with(:locals => {:some_stuff => 'some_value'}, :partial => 'my_partial')
      helper.render_partial('my_partial', { :some_stuff => "some_value"})
    end
  end
  
  describe "#index_results_class" do
    it "should return the right css class for list view" do
      helper.stubs(:viewing_context).returns("list")
      helper.index_results_class.should == "list_index"
       helper.index_results_class.should_not == "gallery_index"
    end
    
    it "should return the right css class for gallery view" do
      helper.stubs(:viewing_context).returns("gallery")
      helper.index_results_class.should_not == "list_index"
      helper.index_results_class.should == "gallery_index"
    end
  end
  
  describe "#viewing_context" do
    it "should return gallery is no params are set" do
      helper.viewing_context.should == "gallery"
    end
    
    it "should return gallery is params[:view] == gallery" do 
      helper.stubs(:params).returns({:view => 'gallery'})
      helper.viewing_context.should == "gallery"
    end
    
     it "should return view is params[:view] == list" do 
        helper.stubs(:params).returns({:view => 'list'})
        helper.viewing_context.should == "list"
        helper.viewing_context.should_not == "gallery"
      end  
  end
  
  
  
  describe "#grouping_facet" do
    
   
    #   This is testing against the sorts defined the Blacklight.config. The sort_fields currently = 
    #  {"location"=>"series_sort asc, box_sort asc, folder_sort asc, year_sort desc, month_sort asc, title_sort asc",
    #  "title"=>"title_sort asc, year_sort desc, month_sort asc", 
    #  "date +"=>"year_sort asc, month_sort asc, day_sort asc, title_sort asc", 
    #  "relevance"=>"score desc, year_sort desc, month_sort asc, title_sort asc",
    #   "date -"=>"year_sort desc, month_sort asc, day_sort asc, title_sort asc"} )
    
    it "should return nil if there is no sort_facet" do
      helper.grouping_facet.should == nil
    end
    
    it "should return the proper values " do
       helper.stubs(:params).returns({:sort => 'year_sort desc, month_sort asc, day_sort asc, title_sort asc'})
       helper.grouping_facet.should ==  'year_facet'
    end
    
    it "should return the proper values " do
        helper.stubs(:params).returns({:sort => 'year_sort asc, month_sort asc, day_sort asc, title_sort asc'})
        helper.grouping_facet.should ==  'year_facet'
     end
      
    #it "should return the proper values " do
        #pending
        # not sure we want to use the series sort. 
        #helper.stubs(:params).returns({:sort => 'series_sort asc, box_sort asc, folder_sort asc, year_sort desc, month_sort asc, title_sort asc'})
        #helper.grouping_facet.should ==  'series_facet'
    #end
  end
  
  
  
  describe "#grouped_result_count" do 
    it "should return the count and the correct pluziation of document when there are no facets" do
      response = mock("SolrResponse")
      docs = mock("SolrDocuments")
      docs.expects(:total).returns(3)
      response.expects(:docs).returns(docs).once
      
      helper.grouped_result_count(response).should == "3 documents"
    end
    
    it "should return the count and the correct pluziation of document when there are no facets" do
      response = mock("SolrResponse")
      docs = mock("SolrDocuments")
      docs.expects(:total).returns(1)
      response.expects(:docs).returns(docs).once

      helper.grouped_result_count(response).should == "1 document"
    end
    
    it "should return the count and the correct pluziation of document when there is a facet" do
      response = mock("SolrResponse")
      facets = mock("SolrFacets")
      items = mock("SolrItems")
      item = mock("FacetItem")
      facets.expects(:detect).returns(facets)
      facets.expects(:items).returns(items)
      items.expects(:detect).returns(item)
      item.expects(:hits).returns(3)
      response.expects(:facets).returns(facets).once

      helper.grouped_result_count(response, "somefacet_s", "some_value").should == "3 documents"
    end
    
  end
  
  describe "#display_group_heading" do
   
      
    it "should return the proper html when give the facet_name and facet_value strings" do
      helper.expects(:grouped_result_count).returns("99 foofoos")
      helper.display_group_heading("foo", "bar").should ==  "<h3>bar<em>&nbsp;&nbsp;&nbsp;99 foofoos</em></h3>"
    end
    
    it "should return the proper html when given the facet_name but not facet_value" do
      helper.expects(:grouped_result_count).returns("107 foofoos")
      helper.display_group_heading("foo").should == "<h3><em>&nbsp;&nbsp;&nbsp;107 foofoos</em></h3>"
    end
    
    it "should return the proper htm when given the facet_name string and facet_value as an array" do
      helper.expects(:grouped_result_count).returns("2 foofoos")
      helper.display_group_heading("foo", ["bar", "jar"]).should ==  "<h3>bar<em>&nbsp;&nbsp;&nbsp;2 foofoos</em></h3>"
    end
  end 
  
  describe "#remove_druid_prefix" do 
    it "should return the string with the druid: prefix removed" do
      helper.remove_druid_prefix("druid:foo").should == "foo"
    end
    
    it "should return the string if there is not druid: prefix" do 
      helper.remove_druid_prefix("foo").should == "foo"
    end
  end
  
  describe "#thumbtag" do
    it "should return an img tag with the proper src pointing to an assets thumbnail" do
      helper.thumb_tag("druid:123").should == "<img src=/assets/123.jpg alt=\"druid:123\"/>"
    end
  end
  
  
   describe "#facets_display_heading" do 
      it "should return the proper text when in the show context" do
        helper.expects(:action_name).returns("show")
        helper.facets_display_heading.should == "This Document Refers To"
      end

       it "should return the proper text when in the any other context" do
          helper.expects(:action_name).returns("index")
          helper.facets_display_heading.should ==  "Limit Your Search"
        end

    end
    
    describe "#facets_toggle" do 
     
      it "should add the proper javascript files to the includes when in the show context" do
        helper.expects(:javascript_includes).at_least_once.returns([])
        helper.expects(:action_name).returns("show")
        helper.facets_toggle.should == ["facet_toggle.js", "flipbook.js"]
      end
      
      it "should return nil and keep the javascript includes as is if not in the show context" do
        helper.expects(:javascript_includes).once.returns([])    
        helper.expects(:action_name).returns("index")
        helper.facets_toggle.should == [] 
      end
      
    end
    
    describe "#display_notes" do
      
      it "should return the html in the correct format" do 
          @document = mock("SolrDocuments")
          @document.expects(:get).once.returns(["this is the story", "of a three hour tour"])
          helper.display_donor_notes.should == "<dt class='blacklight-note_display'>Donor Notes:</dt><dd class='blacklight-note_display'>this is the story<br/>of a three hour tour<br/>"
      end
      
      
      
    end
  
  
end