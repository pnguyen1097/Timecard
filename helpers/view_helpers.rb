module ViewHelpers

  def element path
    content = File.read(File.expand_path('views/elements/' + path + '.erb'))
    t = ERB.new(content)
    t.result(binding)
  end

end
