# Amahi Home Server  encoding: utf-8
# Copyright (C) 2007-2013 Amahi
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License v3
# (29 June 2007), as published in the COPYING file.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# file COPYING for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Amahi
# team at http://www.amahi.org/ under "Contact Us."

require 'uri'
require 'net/http'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	# refactored

	def current_user_is_admin?
		current_user && current_user.admin?
	end

	def rtl?
		@locale_direction == 'rtl'
	end

	def theme
		@theme
	end

	def page_title
		@page_title
	end

	def amahi_plugins
		AmahiHDA::Application.config.amahi_plugins
	end

	def full_page_title
		page_title ? "Amahi Home Server &rsaquo; #{page_title}".html_safe : "Amahi Home Server"
	end

	def simple_remote_checkbox options
		parsed_options = {}
		parsed_options[:checked] = 'checked' if options[:checked]
		parsed_options[:disabled] = 'disabled' if options[:disabled]

		options[:id] = SecureRandom.hex(2) unless options[:id]
	    data_options = {:url => options[:url]}
	    data_options[:confirm] = options[:confirm] if options[:confirm]

		content_tag('span', :id => options[:id]) do
			html = ''
			html << tag('input', {:class => options[:css_class], :id => "checkbox_#{options[:id]}", :type => 'checkbox', :data => data_options}.merge(parsed_options))
			html << "&nbsp;&nbsp;"
			html << (block_given? ? yield : options[:label].to_s)
			html << "&nbsp;"
			html << content_tag("span", '', class: "spinner theme-image", style: "display: none")
			html.html_safe
		end
	end

	def simple_remote_radio options
		parsed_options = {}
		parsed_options[:checked] = 'checked' if options[:checked]
		parsed_options[:disabled] = 'disabled' if options[:disabled]

		options[:id] = SecureRandom.hex(2) unless options[:id]
		options[:name] = SecureRandom.hex(2) unless options[:name]
	    data_options = {:url => options[:url]}
	    data_options[:confirm] = options[:confirm] if options[:confirm]

		content_tag('p', :id => options[:id]) do
			html = ''
			html << tag('input', {:class => options[:css_class], :id => "radio_#{options[:id]}", :name => options[:name], :value => options[:value], :type => 'radio', :data => data_options}.merge(parsed_options))
			html << "&nbsp;&nbsp;"
			html << (block_given? ? yield : options[:label].to_s)
			html << "&nbsp;"
			html << content_tag("span", '', class: "spinner theme-image", style: "display: none")
			html.html_safe
		end
	end

	def simple_remote_text options
		parsed_options = {}
		parsed_options[:disabled] = 'disabled' if options[:disabled]
		content_tag('div', :id => "div_form_#{options[:id]}") do
			html = ''
			html << content_tag('form',{:action=>options[:url], :method => options[:method],:data => {:remote=>options[:remote]},:id=>options[:form_id], :class=>options[:form_css_class]}) do
				input_html =''
				input_html << content_tag('div',:class=>"control-group form-group") do
					input_html1 = ''
					input_html1 = content_tag('div',:class=>"controls") do
						input_html2 = ''
						input_html2 << tag('input', {:class => options[:input_css_class], :id =>options[:input_id] , :name => options[:name], :value => options[:value], :type => 'text'}.merge(parsed_options))
						input_html2.html_safe
					end
					input_html1.html_safe
				end
				input_html << content_tag('div',:class=>"control-group form-group") do
					input_html1 = ''
					input_html1 = content_tag('div',:class=>"controls") do
						input_html2 = ''
						input_html2 << content_tag("button",options[:label],:class=> "btnn btn btn-info btn-create btn-sm left-margin-10",:type => "submit",:id=> options[:button_id] )
						input_html2 << content_tag("a",'Cancel',:class=>options[:cancel_class],:data=>{:id=>options[:id]})
						input_html2.html_safe
					end
					input_html1.html_safe
				end
				input_html << content_tag("span", '', class: "spinner theme-image", style: "display: none")
				input_html.html_safe
			end
			html.html_safe
		end
	end

	def simple_remote_select options
		parsed_options = {}
		parsed_options[:disabled] = 'disabled' if options[:disabled]

		options[:id] = SecureRandom.hex(2) unless options[:id]
		options[:name] = SecureRandom.hex(2) unless options[:name]

		content_tag('span', :id => options[:id]) do
			html = ''
			html << (block_given? ? yield : options[:label].to_s)
			html << select_tag("select", options_from_collection_for_select(options[:collection], "first", "last", options[:selected].to_s), :class=>'form-control', :name => options[:name], :data => {:url => options[:url]}.merge(parsed_options))
			html << content_tag("span", '', class: "spinner theme-image", style: "display: none") unless options[:no_spinner]
			html.html_safe
		end
	end


	def spinner(css_class = '')
		content_tag('span', '', class: "spinner #{css_class}", style: "display: none")
	end

	def formatted_date(date)
		date = date.localtime
		"#{date.to_formatted_s(:short)} (#{time_ago_in_words(date)})"
	rescue
		'-'
	end

	def path2uri(name)
		name = URI.escape name
		is_a_mac? ? "smb://hda/#{name}" : "file://///hda/#{name}"
	end

	def path2location(name)
		fwd = '\\'
		is_a_mac? ? '&raquo; '.html_safe + h(name.gsub(/\//, ' ▸ ')) : h('\\\\hda\\' + name.gsub(/\//, fwd))
	end

	# to verify ################################################

	def is_a_mac?
		(request.env["HTTP_USER_AGENT"] =~ /Macintosh/) ? true : false
	end

	def is_firefox?
		(request.env["HTTP_USER_AGENT"] =~ /Firefox/) ? true : false
	end

	def editable_content(options)
		options[:content] = { :element => 'span' }.merge(options[:content])
		options[:url] = {}.merge(options[:url])
		options[:ajax] = { :okText => "'Save'", :cancelText => "'Cancel'"}.merge(options[:ajax] || {})
		script = Array.new
		script << "new Ajax.InPlaceEditor("
		script << "  '#{options[:content][:options][:id]}',"
		script << "  '#{url_for(options[:url])}',"
		script << "  {"
		script << options[:ajax].map{ |key, value| "#{key.to_s}: #{value}" }.join(", ")
		script << "  }"
		script << ")"

		content_tag(
		options[:content][:element],
		options[:content][:text],
		options[:content][:options]
		) + javascript_tag( script.join("\n") )
	end

	# FIXME-cpg: somehow generate <input ... /> instead of
	# <input>...</input>
	def checkbox_to_function(checked = true, *args, &block)
		html_options = args.extract_options!
		function = args[0] || ''

		html_options.symbolize_keys!
		function = update_page(&block) if block_given?
		tag("input",
		html_options.merge({
			:type => "checkbox",
			:checked => ("checked" if checked),
			# FIXME-cpg: href should not be needed? :href => html_options[:href] || "#",
			:onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + "#{function}; return false;"
		})
		)
	end

	def checkbox_to_remote( checked = true, options = {}, html_options = nil)
		checkbox_to_function(checked, remote_function(options), html_options || options.delete(:html))
	end



	def fw_rule_type(t)
		case t
		when 'port_filter'
			'Port Filter'
		when 'url_filter'
			'URL Filter'
		when 'mac_filter'
			'MAC Filter'
		when 'ip_filter'
			'IP Filter'
		when 'port_forward'
			'Port Forwarding'
		else
			raise "type #{rule.kind} unknown"
		end
	end

	def fw_rule_details(rule)
		case rule.kind
		when 'port_filter'
			"Ports: #{rule.range}, Protocol: #{fw_prot(rule.protocol)}"
		when 'ip_filter'
			"IP: #{@net}.#{rule.ip}, Protocol: #{fw_prot(rule.protocol)}"
		when 'mac_filter'
			"MAC: #{rule.mac}"
		when 'url_filter'
			"URL: #{rule.url}"
		when 'port_forward'
			"IP: #{@net}.#{rule.ip}, Ports: #{rule.range}"
		else
			raise "details for #{rule.kind} unknown"
		end
	end

	def fw_rule_state(rule)
		Setting.get(rule.kind) == '1'
	end

	def fw_prot(p)
		p == 'both' ? 'TCP &amp; UDP' : p.upcase
	end

	def msg_bad(s = "")
		theme_image_tag("stop") + " " + s
	end

	def msg_good(s = "")
		theme_image_tag("ok") + " " + s
	end

	def msg_warn(s = "")
		theme_image_tag("warning") + " " + s
	end

	def delete_icon(title = "")
		theme_image_tag("delete.png", :title => title)
	end

	def inline_event
		page << "new Effect.Event({queue: 'end', afterFinish:function(){"
		yield
		page << "}})"
	end



	def spinner_show id
		"Element.show('spinner-#{id}');"
	end

	def spinner_hide id
		"Element.hide('spinner-#{id}');"
	end
end
