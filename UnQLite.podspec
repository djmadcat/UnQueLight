Pod::Spec.new do |s|
  s.name     = 'UnQLite'
  s.version  = '1.1.6'
  s.author   = 'Symisc Systems'
  s.license  = { :type => 'BSD', :file => 'license.txt' }
  s.homepage = 'http://unqlite.org/'
  s.summary  = 'UnQLite source code'
  s.description = 'UnQLite is a in-process software library which implements a self-contained, serverless, zero-configuration, transactional NoSQL database engine. UnQLite is a document store database similar to MongoDB, Redis, CouchDB etc. as well a standard Key/Value store similar to BerkeleyDB, LevelDB, etc.'
  s.source = { :http => 'http://unqlite.org/db/unqlite-db-20130825-116.zip' }
  s.requires_arc = false
  s.source_files = '*.{h,c}'

  s.prefix_header_contents = <<-EOS
#define UNQLITE_ENABLE_THREADS 1
EOS
end
