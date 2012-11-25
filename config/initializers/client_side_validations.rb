
# Uncomment the following block if you want each input field to have the validation messages attached.
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  unless html_tag =~ /^<label/
    %{<span class="field_with_errors">#{html_tag}<label for="#{instance.send(:tag_id)}" class="messages">#{instance.error_message.first}</label></span>}.html_safe
  else
    %{<span class="field_with_errors">#{html_tag}</span>}.html_safe
  end
end

