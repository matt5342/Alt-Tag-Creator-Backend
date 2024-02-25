require 'json'

class OpenAiController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
        response = OpenAiService.new.analyze_image
        # render json: response.parsed_response['choices'][0]
        # @response = response.parsed_response['choices'][0]['text']
        @response = response

    end
    # post
    def upload_image()
        @image_form = ImageForm.new(image_form_params)
        if @image_form.valid?
            if @image_form.input_type == 'url'
                response = OpenAiService.new.analyze_image(@image_form.image_url)
                @response = response
            elsif @image_form.input_type == 'text'
                # Regular expression to match image URLs
                regex = /\bhttps?:\/\/\S+\.(?:jpg|jpeg|png|gif|webp)\b/i
                @image_urls = @image_form.input_text.scan(regex)
                @responses = @image_urls.map do |url|
                    OpenAiService.new.analyze_image(url)
                end
            elsif @image_form.input_type == 'file'

            end
        end
        render :upload
        # response = OpenAiService.new.analyze_image(image_form.image_url)
        # @response = response
        # @response = response.parsed_response["choices"][0]["message"]["content"]
    end
    # get
    def upload
        @image_form = ImageForm.new(input_type: 'url')
    end

    private

    def image_form_params
    params.require(:image_form).permit(:image_url, :input_type, :input_text, :html_file)
    end
end

class ImageForm
    include ActiveModel::Model

    attr_accessor :image_url, :input_type, :input_text, :html_file

    validates :input_type, presence: true, inclusion: { in: ['url', 'text', 'file'] }
    validates :image_url, presence: true, format: URI::regexp(%w[http https]), if: -> { input_type == 'url' }
    validates :input_text, presence: true, if: -> { input_type == 'text' }
    validates :html_file, presence: true, if: -> { input_type == 'file' }
end
