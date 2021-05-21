module Button
    class Component < ::ViewComponent::Base
      attr_reader :type
      attr_reader :size
      attr_reader :icon
      attr_reader :color
      attr_reader :role
      attr_reader :transition
      attr_reader :show_spinner
  
      def initialize(type,
                     size: :normal,
                     icon: { name: nil, size: nil, color: nil },
                     color: :default,
                     link: nil,
                     html_options: {},
                     role: :button,
                     slider: nil,
                     transition: nil,
                     spinner: nil,
                     hotkey: nil)
        @type = type
        @size = size
        if icon && icon.is_a?(String)
          @icon = { name: icon, color: nil, size: nil }
        else
          @icon = { name: nil, color: nil, size: nil }.merge(icon)
        end
  
        @color = color
        if link
          if link.is_a? String
            @link = { url: link, options: {}, as_button: false }
          else
            @link = { options: {}, as_button: false }.merge(link)
          end
        else
          @link = nil
        end
  
        @html_options = html_options
        @hotkey = hotkey
        if slider
          if slider.is_a? String
            @slider = { slider: slider }
          else
            @slider = slider
          end
        else
          @slider = nil
        end
  
        if spinner
          spinner = {} if spinner.is_a? TrueClass
          @spinner = { class: "animate-spin #{get_spinner_icon_size.join(' ')} hidden", image: 'full-spin', color: 'text-blue-500' }.merge(spinner)
        else
          @spinner = nil
        end
  
        @role = role
        @transition = transition.nil? ? 'transition duration-300 ease-in-out' : transition
        @is_button = @link.present? ? @link[:as_button] : true
      end
  
      def get_options
        html_options = @html_options || {}
        data_attrs = html_options[:data] || {}
        cl_names = html_options[:class] || ''
        class_attrs = cl_names.split(' ')
        c_names = data_attrs[:controller] || ''
        controllers = c_names.split(' ')
        a_names = data_attrs[:action] || ''
        actions = a_names.split(' ')
  
        if @hotkey
          data_attrs = data_attrs.merge(hotkey_attributes)
          controllers << "hotkey"
          controllers << "popup"
        end
  
        if @slider
          data_attrs = data_attrs.merge(slidein_attributes)
          controllers << "button--component"
          actions << "button--component#openSlider"
        end
  
        if @spinner
          controllers << "button--component"
          actions << "button--component#clicked"
        end
  
        data_attrs[:controller] = controllers.uniq.join(' ') unless controllers.empty?
        data_attrs[:action] = actions.uniq.join(' ') unless actions.empty?
  
        required_classes = get_size + get_color + get_base_style
  
        final_classes = (required_classes + class_attrs).flatten.uniq.compact
  
        if data_attrs.empty?
          final = { class: final_classes.join(' ') }
        else
          final = { class: final_classes.join(' '), data: data_attrs }
        end
  
        final = final.merge(html_options.except(:class, :data))
        final.merge!({ type: @role }) if @is_button
  
        final
      end
  
      def link_options
        @link[:options].merge(get_options)
      end
  
      def get_icon_size
        icon_size = @icon[:size] ? @icon[:size] : @size
  
        case icon_size
        when :xs
          %w[-ml-0.5 mr-2 h-3 w-3]
        when :sm
          %w[-ml-1 mr-2 h-4 w-4]
        when :normal
          %w[-ml-1 mr-3 h-4 w-4]
        when :lg
          %w[-ml-1 mr-3 h-5 w-5]
        when :xl
          %w[-ml-1 mr-3 h-5 w-5]
        else
          raise ArgumentError, 'invalid size'
        end
      end
  
      def get_spinner_icon_size
        icon_size = @icon[:size] ? @icon[:size] : @size
  
        case icon_size
        when :xs
          %w[-ml-0.5 mr-2 h-3 w-3]
        when :sm
          %w[-ml-1 mr-2 h-4 w-4]
        when :normal
          %w[-ml-1 mr-3 h-4 w-4]
        when :lg
          %w[-ml-1 mr-3 h-5 w-5]
        when :xl
          %w[-ml-1 mr-3 h-5 w-5]
        else
          raise ArgumentError, 'invalid size'
        end
      end
  
      def get_icon_color
        return ['fill-current', @icon[:color]] if @icon[:color]
  
        case @type
        when :primary
          %W[text-white dark:text-#{get_default_color}-200 dark:hover:text-#{get_default_color}-800 fill-current]
        when :secondary
          %W[text-#{get_default_color}-500 dark:text-#{get_default_color}-400 fill-current]
        when :tertiary
          %W[text-#{get_default_color}-500 dark:text-#{get_default_color}-400 fill-current]
        end
      end
  
      def get_icon_class
        get_icon_size + get_icon_color
      end
  
      def get_icon
        content_tag :span do
          concat(helpers.embedded_svg(@spinner[:image], class: @spinner[:class] + ' ' + @spinner[:color], data: { 'button--component-target': 'spinner'})) if @spinner
          concat helpers.embedded_svg(@icon[:name], class: get_icon_class.join(' '), data: { 'button--component-target': 'icon'})
        end
      end
  
      def get_default_color
        return @color unless @color == :default
  
        case type
        when :primary
          "green"
        when :secondary
          "blue"
        when :tertiary
          "gray"
        else
          raise ArgumentError, "invalid type"
        end
      end
  
      def get_size
        case size
        when :xs
          return %w[text-xs font-medium px-2 py-1 rounded]
        when :sm
          return %w[text-sm leading-4 font-medium px-3 py-2 rounded-md]
        when :normal
          return %w[text-sm font-medium px-4 py-2 rounded-md]
        when :lg
          return %w[text-base font-medium px-4 py-2 rounded-md]
        when :xl
          return %w[text-base font-medium px-6 py-3 rounded-md]
  
        else
          raise ArgumentError, 'invalid size'
        end
      end
  
      def get_color
        case @type
        when :primary
          %W[dark:bg-#{get_default_color}-500 dark:border-#{get_default_color}-200 dark:hover:bg-#{get_default_color}-200 dark:hover:text-#{get_default_color}-700 border-transparent text-white bg-#{get_default_color}-600 hover:bg-#{get_default_color}-700 focus:ring-#{get_default_color}-500]
        when :secondary
          %W[dark:bg-#{get_default_color}-700 border-transparent text-#{get_default_color}-700 bg-#{get_default_color}-100 hover:bg-#{get_default_color}-200 focus:ring-#{get_default_color}-500]
        when :tertiary
          %W[dark:bg-#{get_default_color}-800 dark:border-#{get_default_color}-400 border-#{get_default_color}-300 dark:text-#{get_default_color}-300 text-#{get_default_color}-700 bg-white dark:hover:bg-#{get_default_color}-500 hover:bg-#{get_default_color}-50 focus:ring-#{get_default_color}-500]
        end
      end
  
      def get_base_style
        base = %w[inline-flex justify-center items-center border shadow-sm]
        base << @transition.split(' ')
        return base.flatten.uniq.compact
      end
  
      def hotkey_attributes
        { hotkey: @hotkey[:keys], "popup-markup-value": helpers.hotkey(@hotkey[:text], @hotkey[:keys]) }
      end
  
      def slidein_attributes
        r = { 'button--component-slider-value': "#{@slider[:slider]}_slider" }
        r.merge!({ 'button--component-slider-source-value': @slider[:source] }) if @slider.has_key?(:source)
  
        return r
      end
  
    end
  end
  