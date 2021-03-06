module WhurlEngine
  class WhurlsController < WhurlEngine::ApplicationController
    def new
      @whurl = Whurl.new
    end

    def create
      request_params = params[:whurl]
      request_params[:request_headers] = HTTParty::Response::Headers.new(Hash[params[:header_keys].zip(params[:header_values])].delete_if { |k, _| k.blank? })
      request_params[:request_parameters] = Hash[params[:param_keys].zip(params[:param_values])].delete_if { |k, _| k.blank? }
      @whurl = Whurl.new(request_params)

      unless @whurl.save
        flash[:alert] = @whurl.errors.map {|k,v| "#{k.to_s.titleize} #{v}"}.join('\n')
        render :new and return
      end
      redirect_to short_whurl_path(@whurl)
    end

    def edit
      @whurl = Whurl.find_by_hash_key(params[:id])
    end

    def update
      @whurl = Whurl.find_by_hash_key(params[:id])
      unless @whurl.update_attributes(params[:whurl])
        render :partial => 'whurl_engine/shared/error', :locals => {:object => @whurl}
      end
      redirect_to resource_path(params[:whurl][:resource_id])
    end
    def destroy
      @whurl = Whurl.find_by_hash_key(params[:id])
      unless @whurl.destroy
        render :partial => 'whurl_engine/shared/error', :locals => {:object => @whurl}
      end
    end

    def show
      @whurl = Whurl.find_by_hash_key(params[:id])
    end
  end
end
