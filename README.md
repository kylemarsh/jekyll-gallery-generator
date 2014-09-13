# jekyll-gallery-generator

*JEKYLL GALLERY GENERATOR IS NOT COMPLETE AT THIS TIME*

**Effortless Image Albums for Jekyll**

Jekyll Gallery Generator is a plugin for the [Jekyll](http://jekyllrb.com) static site generator to streamline creating image albums and a gallery site. Gather images for an album into a directory and the gallery generator will create an album page for each directory.

## Installation

So far Jekyll Gallery Generator does not require any additional code beyond Ruby and Jekyll. In the future it will likely require [minimagick](https://github.com/minimagick/minimagick) and [miniexiftool](https://github.com/janfri/mini_exiftool)

Just put `gallery_generator.rb` in the `_plugins` directory and `album_index.html` in `_layouts` (or write your own `album_index.html`). Put directories full of images in a directory called `"albums"` and build your site!

## Usage

There are three parts to using the gallery generator:

- [Configuration](#configuration)
- [Directory Structure](#directory-structure)
- [Album Template](#album-template)

### Configuration

Your _config.py should specify `album_dir: some_directory`. If it does not, `album_dir` defaults to `"albums"`.

### Directory Structure

If your `album_dir` is `"albums"` then this structure:


```
.
|-albums
| |-Some Event
| | |-IMG_123.jpg
| | |-IMG_124.jpg
| |-Family
|   |-Morgan.jpg
|   |-Terry_and_Leslie.jpg
|   |-Mom_and_Dad_Anniversary.jpg
```

will build a gallery with two albums: "Some Event" and "Family". `http://mysite.com/Some Event/index.html` will show two images: `IMG_123.jpg` and `IMG_124.jpg`. Similarly, `http://mysite.com/Family/index.html` will show three images: `Morgan.jpg`, `Terri_and_Leslie.jpg`, and `Mom_and_Dad_Anniversary.jpg`. 

### Album Template

Your album template must be named `album_index.html` and should also loop over `page.images` to actually place all the images on the page. For example:

```
---
layout: default
page_type: album
---
<h2>{{ page.title }}</h2>
{% for image in page.images %}
    <span class='image'><img src="/{{ image }}"></span>
{% endfor %}
```

You may wish to use other plugins, such as Rob Wierzbowski's [jekyll-image-tag](https://github.com/robwierzbowski/jekyll-image-tag) for your template.

If you want to list all available albums, make sure that your album template includes `page_type: albums` and then put this in your site's homepage (or wherever you want the album list):

```Liquid
<ul>
{% for page in site.pages %}
    {% if page.page_type == 'album' %}
        <li><a href="{{ page.url }}">{{ page.title }}</a></li>
    {% endif %}
{% endfor %}
</ul>
```
