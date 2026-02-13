class JournalEntry
  CONTENT_DIR = Rails.root.join("content", "journal")

  attr_reader :title, :date, :slug, :description, :body_html

  def initialize(front_matter:, body:)
    @title = front_matter["title"]
    @date = Date.parse(front_matter["date"].to_s)
    @slug = front_matter["slug"]
    @description = front_matter["description"]
    @body_html = render_markdown(body)
  end

  def self.all
    @all ||= Dir.glob(CONTENT_DIR.join("*.md")).map { |path| from_file(path) }
      .sort_by(&:date)
      .reverse
  end

  def self.find_by_slug!(slug)
    all.find { |entry| entry.slug == slug } || raise(ActionController::RoutingError, "Journal entry not found: #{slug}")
  end

  def self.reset!
    @all = nil
  end

  def formatted_date
    date.strftime("%B %-d, %Y")
  end

  private

  def self.from_file(path)
    parsed = FrontMatterParser::Parser.parse_file(path)
    new(front_matter: parsed.front_matter, body: parsed.content)
  end

  def render_markdown(text)
    renderer = HtmlWithRouge.new
    markdown = Redcarpet::Markdown.new(renderer,
      fenced_code_blocks: true,
      autolink: true,
      tables: true,
      strikethrough: true,
      footnotes: true
    )
    markdown.render(text).html_safe
  end
end
