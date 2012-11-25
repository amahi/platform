module SharesHelper

  def confirm_share_destroy_message(comment)
    [t('are_you_sure_share', :share => comment),
     t('this_shares_files_deleted'), "", t('there_is_no_undo'), ""].join("\n")
  end

  def tags_to_str(tags)
    tags.blank? ? '(add tags)' : tags
  end


  def warning_greyhole(path)
    title, wiki_path = warning_greyhole_on_root(path)
    if title and wiki_path
      danger_image = theme_image_tag('danger.png', :class => 'theme-image')
      link_to_wiki = link_to(theme_image_tag('more.png', :title => title, :class => 'theme-image'), "http://wiki.amahi.org/index.php#{wiki_path}")
      "<span style='float:right;'>#{danger_image} &raquo; #{link_to_wiki}</span>".html_safe
    else
      ''
    end
  end

    def warning_greyhole_on_root(path)
      return ['Greyhole not on root', '/Greyhole_not_on_root' ] if path == '/'
      return ['Greyhole not on /media', '/Greyhole#.2Fmedia' ] if path =~ /^\/media/
    end

  def space_color(total_space, free_space)
    space_color_class = "cool"
    space_color_class = "warm" if free_space < (total_space * 0.20)
    space_color_class = "hot" if free_space < (total_space * 0.10)
    space_color_class
  end

  def disk_pooling_area?
    advanced? && DiskPoolPartition.count > 0 && Greyhole.enabled?
  end

end
