require 'twitter_ebooks'
require 'google/apis/vision_v1'
require 'base64'

class IsThisALlamaBot < Ebooks::Bot

  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = '' # Your app consumer key
    self.consumer_secret = '' # Your app consumer secret
  end

  def on_mention(tweet)
    if !(photo = meta(tweet).media_uris('large')[0])
      reply(tweet, meta(tweet).reply_prefix + "I don't know, did you forget to include a photo?")
    else
      answer = is_this_a_llama(photo)
      reply(tweet, meta(tweet).reply_prefix + answer)
    end
  end

  def is_this_a_llama(photo)
    object = "llama" # Name of the object we're asking the Google Vision API for
    synonyms = ["alpaca"] # Alternate names that should be treated as similar
    google_api_key = '' # Your Google API key
    vision = Google::Apis::VisionV1::VisionService.new
    vision.key = google_api_key
    image = Google::Apis::VisionV1::Image.new(content: open(photo).read)
    feature = Google::Apis::VisionV1::Feature.new(type: 'LABEL_DETECTION')
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(requests: [
      {
        image: image,
        features: [feature]
        }])
    result = vision.annotate_image(req)
    labels = []
    result.responses[0].label_annotations.each do |r|
      labels.push(r.description)
    end
    if labels.include? object
      return "Yes! This is a " + object + "!"
    elsif (!(labels & synonyms).empty?)
      return "Hmmm... Maybe a" + (labels & synonyms)[0]
    else
      return "Nope"
    end
  end


end

IsThisALlamaBot.new("IsThisALlama") do |bot|
  bot.access_token = "" # Token connecting the app to this account
  bot.access_token_secret = "" # Secret connecting the app to this account
end
