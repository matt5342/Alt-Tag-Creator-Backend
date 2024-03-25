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
                @response = analyze_image_and_handle_errors(@image_form.image_url)
                # @response = response
            elsif @image_form.input_type == 'text'
                # Regular expression to match image URLs
                regex = /\bhttps?:\/\/\S+\.(?:jpg|jpeg|png|gif|webp)\b/i
                # Extract all image URLs from the input text
                @image_urls = @image_form.input_text.enum_for(:scan, regex).map { Regexp.last_match }

                # Create a copy of the input text to build the combined response
                @response = @image_form.input_text.dup

                for i in 0...@image_urls.size
                    match = @image_urls[i]
                    # Analyze the image and get the response
                    image_response = analyze_image_and_handle_errors(match[0])
                    # Create a placeholder for the current image URL
                    placeholder = "{image_#{i}}"
                    # Replace the image URL in the combined response with the placeholder
                    @response.sub!(match[0], placeholder)
                    # Replace the placeholder in the combined response with the image description and tooltip
                    @response.sub!(placeholder, image_response[:response])
                end
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

    def analyze
        return render json: { error: 'Invalid input' } if params[:url].blank?
    end

    def upload_image_api()
        @image_form = ImageForm.new(image_form_params)
        if @image_form.valid?
            if @image_form.input_type == 'url'
                @response = [analyze_image_and_handle_errors_api(@image_form.image_url)]
            elsif @image_form.input_type == 'text'
                regex = /\bhttps?:\/\/\S+\b/i
                @urls = @image_form.input_text.enum_for(:scan, regex).map { Regexp.last_match }
                @response = []
                @urls.each do |match|
                    if match[0] =~ /\bhttps?:\/\/\S+\.(?:jpg|jpeg|png|gif|webp)(?:\?\S*)?\b/i
                        image_response = analyze_image_and_handle_errors_api(match[0])
                        @response << image_response
                    elsif match[0] =~ /\bhttps?:\/\/\S+\.(?:bmp|svg|tiff)(?:\?\S*)?\b/i
                        # Handle other image formats here
                        # For example, you might want to add a placeholder response:
                        @response << { url: match[0], error_message: "You uploaded an unsupported image. Please make sure your image is of one the following formats: ['png', 'jpeg', 'gif', 'webp']." }
                    end
                end
            else
                return render json: { error: 'Invalid input_type. It should be either url or text.' }, status: :unprocessable_entity
            end
        else
            return render json: { error: 'Invalid form data.' }, status: :unprocessable_entity
        end
        render json: @response, status: :ok
    end

    private

    def image_form_params
        params.transform_keys(&:underscore).permit(:input_type, :image_url, :input_text, :html_file)
    end
    # def image_form_params
    # params.require(:image_form).permit(:image_url, :input_type, :input_text, :html_file)
    # end
end

def analyze_image_and_handle_errors_api(url)
    response = OpenAiService.new.analyze_image(url)
    # puts JSON.pretty_generate(response.parsed_response)
    if response.parsed_response.key?("error")
        {
            error_message: response.parsed_response["error"]["message"],
        }
    else
        {
            alt_text: response.parsed_response["choices"][0]["message"]["content"],
            url: url
        }
    end
end

def analyze_image_and_handle_errors(url, pre_text = nil, post_text = nil)
    response = OpenAiService.new.analyze_image(url)
    if response.parsed_response.key?("error")
      {
        error_message: response.parsed_response["error"]["message"],
      }
    else
      {
        response: ActionController::Base.helpers
            .link_to(response.parsed_response["choices"][0]["message"]["content"], url, target: "_blank", title: "<img src='#{url}' width='100'>".html_safe, data: { bs_toggle: "tooltip", bs_html: "true" }),
      }
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
