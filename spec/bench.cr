require "benchmark"
require "json"
require "http/client"

data = {
  "LANG" => "en",
  "TEXT" => "Hello, World!",
  "TEXT2" => "Hello, World!",
  "value" => "1",
  "SUBTEXT" => "Some subtext with spaces"
}

Benchmark.ips do |x|
  x.report("http params") do
    form_params = HTTP::Params.build do |params|
      data.each do |key, value|
        params.add key, value
      end
    end

    form_data_string = form_params.to_s

    parsed_form_params = HTTP::Params.parse(form_data_string)
  end

  x.report("json") do
    json_data = data.to_json

    # Decoding data from JSON
    decoded_data = JSON.parse(json_data)
  end
end
