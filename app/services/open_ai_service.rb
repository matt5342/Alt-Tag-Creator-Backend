require 'open-uri'
require 'mini_magick'

class OpenAiService
    include HTTParty
    base_uri 'https://api.openai.com'

    def initialize
      @headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{Rails.application.credentials.openai[:api_key_marshall]}"
      }
    end

    def analyze_image(image_url)
      body = {
        'model' => 'gpt-4-vision-preview',
        'messages' => [
          {
            'role' => 'user',
            'content' => [
              { 'type' => 'text', 'text' => 'Describe image succinctly with less than 150 characters' },
              {
                'type' => 'image_url',
                'image_url' => {
                  'url' => image_url,
                  'detail' => 'low'
                }
              }
            ]
          }
        ]
      }

      response = self.class.post("/v1/chat/completions", headers: @headers, body: body.to_json)
      return response
    end

    def self.reduce_image_quality(url, quality)
      # Open the image from the URL
      image = MiniMagick::Image.open(url)

      # Reduce the quality of the image
      image.quality(quality)

      # Save the image to a temp file
      temp_file = Tempfile.new(['reduced', '.jpg'])
      image.write(temp_file.path)

      # Read the temp file and encode it as base64
      base64_image = Base64.strict_encode64(File.read(temp_file.path))

      # Ensure the temp file is deleted
      temp_file.close
      temp_file.unlink

      base64_image
    end

  end
