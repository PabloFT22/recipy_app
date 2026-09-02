require 'rails_helper'

# The importer makes the SERVER fetch a URL the user chose, which is a
# server-side request forgery vector: a public-looking URL must not be able to
# reach cloud metadata (169.254.169.254) or anything inside the private network.
RSpec.describe RecipeScraperService do
  def resolving(host_to_addresses)
    allow(Resolv).to receive(:getaddresses) do |host|
      host_to_addresses.fetch(host, ["93.184.216.34"]) # public by default
    end
  end

  describe "blocked targets" do
    {
      "cloud metadata"   => ["169.254.169.254", ["169.254.169.254"]],
      "loopback"         => ["localhost", ["127.0.0.1"]],
      "private 10.x"     => ["internal.test", ["10.0.0.5"]],
      "private 192.168"  => ["router.test", ["192.168.1.1"]],
      "private 172.16"   => ["vpc.test", ["172.16.9.9"]],
      "IPv6 loopback"    => ["v6.test", ["::1"]],
      "IPv6 unique-local" => ["v6ula.test", ["fc00::1"]]
    }.each do |label, (host, addrs)|
      it "refuses #{label}" do
        resolving(host => addrs)
        service = described_class.new("http://#{host}/recipe")

        expect(service.scrape).to be_nil
        expect(service.errors.join).to match(/not allowed|private|reserved/i)
      end
    end

    it "refuses a host that resolves to both a public and a private address" do
      resolving("split.test" => ["93.184.216.34", "10.1.2.3"])
      service = described_class.new("http://split.test/recipe")

      expect(service.scrape).to be_nil
    end

    it "refuses a non-http scheme" do
      service = described_class.new("file:///etc/passwd")
      expect(service.scrape).to be_nil
    end

    it "refuses a host that does not resolve" do
      allow(Resolv).to receive(:getaddresses).and_return([])
      service = described_class.new("http://nowhere.invalid/recipe")
      expect(service.scrape).to be_nil
    end
  end

  describe "redirects" do
    # The first URL is public and passes the check; the redirect target is not.
    # Following it without re-checking is the classic bypass.
    it "refuses a redirect into a private address" do
      resolving("public.test" => ["93.184.216.34"], "169.254.169.254" => ["169.254.169.254"])

      redirect = instance_double(
        HTTParty::Response,
        code: 302,
        headers: { "location" => "http://169.254.169.254/latest/meta-data/" }
      )
      allow(HTTParty).to receive(:get).and_return(redirect)

      service = described_class.new("http://public.test/recipe")

      expect(service.scrape).to be_nil
      expect(service.errors.join).to match(/redirect/i)
    end

    it "gives up rather than following redirects forever" do
      resolving("public.test" => ["93.184.216.34"])

      loop_response = instance_double(
        HTTParty::Response,
        code: 302,
        headers: { "location" => "http://public.test/again" }
      )
      allow(HTTParty).to receive(:get).and_return(loop_response)

      service = described_class.new("http://public.test/recipe")

      expect(service.scrape).to be_nil
      expect(service.errors.join).to match(/redirect/i)
    end
  end

  describe "allowed targets" do
    it "fetches an ordinary public URL" do
      resolving("example.com" => ["93.184.216.34"])

      page = instance_double(
        HTTParty::Response,
        code: 200,
        success?: true,
        headers: {},
        body: <<~HTML
          <html><head><title>Test Pasta</title></head>
          <body><h1>Test Pasta</h1></body></html>
        HTML
      )
      allow(HTTParty).to receive(:get).and_return(page)

      service = described_class.new("https://example.com/recipes/pasta")
      expect(service.scrape).to be_a(Hash)
    end
  end
end
