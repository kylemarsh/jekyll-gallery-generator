# jekyll-gallery-generator

*JEKYLL GALLERY GENERATOR IS NOT COMPLETE AT THIS TIME*

**Effortless Image Galleries for Jekyll**

Jekyll Gallery Generator is a plugin for the [Jekyll](http://jekyllrb.com) static site generator to streamline creating image galleries. Gather images for a gallery into a directory and the gallery generator will create a gallery page for each directory.

## Installation

So far Jekyll Gallery Generator does not require any additional code beyond Ruby and Jekyll. In the future it will likely require [minimagick](https://github.com/minimagick/minimagick) and [miniexiftool](https://github.com/janfri/mini_exiftool)

Just put `gallery_generator.rb` in the `_plugins` directory and `gallery_index.html` in `_layouts` (or write your own `gallery_index.html`). Put directories full of images in a directory called `"galleries"` and build your site!

## Usage

There are three parts to using the gallery generator:

- [Configuration](#configuration)
- [Directory Structure](#directory-structure)
- [Gallery Template](#gallery-template)

### Configuration

Your _config.py should specify `gallery_dir: some_directory`. If it does not, `gallery_dir` defaults to `"galleries"`.

### Directory Structure

If your `gallery_dir` is `"galleries"` then this structure:


```
.
|-galleries
| |-Some Event
| | |-IMG_123.jpg
| | |-IMG_124.jpg
| |-Family
|   |-Morgan.jpg
|   |-Terry_and_Leslie.jpg
|   |-Mom_and_Dad_Anniversary.jpg
```

will build a site with two galleries: "Some Event" and "Family". `http://mysite.com/Some Event/index.html` will show two images: `IMG_123.jpg` and `IMG_124.jpg`. Similarly, `http://mysite.com/Family/index.html` will show three images: `Morgan.jpg`, `Terri_and_Leslie.jpg`, and `Mom_and_Dad_Anniversary.jpg`. 

### Gallery Template

Your gallery template must be named `gallery_index.html` and should also loop over `page.images` to actually place all the images on the page. For example:

```
---
layout: default
page_type: gallery
---
<h2>{{ page.title }}</h2>
{% for image in page.images %}
    <span class='image'><img src="/{{ image }}"></span>
{% endfor %}
```

You may wish to use other plugins, such as Rob Wierzbowski's [jekyll-image-tag](https://github.com/robwierzbowski/jekyll-image-tag) for your template.

If you want to list all available galleries, make sure that your gallery template includes `page_type: gallery` and then put this in your site's homepage (or wherever you want the gallery list):

```Liquid
<ul>
{% for page in site.pages %}
    {% if page.page_type == 'gallery' %}
        <li><a href="{{ page.url }}">{{ page.title }}</a></li>
    {% endif %}
{% endfor %}
</ul>
```
