xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
    xml.changefreq "weekly"
  end

  %w[now projects about].each do |page|
    xml.url do
      xml.loc url_for(controller: "pages", action: page, only_path: false)
      xml.changefreq "monthly"
    end
  end

  @entries.each do |entry|
    xml.url do
      xml.loc journal_entry_url(slug: entry.slug)
      xml.lastmod entry.date.iso8601
      xml.changefreq "yearly"
    end
  end
end
