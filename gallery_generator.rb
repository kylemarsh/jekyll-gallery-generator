module Jekyll
	class ImagePage < Page
		# An image page
		def initialize(site, base, dir, img_source, name, prev_name, next_name, album_page)
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
			self.data['album_url'] = album_page
		end
	end

	class AlbumPage < Page
		# An album page

		DEFAULT_METADATA = {
			'sort' => 'filename asc',
			'paginate' => 50,
		}

		def initialize(site, base, dir, page=0)
			@site = site
			@base = base # Absolute path to use to find files for generation

			# Page will be created at www.mysite.com/#{dir}/#{name}
			@dir = dir
			@name = album_name_from_page(page)

			@album_source = File.join(site.config['album_dir'] || 'albums', @dir)
			@album_metadata = get_album_metadata

			self.process(@name)
			self.read_yaml(File.join(@base, '_layouts'), 'album_index.html')

			self.data['title'] = "#{dir}"
			self.data['images'] = []
			self.data['albums'] = []
			self.data['description'] = @album_metadata['description']
			self.data['hidden'] = true if @album_metadata['hidden']

			files, directories = list_album_contents

			#Pagination
			num_images = @album_metadata['paginate']
			if num_images
				first = num_images * page
				last = num_images * page + num_images
				self.data['prev_url'] = album_name_from_page(page-1) if page > 0
				self.data['next_url'] = album_name_from_page(page+1) if last < files.length
			end

			if page == 0
				directories.each do |subalbum|
					albumpage = AlbumPage.new(site, site.source, File.join(@dir, subalbum))
					if !albumpage.data['hidden']
						self.data['albums'] << { 'name' => subalbum, 'url' => albumpage.url }
					end
					site.pages << albumpage #FIXME: sub albums are getting included in my gallery index
				end
			end

			files.each_with_index do |filename, idx|
				if num_images
					next if idx < first
					if idx >= last
						site.pages << AlbumPage.new(site, base, dir, page + 1)
						break
					end
				end
				prev_file = files[idx-1] unless idx == 0
				next_file = files[idx+1] || nil

				album_page = "#{@dir}/#{album_name_from_page(page)}"
				do_image(filename, prev_file, next_file, album_page)
			end
		end

		def get_album_metadata
			site_metadata = @site.config['album_config'] || {}
			local_config = {}
			['yml', 'yaml'].each do |ext|
				config_file = File.join(@album_source, 'album_info.yml')
				if File.exists? config_file
					local_config = YAML.load_file(config_file)
				end
			end
			return DEFAULT_METADATA.merge(site_metadata).merge(local_config)
		end

		def album_name_from_page(page)
			return page == 0 ? 'index.html' : "index#{page + 1}.html"
		end

		def list_album_contents
			entries = Dir.entries(@album_source)
			entries.reject! { |x| x =~ /^\./ } # Filter out ., .., and dotfiles

			files = entries.reject { |x| File.directory? File.join(@album_source, x) } # Filter out directories
			directories = entries.select { |x| File.directory? File.join(@album_source, x) } # Filter out non-directories

			files.select! { |x| ['.png', '.jpg', '.gif'].include? File.extname(File.join(@album_source, x)) } # Filter out files that image-tag doesn't handle

			# Sort images
			def filename_sort(a, b, reverse)
				if reverse =~ /^desc/
					return b <=> a
				end
				return a <=> b
			end

			sort_on, sort_direction = @album_metadata['sort'].split
			files.sort! { |a, b| send("#{sort_on}_sort", a, b, sort_direction) }

			return files, directories
		end

		def do_image(filename, prev_file, next_file, album_page)
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
				rel_link, image_page_url(prev_file), image_page_url(next_file), album_page)
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
