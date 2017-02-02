module ProfilesHelper

  def backup_files_breadcrumb
    html = "<ol class='breadcrumb'>"
    html << content_tag(:li, link_to("Profiles", profiles_path))

    if @parent.present?
      html << content_tag(:li, link_to(@profile.name,"/profiles/#{@profile.id}/browse/#{params[:version]}"))
    else
      html << content_tag(:li, @profile.name, class: "active")
    end

    all_parents = @parent.try(:self_and_parents) || []
    all_parents.reverse.each do |parent|
      if parent == @parent
        html << content_tag(:li, parent.filename, class: "active")
      else
        html << content_tag(:li, link_to(parent.filename, "/profiles/#{@profile.id}/browse/#{params[:version]}?parent_id=#{parent.id}"))
      end
    end

    options = options_from_collection_for_select(@backup_version, 'version', 'version', params[:version])
    html << "<span class='pull-right'>Backup version : #{select_tag "time", options, onChange: "location.href = '/profiles/#{@profile.id}/browse/' + $(this).val()" }</span>"

    html << "</ol>"

    return html.html_safe
  end
end
