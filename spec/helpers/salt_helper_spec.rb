require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include SaltHelper

   

describe SaltHelper do
  include SaltHelper
  

  
  describe "#index_results_box" do
    it "should call index_group_results if there's a grouping facet" do
       helper.stub(:grouping_facet => 'year_facet')
       expect(helper).to receive(:index_grouped_results).with('year_facet').once
       expect(helper).to receive(:index_ungrouped_results).never
       helper.index_results_box
    end
    
    it "should call index_ungrouped_results if there's not a grouping facet" do
       helper.stub(:grouping_facet => nil)
       expect(helper).to receive(:index_grouped_results).never
       expect(helper).to receive(:index_ungrouped_results).once
       helper.index_results_box
    end   
  end
  
  describe "#index_grouped_results" do
    it "should render the partial correctly with the proper locals" do
      @response = double("SolrResponse")
      
      docs = double("SolrDocuments")
      grouping = [["1990", "docs"]] 
      expect(docs).to receive(:group_by).once.and_return(grouping)
      expect(@response).to receive(:docs).once.and_return(docs)
      helper.stub(:viewing_context => "gallery")
      expect(helper).to receive(:render_partial).with('catalog/_index_partials/group',{ :docs => "docs", :facet_name => "year_facet", :facet_value => "1990", :view_type => 'gallery' } ).once.and_return("")
      helper.index_grouped_results('year_facet')
    end    
  end
  
  describe "#index_ungrouped_results" do
    it "should render the partial correctly with the proper locals" do
      @response = double("SolrResponse")
      docs = double("SolrDocuments")
      expect(@response).to receive(:docs).once.and_return(docs)
      helper.stub(:viewing_context => "gallery")
      expect(helper).to receive(:render_partial).with('catalog/_index_partials/group',{ :docs => docs, :facet_name => nil, :facet_value => nil, :view_type => 'gallery' } ).once
      helper.index_ungrouped_results()
    end
  end
  
  describe "#render_partial" do
    it "should render the partial with the local params passed in" do
      expect(helper).to receive(:render).with(:locals => {:some_stuff => 'some_value'}, :partial => 'my_partial')
      helper.render_partial('my_partial', { :some_stuff => "some_value"})
    end
  end
  
  describe "#index_results_class" do
    it "should return the right css class for list view" do
      helper.stub(:viewing_context => "list")
      expect(helper.index_results_class).to eq("list_index")
       expect(helper.index_results_class).not_to eq("gallery_index")
    end
    
    it "should return the right css class for gallery view" do
      helper.stub(:viewing_context => "gallery")
      expect(helper.index_results_class).not_to eq("list_index")
      expect(helper.index_results_class).to eq("gallery_index")
    end
  end
  
  describe "#viewing_context" do
    it "should return gallery is no params are set" do
      expect(helper.viewing_context).to eq("gallery")
    end
    
    it "should return gallery is params[:view] == gallery" do 
      helper.stub(:params => {:view => 'gallery'})
      expect(helper.viewing_context).to eq("gallery")
    end
    
     it "should return view is params[:view] == list" do 
        helper.stub(:params => {:view => 'list'})
        expect(helper.viewing_context).to eq("list")
        expect(helper.viewing_context).not_to eq("gallery")
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
      expect(helper.grouping_facet).to eq(nil)
    end
    
    it "should return the proper values " do
       helper.stub(:params => {:sort => 'year_sort desc, month_sort asc, day_sort asc, title_sort asc'})
       expect(helper.grouping_facet).to eq('year_facet')
    end
    
    it "should return the proper values " do
        helper.stub(:params => {:sort => 'year_sort asc, month_sort asc, day_sort asc, title_sort asc'})
        expect(helper.grouping_facet).to eq('year_facet')
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
      expect(docs).to receive(:length).and_return(3)
      expect(response).to receive(:docs).once.and_return(docs)
      
      expect(helper.grouped_result_count(response)).to eq("3 documents")
    end
    
    it "should return the count and the correct pluziation of document when there are no facets" do
      response = double("SolrResponse")
      docs = double("SolrDocuments")
      expect(docs).to receive(:length).and_return(1)
      expect(response).to receive(:docs).once.and_return(docs)

      expect(helper.grouped_result_count(response)).to eq("1 document")
    end
    
    it "should return the count and the correct pluziation of document when there is a facet" do
      response = double("SolrResponse")
      facets = double("SolrFacets")
      items = double("SolrItems")
      item = double("FacetItem")
      expect(facets).to receive(:detect).and_return(facets)
      expect(facets).to receive(:items).and_return(items)
      expect(items).to receive(:detect).and_return(item)
      expect(item).to receive(:hits).and_return(3)
      expect(response).to receive(:facets).once.and_return(facets)

      expect(helper.grouped_result_count(response, "somefacet_s", "some_value")).to eq("3 documents")
    end
    
  end
  
  describe "#display_group_heading" do
   
      
    it "should return the proper html when give the facet_name and facet_value strings" do
      expect(helper).to receive(:grouped_result_count).and_return("99 foofoos")
      expect(helper.display_group_heading("foo", "bar")).to eq("<h3>bar<em>&nbsp;&nbsp;&nbsp;99 foofoos</em></h3>")
    end
    
    it "should return the proper html when given the facet_name but not facet_value" do
      expect(helper).to receive(:grouped_result_count).and_return("107 foofoos")
      expect(helper.display_group_heading("foo")).to eq("<h3><em>&nbsp;&nbsp;&nbsp;107 foofoos</em></h3>")
    end
    
    it "should return the proper htm when given the facet_name string and facet_value as an array" do
      expect(helper).to receive(:grouped_result_count).and_return("2 foofoos")
      expect(helper.display_group_heading("foo", ["bar", "jar"])).to eq("<h3>bar<em>&nbsp;&nbsp;&nbsp;2 foofoos</em></h3>")
    end
  end 
  
  describe "#remove_druid_prefix" do 
    it "should return the string with the druid: prefix removed" do
      expect(helper.remove_druid_prefix("druid:foo")).to eq("foo")
    end
    
    it "should return the string if there is not druid: prefix" do 
      expect(helper.remove_druid_prefix("foo")).to eq("foo")
    end
  end
  
  describe "#thumbtag" do
    it "should return an img tag with the proper src pointing to an assets thumbnail" do
      expect(helper.thumb_tag("druid:123")).to eq("<img src=/assets/123.jpg alt=\"druid:123\"/>")
    end
  end
  
  
   describe "#facets_display_heading" do 
      it "should return the proper text when in the show context" do
        expect(helper).to receive(:action_name).and_return("show")
        expect(helper.facets_display_heading).to eq("This Document Refers To")
      end

       it "should return the proper text when in the any other context" do
          expect(helper).to receive(:action_name).and_return("index")
          expect(helper.facets_display_heading).to eq("Limit Your Search")
        end

    end
    
    describe "#display_notes" do
      
      it "should return the html in the correct format" do 
          @document = { "notes_display" => ["this is the story", "of a three hour tour"] }       
          expect(helper.display_donor_notes).to eq("<dt class='blacklight-notes_display'>Donor Notes:</dt><dd class='blacklight-notes_display'>this is the story<br/><br/>of a three hour tour")
      end
    end
    
    describe "#render_salt_pagination_info" do
      
       it "should return the proper html given a solr response with no docs" do
          @solr_response = double("SolrResponse")
          docs = double("SolrDocuments")
          expect(docs).to receive(:length).twice.and_return(0)
          expect(docs).to receive(:first).never
          
          expect(@solr_response).to receive(:empty?).and_return(true)
          expect(@solr_response).to receive(:docs).at_least(1).and_return(docs)
          expect(@solr_response).to receive(:start).twice.and_return(0)
          expect(@solr_response).to receive(:rows).at_least(1).and_return(0)
          expect(@solr_response).to receive(:total).twice.and_return(0)

          expect(helper.render_salt_pagination_info(@solr_response)).to eq("No entries found")

       end
      
       it "should return the proper html given a solr response with 1 docs" do
          @solr_response = double("SolrResponse")
          docs = double("SolrDocuments")
          expect(docs).to receive(:length).twice.and_return(1)

          first = SolrDocument.new 
          expect(docs).to receive(:first).and_return(first)

          expect(@solr_response).to receive(:empty?).and_return(false)
          expect(@solr_response).to receive(:docs).at_least(1).and_return(docs)
          expect(@solr_response).to receive(:start).twice.and_return(0)
          expect(@solr_response).to receive(:rows).at_least(1).and_return(0)
          expect(@solr_response).to receive(:total).twice.and_return(1)

          expect(helper.render_salt_pagination_info(@solr_response)).to eq("Displaying <b>1</b> solr document")
        end
        
        it "should return the proper html given a solr response with multiple docs but not paginated" do
            @solr_response = double("SolrResponse")
            docs = double("SolrDocuments")
            expect(docs).to receive(:length).twice.and_return(5)

            first = SolrDocument.new 
            expect(docs).to receive(:first).and_return(first)

            expect(@solr_response).to receive(:empty?).and_return(false)
            expect(@solr_response).to receive(:docs).at_least(1).and_return(docs)
            expect(@solr_response).to receive(:start).twice.and_return(0)
            expect(@solr_response).to receive(:rows).at_least(1).and_return(10)
            expect(@solr_response).to receive(:total).twice.and_return(5)

            expect(helper.render_salt_pagination_info(@solr_response)).to eq("Displaying <b>all 5</b> solr documents")
          end
        
      
         it "should return the proper html given a solr response with many docs paginated" do
            @solr_response = double("SolrResponse")
            docs = double("SolrDocuments")
            expect(docs).to receive(:length).once.and_return(100000000)

            first = double("SolrDoc")
            expect(docs).to receive(:first).and_return(first)

            expect(@solr_response).to receive(:empty?).and_return(false)
            expect(@solr_response).to receive(:docs).at_least(1).and_return(docs)
            expect(@solr_response).to receive(:start).twice.and_return(2)
            expect(@solr_response).to receive(:rows).at_least(1).and_return(0)
            expect(@solr_response).to receive(:total).twice.and_return(100000000)

            expect(helper.render_salt_pagination_info(@solr_response)).to eq("<span id='salt_pagination_info'><b>3 - 100,000,002</b> of <b>100,000,000</b></span>") 
          end
    end
    
    
    describe "#folder_siblings" do
      
      it "should return nil if box, folder, and series are not given" do
        @document = {}
        expect(helper.folder_siblings(@document)).to be_empty
      end
      
      it "should query Blacklight if series is given" do
        expect(helper).to receive(:get_search_results).with({:fq =>  ["series_facet:\"Big Box O' Porn\""], :rows => 1000}, {}).and_return(["", "The Results"])
        
        @document = {:series_facet => "Big Box O' Porn"}
        expect(helper.folder_siblings(@document)).to eq("The Results")
      end
      
        it "should query Blacklight if series and box is given" do
          expect(helper).to receive(:get_search_results).with({:fq =>  ["series_facet:\"Big Box O' Porn\"", "box_facet:\"78\""], :rows => 1000}, {}).and_return(["", "The Results"])
    
          @document = {:series_facet => "Big Box O' Porn", :box_facet => "78"}
          expect(helper.folder_siblings(@document)).to eq("The Results")
        end
      
      
       it "should query Blacklight if series and box and folder are given" do
          expect(helper).to receive(:get_search_results).with({:fq =>  ["series_facet:\"Big Box O' Porn\"", "box_facet:\"78\"", "folder_facet:\"11\""], :rows => 1000}, {}).and_return(["", "The Results"])
    
          @document = {:series_facet => "Big Box O' Porn", :box_facet => "78", :folder_facet => "11"}
          expect(helper.folder_siblings(@document)).to eq("The Results")
        end
            
       it "shouldn't do anything if no series is given" do
          @document = {:folder_facet => "11", :box_facet => "78"}
          expect(helper.folder_siblings(@document)).to eq([])
        end
    end
    
    describe "#link_to_multifacet" do
      # <%= link_to_multifacet(@document["series_facet"], "Series: ",  "series_facet" => @document["series_facet"])  %> 
      
      it "should return nil if facet is nil" do
        expect(helper.link_to_multifacet(nil, "prefix")).to be_nil  
      end
      
      it "should return a value if a facet is given" do
        expect(helper.link_to_multifacet("Series Title", "Series:", "series_facet" => "Series Title")).to eq( 
           helper.link_to("Series:Series Title", catalog_index_path(f: {series_facet: ["Series Title"]}))
        )
        
        
      end
      
        it "should return a value if a facet is given and options too" do
          expect(helper.link_to_multifacet("Series Title", "Series:", "series_facet" => "Series Title", :options => { :confirm => "booyah?"})).to eq( 
            helper.link_to("Series:Series Title", catalog_index_path(f: {series_facet: ["Series Title"]}), confirm: 'booyah?')
          )


        end
      
    end
  
  
end
