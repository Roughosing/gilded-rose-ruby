require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, 'item'))
loader.push_dir(File.join(__dir__, 'updaters'))
loader.setup
