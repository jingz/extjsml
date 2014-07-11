require "yaml"
YAML::ENGINE.yamler = 'psych'
class ExtParser

  def self.parse(text)
    begin
      matcher = /^(\w+)(?:(?:#([\w\-]+))?(?:\.([\w\-]+))?)?(?:(?:@\{(.*)\}))*$/
      res = matcher.match text 
      xtype = res[1] 
      id = res[2]
      classes = res[3].sub("_"," ") unless res[3].nil?
      options = {}
      options.merge! :id => id unless id.nil?
      options.merge! :cls => classes unless classes.nil?

      config = res[4]

      if not config.nil? and config.strip != ""
        config = config.strip!.gsub(/\)\s+:/, ")$$:").split("$$")
        config.map! do |c|
          c.gsub!(/\(/,": ")
          c.gsub!(/\)/," ")
        end
        config = YAML.load(config * "\n")
        options.merge! config
      end
    rescue Exception => e
      puts "error near #{text}: #{e.message}"
      abort()
    end
    # TODO validate xtype
    [ xtype, options ]
  end

end
