class RobocodesController < ApplicationController

  def index
    # This bounces the project off of Robocoder

    project = Project.find(params[:project_id])

    require 'open-uri'
    code_text = "#{project.title} #{project.description}".gsub(/[^[\w\s]]/, '')

    if code_text != " "
      robocode_url= URI.encode("http://aid-robocoder.herokuapp.com/classify/#{code_text}")
      begin
        res = open(robocode_url){|io| io.read}
        code = JSON.parse(res)
        robocode = {
          text: "#{code['guess_name']} (#{code["guess_code"]})",
          code: "#{code['guess_name']}",
          url: robocode_url,
        }
      rescue
        robocode = {
          text: "Oops, there was an error.",
          code: "",
          url: robocode_url,
        }  
      end
    else
        robocode = {
          text: "No text to robocode!",
          code: "",
          url: ""
        } 
    end 

    render json: robocode 

  end

end
