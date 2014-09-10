module Jekyll
	class GalleryPage < Page
		# A gallery page
		#	Just a UL of images for now
		def initialize(site, base, dir, parent, gallery)
			@site = site
			@base = base
			@dir = dir
			@name = 'index.html' # Name of the generated page

			self.process(@name)
			self.read_yaml(File.join(base, '_layouts'), 'gallery_index.html')
			self.data['title'] = "#{gallery}"

			self.data['images'] = []
			d = Dir.open(File.join(parent, gallery))
			d.each do |file|
				next if /^\.\.?/ =~ file
				#TODO: Do we want to generate thumbnails to put on this page?
				self.data['images'] << File.join(d.path, file)
			end
		end
	end

	class GalleryGenerator < Generator
		safe true

		def generate(site)
			if site.layouts.key? 'gallery_index'
				base_gallery_path = site.config['gallery_dir'] || 'galleries'
				d = Dir.open(base_gallery_path)
				d.each do |gallery|
					next if /^\.\.?$/ =~ gallery
					# TODO: split to recursive helper to handle sub-galleries
					site.pages << GalleryPage.new(site, site.source, gallery, d.to_path, gallery)
				end
			end
		end
	end
end
