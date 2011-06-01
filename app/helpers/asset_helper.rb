
module AssetHelper

 # returns the flipbook url
  def flipbook_tag(id)
      flipbook_url = "#{url_for(:action => 'show', :controller => 'asset', :id => id, :format => :flipbook )}"
      pdf_url = "#{url_for(:action => 'show', :controller => 'asset', :id => id, :format => :pdf)}"
      iframe =  "<iframe src='#{flipbook_url}' width='99%' height='450px'/>"
      flipbook_link = "<a href='#{flipbook_url}' style='cursor:pointer;' onclick=\"window.open('#{flipbook_url}','status=0','toolbar=0','location=0','menubar=0','directories=0','navigation=0');return false;\">Open viewer in new window</a>"
      pdf_link = "<a href='#{pdf_url}' style='cursor:pointer;' onclick=\"window.open('#{pdf_url}], 'status=0', 'toolbar=0', 'location=0', 'menubar=0', 'directories=0', 'navigation=0'); return false;\">Download PDF</a>"
      return "#{iframe}#{flipbook_link}<br/>#{pdf_link}".html_safe
  end
  
  
end