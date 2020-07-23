require "thor"
require "cube_cli"
module CubeCli

  class CLI < Thor
    desc "CubeCli", "CubeCli update"
    method_option :image, :type => :string, :aliases => "-i"
    method_option :cube_id, :type => :string, :aliases => "-c"
    method_option :region, :type => :string, :aliases => "-r"
    method_option :pod_name, :type => :string, :aliases => "-p"

    def update
      image = options[:image]
      cube_id = options[:cube_id]
      region = options[:region] || 'cn-bj2'
      pod_name = options[:pod_name]
      puts CubeCli.update(region, cube_id, image, pod_name)
    end

    desc "CubeCli", "CubeCli get"
    method_option :cube_id, :type => :string, :aliases => "-c"
    method_option :region, :type => :string, :aliases => "-r"

    def get
      cube_id = options[:cube_id]
      region = options[:region] || 'cn-bj2'
      puts CubeCli.get(region, cube_id)
    end

  end
end