module PageHeaderHelper
  def gradient_header(&block)
    <<~HTML.html_safe
      <header class="page-header bg-gradient-primary-to-secondary">
        #{capture(&block)}
        <div class="svg-border-rounded text-white">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 144.54 17.34" preserveAspectRatio="none" fill="currentColor">
            <path d="M144.54,17.34H0V0H144.54ZM0,0S32.36,17.34,72.27,17.34,144.54,0,144.54,0"></path>
          </svg>
        </div>
      </header>
    HTML
  end

  def waved_section(start_color = '#fff', end_color = '#eff3f9', &block)
    <<~HTML.html_safe
      <div style="background-image: linear-gradient(#{start_color} 0%, #{end_color} 100%); position: relative; padding-bottom: 80px;">
        #{capture(&block)}

        <div class="svg-border-rounded" style="color: #{start_color};">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 144.54 17.34" preserveAspectRatio="none" fill="currentColor">
            <path d="M144.54,17.34H0V0H144.54ZM0,0S32.36,17.34,72.27,17.34,144.54,0,144.54,0"></path>
          </svg>
        </div>
      </div>
    HTML
  end

  def offset_anchor(id)
    <<~HTML.html_safe
      <div style="position: relative;">
        <div id="#{id}" style="position: absolute; margin-top: -100px;"></div>
      </div>
    HTML
  end
end
