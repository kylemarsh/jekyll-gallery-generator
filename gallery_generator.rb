module Jekyll
	class ImagePage < Page
		# An image page
		def initialize(site, base, dir, img_source, name, prev_name, next_name)
			@site = site
			@base = base
			@dir = dir
			@name = name # Name of the generated page

			self.process(@name)
			self.read_yaml(File.join(@base, '_layouts'), 'image_page.html')
			self.data['title'] = "#{File.basename(img_source)}"
			self.data['img_src'] = img_source
			self.data['prev_url'] = prev_name
			self.data['next_url'] = next_name
			self.data['album_url'] = @dir
		end
	end

	class AlbumPage < Page
		# An album page
		#	Just a UL of images for now
		def initialize(site, base, dir)
			@site = site
			@base = base # Absolute path to use to find files for generation

			# Page will be created at www.mysite.com/#{dir}/#{name}
			@dir = dir
			@name = 'index.html'

			@album_source = File.join(site.config['album_dir'] || 'albums', @dir)

			self.process(@name)
			self.read_yaml(File.join(@base, '_layouts'), 'album_index.html')
			self.data['title'] = "#{dir}"

			self.data['images'] = []
			self.data['albums'] = []

			files, directories = list_album_contents

			directories.each do |subalbum|
				albumpage = AlbumPage.new(site, site.source, File.join(@dir, subalbum))
				self.data['albums'] << { 'name' => subalbum, 'url' => albumpage.url }
				site.pages << albumpage #FIXME: sub albums are getting included in my gallery index
			end

			files.each_with_index do |filename, idx|
				prev_file = files[idx-1] unless idx == 0
				next_file = files[idx+1] || nil

				do_image(filename, prev_file, next_file)
			end
		end

		def list_album_contents
			#FIXME: Skip non-image files
			entries = Dir.entries(@album_source)
			entries.reject! { |x| x =~ /^\./ } # Filter out ., .., and dotfiles
			files = entries.reject { |x| File.directory? File.join(@album_source, x) } # Filter out directories
			directories = entries.select { |x| File.directory? File.join(@album_source, x) } # Filter out non-directories
			return files, directories
		end

		def do_image(filename, prev_file, next_file)
			# Get info for the album page and make the image's page.

			rel_link = image_page_url(filename)
			img_source = "#{File.join(@album_source, filename)}"

			image_data = {
				'src' => img_source,
				'rel_link' => rel_link
			}

			self.data['images'] << image_data

			# Create image page
			site.pages << ImagePage.new(@site, @base, @dir, img_source,
				rel_link, image_page_url(prev_file), image_page_url(next_file))
		end

		def image_page_url(filename)
			return nil if filename == nil
			ext = File.extname(filename)
			return "#{File.basename(filename, ext)}_#{File.extname(filename)[1..-1]}.html"
		end
	end

	class GalleryGenerator < Generator
		safe true

		def generate(site)
			if site.layouts.key? 'album_index'
				base_album_path = site.config['album_dir'] || 'albums'
				albums = Dir.entries(base_album_path)
				albums.reject! { |x| x =~ /^\./ }
				albums.select! { |x| File.directory? File.join(base_album_path, x) }
				albums.each do |album|
					site.pages << AlbumPage.new(site, site.source, album)
				end
			end
		end
	end
end
