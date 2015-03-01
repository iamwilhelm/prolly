
Gem::Specification.new do |s|
  s.name = "prolly"
  s.version = '0.0.1'
  s.date = '2015-02-15'
  s.summary = 'Domain Specific Language for expressing probabilities in code'
  s.description = "Just like a database has a query language like SQL this is a query language specifically for answering questions about probabilities of events based on the samples you have seen before"
  s.authors = ["Wil Chung"]
  s.email = "iamwil@gmail.com"
  s.files = [Dir.glob(File.join('lib', '**', '**')), 'LICENSE', 'README.markdown'].flatten
  s.add_runtime_dependency('moped', '~> 2.0', '>= 2.0.3')
  s.homepage = "https://github.com/iamwilhelm/prolly"
  s.license = 'MIT'
end

