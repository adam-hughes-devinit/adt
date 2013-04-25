module AmazonHelper
  def upload(tempfile, filename)
    # tempfile is a Tempfile
    # filename is the name it should be stored as (in my case, MD5)

    s3 = AWS::S3.new(
        :access_key_id => AWS_ACCESS_KEY_ID, 
        :secret_access_key => AWS_ACCESS_SECRET_KEY 
    )
    p "Uploading file to S3 #{EXPORT_BUCKET}"

    # just in case 
    tempfile.rewind
    obj = s3.buckets[EXPORT_BUCKET].objects[filename].write(tempfile.read)

    # Oh heck, make sure people can download this stuff.

    obj.acl = :public_read

    filename
  end
end
