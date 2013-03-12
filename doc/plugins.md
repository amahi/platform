# Writing a plugin for the Amahi Platform

An Amahi platform plugin is an RoR engine. For simplicity we call them plugins.

Plugins should be located in `plugins/` and can be generated with a generator

```bash
rails generate plugin FooBar --mountable
```

This will generate a plugin called FooBar in the plugin/ directory of the app. The name of the directory is the class name for the plugin and it should be CamelCased for best results.

## Requirements

Each plugin has to have a file called `config/amahi_plugin.yml` with details of the plugin, for example:

	# human readable name (no localization supported yet)
	# for example, it may be used as the text of the tab or the page title, etc.
	name: Foo Bar Tab
	# class to be mounted
	class: FooBar
	# kind of plugin (so far we only support 'tab' plugins)
	kind: tab
	# url where it will be mounted in the platform
	url: /tab/foobar

No two apps have may use the same class or url to be mounted.

## Recommendations

1) Contrary to most RoR engines, it is recommended that you do not namespace your plugins. By default all engines will have the following in foo_bar/lib/foo_bar/engine.rb

	module FooBar
		class Engine < ::Rails::Engine
			isolate_namespace FooBar
		end
	end

it's recommended that the line with isolate_namespace in it. Otherwise, each of helpers, controllers, all views and and all of asset images, stylesheets, and javascripts will have to be namespaced, i.e., each having foo_bar/ dir in them all over the place and also, most ruby code modularized like the above engine.rb.

2) For setup area tab plugins, it has to use this layout:

	layout 'setup_area'

