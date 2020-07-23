require "cube_cli/version"
require 'digest'
require 'digest/sha1'
require 'json'
require 'base64'
require 'net/http'
require 'net/https'
require 'yaml'

module CubeCli
  class Error < StandardError; end
  # TODO
  # 1、使用容器名进行更新，替换掉现有的容器id
  # 2、查找默认项目id
  # 3、完善其余信息修改，可能修改结构
  def self.update(region, cube_id, image, pod_name)
    @region = region
    @cube_id = cube_id
    @image = image
    new_pod = old_pod
    new_pod["spec"]["containers"] = old_pod["spec"]["containers"].map do |container|
      container["image"] = image if container["name"] == pod_name
      container
    end

    dict = {
      "Action" => 'RenewCubePod',
      "CubeId" => @cube_id,
      "Region" => @region,
      "ProjectId" => ENV['UCLOUD_PROJECT_ID'],
      "PublicKey" => ENV['UCLOUD_PUBLIC_KEY'],
      "Pod" => Base64.encode64(new_pod.to_yaml).split("\n").join
    }
    dict["Signature"] = signature(dict)
    send_request(dict)
    # 'Update' + image
  end

  def self.get(region, cube_id)
    @region = region
    @cube_id = cube_id
    old_pod
  end
  

  def self.signature(dict)
    a = Hash[ dict.sort_by { |key, val| key } ]
    string = ""
    a.each do |key, value|
      string << key.to_s + value.to_s
    end
    Digest::SHA1.hexdigest(string + ENV['UCLOUD_PRIVATE_KEY'])
  end

  def self.old_pod
    dict = {
      "Action" => 'GetCubePod',
      "CubeId" => @cube_id,
      "Region" => @region,
      "ProjectId" => ENV['UCLOUD_PROJECT_ID'],
      "PublicKey" => ENV['UCLOUD_PUBLIC_KEY']
    }
    dict["Signature"] = signature(dict)
    response = send_request(dict)
    pod = Base64.decode64 response["Pod"]
    YAML.load(pod)
  end
  

  def self.send_request(dict)
    uri = URI('https://api.ucloud.cn/')
  
    # Create client
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    body = JSON.dump(dict)
  
    # Create Request
    req =  Net::HTTP::Post.new(uri)
    # Add headers
    req.add_field "Content-Type", "application/json; charset=utf-8"
    # Set body
    req.body = body
  
    # Fetch Request
    res = http.request(req)
    # puts "Response HTTP Status Code: #{res.code}"
    # puts "Response HTTP Response Body: #{res.body}"
    return JSON.parse(res.body)
  rescue StandardError => e
    puts "HTTP Request failed (#{e.message})"
  end
  
end
