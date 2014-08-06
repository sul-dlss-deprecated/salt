require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include SaltHelper

   

describe SaltHelper do
  include SaltHelper
  

  
  describe "#index_results_box" do
    it "should call index_group_results if there's a grouping facet" do
       helper.stub(:grouping_facet => 'year_facet')
       helper.should_receive(:index_grouped_results).with('year_facet').once
       helper.should_receive(:index_ungrouped_results).never
       helper.index_results_box
    end
    
    it "should call index_ungrouped_results if there's not a grouping facet" do
       helper.stub(:grouping_facet => nil)
       helper.should_receive(:index_grouped_results).never
       helper.should_receive(:index_ungrouped_results).once
       helper.index_results_box
    end   
  end
  
  describe "#index_grouped_results" do
    it "should render the partial correctly with the proper locals" do
      @response = double("SolrResponse")
      
      docs = double("SolrDocuments")
      grouping = [["1990", "docs"]] 
      docs.should_receive(:group_by).once.and_return(grouping)
      @response.should_receive(:docs).once.and_return(docs)
      helper.stub(:viewing_context => "gallery")
      helper.should_receive(:render_partial).with('catalog/_index_partials/group',{ :docs => "docs", :facet_name => "year_facet", :facet_value => "1990", :view_type => 'gallery' } ).once.and_return("")
      helper.index_grouped_results('year_facet')
    end    
  end
  
  describe "#index_ungrouped_results" do
    it "should render the partial correctly with the proper locals" do
      @response = double("SolrResponse")
      docs = double("SolrDocuments")
      @response.should_receive(:docs).once.and_return(docs)
      helper.stub(:viewing_context => "gallery")
      helper.should_receive(:render_partial).with('catalog/_index_partials/group',{ :docs => docs, :facet_name => nil, :facet_value => nil, :view_type => 'gallery' } ).once
      helper.index_ungrouped_results()
    end
  end
  
  describe "#render_partial" do
    it "should render the partial with the local params passed in" do
      helper.should_receive(:render).with(:locals => {:some_stuff => 'some_value'}, :partial => 'my_partial')
      helper.render_partial('my_partial', { :some_stuff => "some_value"})
    end
  end
  
  describe "#index_results_class" do
    it "should return the right css class for list view" do
      helper.stub(:viewing_context => "list")
      helper.index_results_class.should == "list_index"
       helper.index_results_class.should_not == "gallery_index"
    end
    
    it "should return the right css class for gallery view" do
      helper.stub(:viewing_context => "gallery")
      helper.index_results_class.should_not == "list_index"
      helper.index_results_class.should == "gallery_index"
    end
  end
  
  describe "#viewing_context" do
    it "should return gallery is no params are set" do
      helper.viewing_context.should == "gallery"
    end
    
    it "should return gallery is params[:view] == gallery" do 
      helper.stub(:params => {:view => 'gallery'})
      helper.viewing_context.should == "gallery"
    end
    
     it "should return view is params[:view] == list" do 
        helper.stub(:params => {:view => 'list'})
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
       helper.stub(:params => {:sort => 'year_sort desc, month_sort asc, day_sort asc, title_sort asc'})
       helper.grouping_facet.should ==  'year_facet'
    end
    
    it "should return the proper values " do
        helper.stub(:params => {:sort => 'year_sort asc, month_sort asc, day_sort asc, title_sort asc'})
        helper.grouping_facet.should ==  'year_facet'
     end
      
    #it "should return the proper values " do
        #pending
        # not sure we want to use the series sort. 
        #helper.stub(:params => {:sort => 'series_sort asc, box_sort asc, folder_sort asc, year_sort desc, month_sort asc, title_sort asc'})
        #helper.grouping_facet.should ==  'series_facet'
    #end
  end
  
  
  
  describe "#grouped_result_count" do 
    it "should return the count and the correct pluziation of document when there are no facets" do
      response = double("SolrResponse")
      docs = double("SolrDocuments")
      docs.should_receive(:length).and_return(3)
      response.should_receive(:docs).once.and_return(docs)
      
      helper.grouped_result_count(response).should == "3 documents"
    end
    
    it "should return the count and the correct pluziation of document when there are no facets" do
      response = double("SolrResponse")
      docs = double("SolrDocuments")
      docs.should_receive(:length).and_return(1)
      response.should_receive(:docs).once.and_return(docs)

      helper.grouped_result_count(response).should == "1 document"
    end
    
    it "should return the count and the correct pluziation of document when there is a facet" do
      response = double("SolrResponse")
      facets = double("SolrFacets")
      items = double("SolrItems")
      item = double("FacetItem")
      facets.should_receive(:detect).and_return(facets)
      facets.should_receive(:items).and_return(items)
      items.should_receive(:detect).and_return(item)
      item.should_receive(:hits).and_return(3)
      response.should_receive(:facets).once.and_return(facets)

      helper.grouped_result_count(response, "somefacet_s", "some_value").should == "3 documents"
    end
    
  end
  
  describe "#display_group_heading" do
   
      
    it "should return the proper html when give the facet_name and facet_value strings" do
      helper.should_receive(:grouped_result_count).and_return("99 foofoos")
      helper.display_group_heading("foo", "bar").should ==  "<h3>bar<em>&nbsp;&nbsp;&nbsp;99 foofoos</em></h3>"
    end
    
    it "should return the proper html when given the facet_name but not facet_value" do
      helper.should_receive(:grouped_result_count).and_return("107 foofoos")
      helper.display_group_heading("foo").should == "<h3><em>&nbsp;&nbsp;&nbsp;107 foofoos</em></h3>"
    end
    
    it "should return the proper htm when given the facet_name string and facet_value as an array" do
      helper.should_receive(:grouped_result_count).and_return("2 foofoos")
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
        helper.should_receive(:action_name).and_return("show")
        helper.facets_display_heading.should == "This Document Refers To"
      end

       it "should return the proper text when in the any other context" do
          helper.should_receive(:action_name).and_return("index")
          helper.facets_display_heading.should ==  "Limit Your Search"
        end

    end
    
    describe "#display_notes" do
      
      it "should return the html in the correct format" do 
          @document = { "notes_display" => ["this is the story", "of a three hour tour"] }       
          helper.display_donor_notes.should == "<dt class='blacklight-notes_display'>Donor Notes:</dt><dd class='blacklight-notes_display'>this is the story<br/><br/>of a three hour tour"
      end
    end
    
    describe "#render_salt_pagination_info" do
      
       it "should return the proper html given a solr response with no docs" do
          @solr_response = double("SolrResponse")
          docs = double("SolrDocuments")
          docs.should_receive(:length).twice.and_return(0)
          docs.should_receive(:first).never
          
          @solr_response.should_receive(:empty?).and_return(true)
          @solr_response.should_receive(:docs).at_least(1).and_return(docs)
          @solr_response.should_receive(:start).twice.and_return(0)
          @solr_response.should_receive(:rows).at_least(1).and_return(0)
          @solr_response.should_receive(:total).twice.and_return(0)

          helper.render_salt_pagination_info(@solr_response).should ==  "No entries found"

       end
      
       it "should return the proper html given a solr response with 1 docs" do
          @solr_response = double("SolrResponse")
          docs = double("SolrDocuments")
          docs.should_receive(:length).twice.and_return(1)

          first = SolrDocument.new 
          docs.should_receive(:first).and_return(first)

          @solr_response.should_receive(:empty?).and_return(false)
          @solr_response.should_receive(:docs).at_least(1).and_return(docs)
          @solr_response.should_receive(:start).twice.and_return(0)
          @solr_response.should_receive(:rows).at_least(1).and_return(0)
          @solr_response.should_receive(:total).twice.and_return(1)

          helper.render_salt_pagination_info(@solr_response).should == "Displaying <b>1</b> solr document"
        end
        
        it "should return the proper html given a solr response with multiple docs but not paginated" do
            @solr_response = double("SolrResponse")
            docs = double("SolrDocuments")
            docs.should_receive(:length).twice.and_return(5)

            first = SolrDocument.new 
            docs.should_receive(:first).and_return(first)

            @solr_response.should_receive(:empty?).and_return(false)
            @solr_response.should_receive(:docs).at_least(1).and_return(docs)
            @solr_response.should_receive(:start).twice.and_return(0)
            @solr_response.should_receive(:rows).at_least(1).and_return(10)
            @solr_response.should_receive(:total).twice.and_return(5)

            helper.render_salt_pagination_info(@solr_response).should == "Displaying <b>all 5</b> solr documents"
          end
        
      
         it "should return the proper html given a solr response with many docs paginated" do
            @solr_response = double("SolrResponse")
            docs = double("SolrDocuments")
            docs.should_receive(:length).once.and_return(100000000)

            first = double("SolrDoc")
            docs.should_receive(:first).and_return(first)

            @solr_response.should_receive(:empty?).and_return(false)
            @solr_response.should_receive(:docs).at_least(1).and_return(docs)
            @solr_response.should_receive(:start).twice.and_return(2)
            @solr_response.should_receive(:rows).at_least(1).and_return(0)
            @solr_response.should_receive(:total).twice.and_return(100000000)

            helper.render_salt_pagination_info(@solr_response).should == "<span id='salt_pagination_info'><b>3 - 100,000,002</b> of <b>100,000,000</b></span>" 
          end
    end
    
    
    describe "#folder_siblings" do
      
      it "should return nil if box, folder, and series are not given" do
        @document = {}
        helper.folder_siblings(@document).should be_empty
      end
      
      it "should query Blacklight if series is given" do
        helper.should_receive(:get_search_results).with({:fq =>  ["series_facet:\"Big Box O' Porn\""], :rows => 1000}, {}).and_return(["", "The Results"])
        
        @document = {:series_facet => "Big Box O' Porn"}
        helper.folder_siblings(@document).should == "The Results"
      end
      
        it "should query Blacklight if series and box is given" do
          helper.should_receive(:get_search_results).with({:fq =>  ["series_facet:\"Big Box O' Porn\"", "box_facet:\"78\""], :rows => 1000}, {}).and_return(["", "The Results"])
    
          @document = {:series_facet => "Big Box O' Porn", :box_facet => "78"}
          helper.folder_siblings(@document).should == "The Results"
        end
      
      
       it "should query Blacklight if series and box and folder are given" do
          helper.should_receive(:get_search_results).with({:fq =>  ["series_facet:\"Big Box O' Porn\"", "box_facet:\"78\"", "folder_facet:\"11\""], :rows => 1000}, {}).and_return(["", "The Results"])
    
          @document = {:series_facet => "Big Box O' Porn", :box_facet => "78", :folder_facet => "11"}
          helper.folder_siblings(@document).should == "The Results"
        end
            
       it "shouldn't do anything if no series is given" do
          @document = {:folder_facet => "11", :box_facet => "78"}
          helper.folder_siblings(@document).should == []
        end
    end
    
    describe "#link_to_multifacet" do
      # <%= link_to_multifacet(@document["series_facet"], "Series: ",  "series_facet" => @document["series_facet"])  %> 
      
      it "should return nil if facet is nil" do
        helper.link_to_multifacet(nil, "prefix").should be_nil  
      end
      
      it "should return a value if a facet is given" do
        helper.link_to_multifacet("Series Title", "Series:", "series_facet" => "Series Title").should == 
           helper.link_to("Series:Series Title", catalog_index_path(f: {series_facet: ["Series Title"]}))
        
        
      end
      
        it "should return a value if a facet is given and options too" do
          helper.link_to_multifacet("Series Title", "Series:", "series_facet" => "Series Title", :options => { :confirm => "booyah?"}).should == 
            helper.link_to("Series:Series Title", catalog_index_path(f: {series_facet: ["Series Title"]}), confirm: 'booyah?')


        end
      
    end
  
  
end
