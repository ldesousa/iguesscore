class HomeController < ApplicationController
  def geoproxy

    require 'net/http'
    require 'timeout'

    rawurl = CGI::unescape(params[:url])
    
    fixedurl = rawurl.gsub('\\', '%5C')   # Escape backslashes... why oh why???!?
    r = nil;

    status = 200
    content_type = 'text/html'
    
    begin
      Timeout::timeout(15) {        # Time, in seconds
        
        if request.get? then
        
          print "GeoProxy sending GET request to: " + String(fixedurl)
          
          res = Net::HTTP.get_response(URI.parse(fixedurl))

          status = res.code    # If there was an  error, pass that code back to our caller
          content_type = res['content-type']
 
          # if content_type.include? 'charset=' then
            @page = res.body
          # else
          #   @page = res.body.force_encoding('ISO-8859-1').encode('UTF-8')   # Force the encoding to be UTF-8
          # end
        
        elsif request.post? then
          
          uri = URI(String(fixedurl))
          post = Net::HTTP::Post.new(uri.path + '?' + uri.query)
          post.body = String(request.body.read())
          post.content_type = 'text/xml' 
          
          res = Net::HTTP.start(uri.host, uri.port) do |http|
            http.request(post)
          end
          
          status = res.code    # If there was an  error, pass that code back to our caller
          @page = res.body
          content_type = res['content-type']
          
        else 
          
          print "GeoProxy couldn't decode request: " + String(fixedurl)
          
        end
        
      }

    rescue Timeout::Error
      @page = "TIMEOUT"
      status = 504    # 504 Gateway Timeout  We're the gateway, we timed out.  Seems logical.
    end

    render :layout => false, :status => status, :content_type => content_type
  end
end

