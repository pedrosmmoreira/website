class OpenGraph
  SITE_URL = "https://pedrosmmoreira.com".freeze

  def self.canonical_url(request)
    "#{SITE_URL}#{request.path}"
  end

  def self.default_og_image_url
    "#{SITE_URL}/icon.png"
  end
end
