module BackupFilesHelper

  def revision_history_breadcrumb
    html = "<ol class='breadcrumb'>"
    html << content_tag(:li, link_to("Profiles", profiles_path))
    html << content_tag(:li, link_to(@profile.name,"/profiles/#{@profile.id}/browse/#{@backup_file.version}"))

    all_parents = @backup_file.parent.try(:self_and_parents) || []
    all_parents.reverse.each do |parent|
      html << content_tag(:li, link_to(parent.filename, "/profiles/#{@profile.id}/browse/#{@backup_file.version}?parent_id=#{@backup_file.parent_id}"))
    end

    html << content_tag(:li, @backup_file.filename, class: "active")

    html << "</ol>"

    return html.html_safe
  end

end
