module Jekyll
	class AlbumPage < Page
		# An album page
		#	Just a UL of images for now
		def initialize(site, base, dir, parent, album)
			@site = site
			@base = base
			@dir = dir
			@name = 'index.html' # Name of the generated page

			self.process(@name)
			self.read_yaml(File.join(base, '_layouts'), 'album_index.html')
			self.data['title'] = "#{album}"

			self.data['images'] = []
			d = Dir.open(File.join(parent, album))
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
			if site.layouts.key? 'album_index'
				base_album_path = site.config['album_dir'] || 'albums'
				d = Dir.open(base_album_path)
				d.each do |album|
					next if /^\.\.?$/ =~ album
					# TODO: split to recursive helper to handle sub-albums
					site.pages << AlbumPage.new(site, site.source, album, d.to_path, album)
				end
			end
		end
	end
end
