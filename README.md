Tenplate
========

Description goes here.

all the magic habens in bin/tenplate right now..

cd into your rails app and run TENPLATE_ROOT/bin/tenplate

Tenplate SASS Usage
===================

!IMPORTANT!

tenplate requires HAML/SASS 2.1 get it [here](http://github.com/nex3/haml/tree/master)

Remember, the main power of tenplate comes from using POSH html, so use the checklist at [Wiki](http://microformats.org/wiki/posh)

1 -  Make sure you have HAML > 2.3 installed

2 -  Copy the tenplate sass files to your project

`/home/you/your/project$ /path/to/tenplate/gem/bin/tenplate`

3 -  Add tenplate to your HAML template file

All you need to do is add tenplate.css to your application. Check the example application.html.haml below.

```ruby
!!! XML
!!! Strict
%html
  %head
    = stylesheet_link_tag 'tenplate'

  %body
    #grid
      = yield

    = javascript_include_tag :all
```
4 -  Set your tenplate variables.

All that really matters is `!line_height`, `!width` and `!page_padding`

public/stylesheets/tenplate.sass
```ruby
!font_color ||= #333
!base_font ||= "helvetica,arial,sans-serif"
!headline_font ||= "Candara,Georgia,serif"
!font_size ||= 1.4
!background_color ||= #FFF
!page_color ||= #EEE
!link_color ||= #C00
!line_height ||= 1.8
!width ||= 960
!page_padding ||= 2
!border_size ||= 0
!border_color ||= #333
!border_style ||= "none"
!border_radius ||= .2
!tab_highlight = !page_color
!tab_font = !link_color
```
5 - Give your pages a layout.

```ruby
.page = full page layout

.main = golden ratio main column
.rail = golden ratio side bar
```
6 -  Play around

Give all your div's rounded corners in ff and safari
Example:
```ruby
!border_radius ||= 1

div
  +rounded
```

COPYRIGHT
=========

Copyright (c) 2008 Dan Nawara. See [LICENSE](https://github.com/danboy/tenplate/blob/master/LICENSE) for details.