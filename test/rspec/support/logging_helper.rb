module LoggingHelper
  
  def log_page_on_fail
    page_html = ""
    begin
      page_html = page.html 
      yield    
    rescue Exception => e
      error("Error: " + e.inspect)
      error("Showing page.html for error (debugging) : \n\n\n\n\n\n\n" + page_html + "\n\n\n\n\END - PAGE ON FAIL \n\n\n\n")
      error("Error: " + e.inspect)
      puts e.backtrace
      raise e
    end
    
  end
  
  def log_page
    page_html = page.html 
    log("Showing page.html: \n\n\n\n\n\n\n" + page_html + "\n\n\n\n\END - PAGE  \n\n\n\n")
  end

  
  
  def write_page_to_file(file_name)
    puts "Writing page to file: " + file_name
    aFile = File.new(file_name, "w")
    aFile.write(page.html)
    aFile.close
  end
  
  
  def info(message)
    log(message, "INFO ")
  end  
  
  def debug(message)
    #log(message, "DEBUG")
  end  
  
  def error(message)
    log(message, "ERROR")
  end
  
  def log(message, level = "INFO ")
    timeStr = Time.now.inspect
    timeParts = timeStr.split(" ")
    puts timeParts[0] + " " + timeParts[1] + " | " + level + " | " + message
  end
    
    
end  


RSpec.configuration.include LoggingHelper, :type => helper_module_include_type


