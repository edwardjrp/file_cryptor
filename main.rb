require "rubygems"
require "base64"
require "fileutils"
require "date"
require "openssl"
require "securerandom"
require "uri"

class EncodeXml

  def initialize
    #@IV = SecureRandom.hex(5) #Resulting hex is twise the length of hex param
    @KEY = Base64.decode64("CHANGEME FOR SOMETHING MORE SECURE")
    @IV = Base64.decode64("CHANGE ME FOR SOMETHING MORE SECURE")

    #Development
    #@apispath = "/data/arinc/inbound/"
    #@apisdest = "/data/arinc/enc/"
    #@apisdest_test = "/data/arinc/enc/test/"
    #@apispath_test = "/data/arinc/inbound/test/"

    #Production
    #@apispath = "/data/avinet3/inbound/"
    @apispath = "/home/edward/apis_dni/loaded/"
    #@apisdest = "/data/avinet3/enc/"
    @apisdest = "/home/edward/apis_dni/apis/"    
    
    @apisdest_test = "/data/avinet3/enc/test/"
    @apispath_test = "/data/avinet3/inbound/test/"

    #Test Session on Production
    #@apispath = "/data/avinet3/inbound/test/"
    #@apiscopy = "/data/avinet3/wrapper/apisparse/ifbound/test/"
    #@apisdest = "/data/avinet3/enc/test/"

  end

  #Get today apis
  def getapis_filenames()
    #Bulding  today apis filenames
    today = Date.today.to_s
    today_a = today.split("-")
    year = today_a[0]
    mon = today_a[1]
    day = today_a[2]
    files = "in-#{mon}#{day}#{year}*.rcv"
  end

  def encode_file(file)
    self.encryptData(file)
  end

  def encryptData(file)
    aes = OpenSSL::Cipher.new("aes-128-cbc")
    aes.encrypt
    aes.key = @KEY
    aes.iv = @IV

    f = File.open(file,"r:utf-8")
    buffer = ""
    secured = ""
    while (l = f.gets)
      buffer << l
    end
    f.close

    buffer = Base64.encode64(buffer)
    secured << aes.update(buffer)
    secured << aes.final
    buffer = Base64.encode64(secured)
  end

  def decryptData(file)
    #des-ede3-cbc
    aes = OpenSSL::Cipher.new("aes-128-cbc")
    aes.decrypt
    aes.key = @KEY
    aes.iv = @IV

    f = File.open(file,"r:utf-8")
    buffer = ""
    while (l = f.gets)
      buffer << l
    end
    f.close

    secure = Base64.decode64(buffer)
    unsecured = aes.update(secure)
    unsecured << aes.final
    buffer = Base64.decode64(unsecured)
  end


  def decode_file(file)
    self.decryptData(file)
  end

  def batch_inbound
    #fullpath = @apispath + getapis_filenames()
    all_apis = "in-*.rcv"
    fullpath = @apispath + all_apis

    Dir.glob(fullpath).each { |f|
      filename = File.basename(f)
      encfile = encode_file(f)

      #Movin inbound file to ifbound
      #FileUtils.mv f,@apiscopy
      FileUtils.rm f, :force => true

      encfile_fullpath = @apisdest + filename
      outfile = File.new(encfile_fullpath,"w:utf-8")
      outfile.puts(encfile)
      outfile.close

    }

  end

  def batch_inbound_test
    #fullpath = @apispath_test + getapis_filenames()
    all_apis = "in-*.RCV"
    fullpath = @apispath_test + all_apis

    Dir.glob(fullpath).each { |f|
      filename = File.basename(f)
      encfile = encode_file(f)

      #Removing unneeded file
      FileUtils.rm f, :force => true

      encfile_fullpath = @apisdest_test + filename
      outfile = File.new(encfile_fullpath,"w:utf-8")
      outfile.puts(encfile)
      outfile.close

    }

  end


end


if ARGV.size == 2
  infile = ARGV[0]
  op = ARGV[1]

  encoder = EncodeXml.new
  if op == "e"
    puts encoder.encode_file(infile)
  end

  if op == "d"
    puts encoder.decode_file(infile)
  end

else

  #Daemonized loop
  #loop do
    #Procesing inbound production session
    encoder = EncodeXml.new
    encoder.batch_inbound

    #Processing inbound/test session
    #encoder_test = EncodeXml.new
    #encoder_test.batch_inbound_test

    #Waits 2 minutes before executes again
    #sleep(120)

  #end

end



