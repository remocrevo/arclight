# frozen_string_literal: true

##
# Generic Helpers used in Arclight
module ArclightHelper
  ##
  # @param [SolrDocument]
  def parents_to_links(document)
    safe_join(Arclight::Parents.from_solr_document(document).as_parents.map do |parent|
      link_to parent.label, solr_document_path(parent.global_id)
    end, t('arclight.breadcrumb_separator'))
  end

  ##
  # Classes used for customized show page in arclight
  def custom_show_content_classes
    'col-md-12 show-document'
  end

  ##
  # Defines custom helpers used for creating unique metadata blocks to render
  Arclight::Engine.config.catalog_controller_field_accessors.each do |config_field|
    ##
    # Mimics what document_show_fields from Blacklight does
    # https://github.com/projectblacklight/blacklight/blob/dee8d794125306ec8d4ab834a6a45bcf9671c791/app/helpers/blacklight/configuration_helper_behavior.rb#L35-L38
    define_method(:"document_#{config_field}s") do |_document = nil|
      blacklight_config.send(:"#{config_field}s")
    end

    ##
    # Mimics what render_document_show_field_label from Blacklight does
    # https://github.com/projectblacklight/blacklight/blob/dee8d794125306ec8d4ab834a6a45bcf9671c791/app/helpers/blacklight/blacklight_helper_behavior.rb#L136-L156
    define_method(:"render_document_#{config_field}_label") do |*args|
      options = args.extract_options!
      document = args.first

      field = options[:field]

      t(:'blacklight.search.show.label', label: send(:"document_#{config_field}_label", document, field))
    end

    ##
    # Mimics what document_show_field_label from Blacklight does
    # https://github.com/projectblacklight/blacklight/blob/dee8d794125306ec8d4ab834a6a45bcf9671c791/app/helpers/blacklight/configuration_helper_behavior.rb#L67-L74
    define_method(:"document_#{config_field}_label") do |document, field|
      field_config = send(:"document_#{config_field}s", document)[field]
      field_config ||= Blacklight::Configuration::NullField.new(key: field)

      field_config.display_label('show')
    end

    ##
    # Mimics what should_render_show_field? from Blacklight does
    # https://github.com/projectblacklight/blacklight/blob/dee8d794125306ec8d4ab834a6a45bcf9671c791/app/helpers/blacklight/blacklight_helper_behavior.rb#L84-L92
    define_method(:"should_render_#{config_field}?") do |document, field_config|
      should_render_field?(field_config, document) && document_has_value?(document, field_config)
    end
  end

  ##
  # Calls the method for a configured field
  def generic_document_fields(config_field)
    send(:"document_#{config_field}s")
  end

  ##
  # Calls the method for a configured field
  def generic_should_render_field?(config_field, document, field)
    send(:"should_render_#{config_field}?", document, field)
  end

  ##
  # Calls the method for a configured field
  def generic_render_document_field_label(config_field, document, field: field_name)
    send(:"render_document_#{config_field}_label", document, field: field)
  end
end
