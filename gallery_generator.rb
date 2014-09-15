module Jekyll
	class ImagePage < Page
		# An image page
		def initialize(site, base, dir, name, image)
			@site = site
			@base = base
			@dir = dir
			@name = name # Name of the generated page

			self.process(@name)
			self.read_yaml(File.join(base, '_layouts'), 'image_page.html')
			self.data['title'] = "#{image}"
			self.data['img_src'] = image
		end
	end

	class AlbumPage < Page
		# An album page
		#	Just a UL of images for now
		def initialize(site, base, dir, parent)
			@site = site
			@base = base
			@dir = dir
			@name = 'index.html' # Name of the generated page

			self.process(@name)
			self.read_yaml(File.join(base, '_layouts'), 'album_index.html')
			self.data['title'] = "#{dir}"

			self.data['images'] = []
			d = Dir.open(File.join(parent, dir))
			d.each do |file|
				next if /^\.\.?/ =~ file
				#TODO: Skip non-image files
				ext = File.extname(file)
				rel_link = "#{File.basename(file, ext)}_#{File.extname(file)[1..-1]}.html"
				img_src = "#{File.join(d.path, file)}"
				image_data = {
					'src' => img_src,
					'rel_link' => rel_link
				}
				self.data['images'] << image_data

				# Create image page
				site.pages << ImagePage.new(site, base, dir, rel_link, img_src)
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
					site.pages << AlbumPage.new(site, site.source, album, d.to_path)
				end
			end
		end
	end
end
