module Mogrify

  @@image_types = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf']
  @@mp3_types = ['audio/mpeg', 'audio/x-mpeg', 'audio/mp3', 'audio/x-mp3', 'audio/mpeg3',
                'audio/x-mpeg3', 'audio/mpg', 'audio/x-mpg', 'audio/x-mpegaudio']


  
  def transliterate(str)
    # Escape str by transliterating to UTF-8 with Iconv
    #s = Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s
    s = str
  
    s.downcase!
    s.gsub!(/'/, '')
    s.gsub!(/[^A-Za-z0-9]+/, ' ')
    s.strip!
    s.gsub!(/\ +/, '-')
  
    return s
  end  
  
  private
  
  def transliterate_file_name(str)
    logger.info "tfn gets: #{str}"
    extension = File.extname(str).gsub(/^\.+/, '')
    filename = str.gsub(/\.#{extension}$/, '')
    return "#{transliterate(filename)}.#{transliterate(extension)}"
  end  

end