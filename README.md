# jekyll-gallery-generator

**Effortless Image Albums for Jekyll**

Jekyll Gallery Generator is a plugin for the [Jekyll](http://jekyllrb.com)
static site generator to streamline creating image albums and a gallery site.
Gather images for an album into a directory and the gallery generator will
create an album page for each directory.

## Installation

So far Jekyll Gallery Generator requires Ruby, Jekyll,
[minimagick](https://github.com/minimagick/minimagick),
[jekyll-image-tag](https://github.com/robwierzbowski/jekyll-image-tag), and
[ImageMagick](http://www.imagemagick.org/script/index.php).

In an upcoming release it will likely require
[miniexiftool](https://github.com/janfri/mini_exiftool) as well.

Once you have the dependencies installed Just put `gallery_generator.rb` in the
`_plugins` directory and `album_index.html` `image_page.html` in `_layouts` (or
write your own templates). Put `album.css` in your `css` directory and import
it into your main CSS file (or, again, write your own CSS).

You'll need to include the following YAML snippet in your `_config.yml` for
jekyll-image-tag to work, but don't actually *need* any further changes to
`_config.yml`:

```YAML
image:
    output: generated
    presets:
        album_thumb:
            width: 200
            attr:
                class: album-image
        medium:
            width: 1200
            attr:
                class: image
```

Finally, put directories full of images in a directory called `"albums"` and
build your site!

## Usage

There are three parts to using the gallery generator:

- [Configuration](#configuration)
- [Directory Structure](#directory-structure)
- [Templates](#templates)

### Configuration

Your _config.py should specify `album_dir: some_directory`. If it does not,
`album_dir` defaults to `"albums"`.

### Directory Structure

If your `album_dir` is `"albums"` then this structure:


```
.
|-albums
| |-Some Event
| | |-IMG_123.jpg
| | |-IMG_124.jpg
| |-Family
|   |-album_info.yml
|   |-Mom_and_Dad_Anniversary.jpg
|   |-Morgan.jpg
|   |-Terry_and_Leslie.jpg
```

will build a gallery with two albums: "Some Event" and "Family".
`http://mysite.com/Some Event/index.html` will show two images: `IMG_123.jpg`
and `IMG_124.jpg`. Similarly, `http://mysite.com/Family/index.html` will show
three images: `Morgan.jpg`, `Terri_and_Leslie.jpg`, and
`Mom_and_Dad_Anniversary.jpg`. The Family album has metadata about the album
that it reads from album_info.yml.

The data in album_info.yml is structured as a hash -- just like _config.yml --
and affects the behavior of your album. Possible metadata keys are:

- description: Text describing the album. Becomes available as
`page.description` in the album_index.html template.
- sort: string describing how to sort the images in the album. First word is
the field to sort on, second is either 'asc' or 'desc'. Valid sort
fields are:
  - filename: sorts on the image's filename.
- hidden: boolean (true or false) indicating whether or not an album should be
linked to from the gallery or parent albums. Hidden albums still exist in the
site.pages list and are publicly accessible to anyone with the url, but don't
get explicit links placed on parent albums' pages.

```YAML
description: Lorem ipsum dolor hipster nonsense
sort: filename desc
hidden: false
```

### Templates

Your album template must be named `album_index.html` and should loop over
`page.images` to actually place all the images on the page. `page.images` is an
array of hashes; each has has two keys: `rel_link` and `source`.  For example:

```
---
layout: default
page_type: album
---
<h2>{{ page.title }}</h2>
{% for image in page.images %}
    <a href="{{ image.rel_link }}">{% image album_thumb {{ image.src }} %}</a>
{% endfor %}
```

Your image page template must be named `image_page.html`. The `page` variable
contains the following data:

- prev_url: The relative path for the previous image in the gallery
- next_url: The relative path for the next image in the gallery
- img_src: The relative path to the image file for this page
- album_url: The path to the album's index page.

If you want to list all available albums, make sure that your album template
includes `page_type: albums` and then put this in your site's homepage (or
wherever you want the album list):

```Liquid
<ul>
{% for page in site.pages %}
    {% if page.page_type == 'album' %}
		{% if page.hidden %}{% continue %}{% endif %}
        <li><a href="{{ page.url }}">{{ page.title }}</a></li>
    {% endif %}
{% endfor %}
</ul>
```
