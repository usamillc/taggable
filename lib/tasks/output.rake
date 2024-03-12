namespace :output do
  desc "Output person htmls"
  task :html, [:category] => :environment do |task, args|
    c = Category.find_by(name: args[:category])
    next unless c
    puts c.pages.count

    dir = "output/#{args[:category]}"
    Dir.mkdir(dir) unless File.exists?(dir)

    c.pages.each do |page|
      File.open("#{dir}/#{page.pageid}", 'w') do |f|
        page.paragraphs.each do |p|
          f.write("#{p.body}\n")
        end
      end
    end
  end
end
