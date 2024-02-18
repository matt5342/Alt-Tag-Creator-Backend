# app/services/open_ai_service.rb
class OpenAiService
    include HTTParty
    base_uri 'https://api.openai.com'
  
    def initialize
      @headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{Rails.application.credentials.openai[:api_key]}"
      }
    end
  
    def analyze_image
      body = {
        'model' => 'gpt-4-vision-preview',
        'messages' => [
          {
            'role' => 'user',
            'content' => [
              { 'type' => 'text', 'text' => 'What’s in this image?' },
              {
                'type' => 'image_url',
                'image_url' => {
                  'url' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg'
                }
              }
            ]
          }
        ]
      }
  
      self.class.post('/v1/engines/davinci-codex/completions', headers: @headers, body: body.to_json)
    end
  end