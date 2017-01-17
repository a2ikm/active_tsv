# frozen_string_literal: true

module ActiveTsv
  # @example
  #   class User < ActiveTsv::Base
  #     self.table_path = "table/product_masters.tsv"
  #   end
  class Base
    SEPARATER = "\t"
    DEFAULT_PRIMARY_KEY = "id"

    class << self
      include Querying
      include Reflection

      attr_reader :table_path

      def table_path=(path)
        reload(path)
      end

      def reload(path)
        if @column_names
          column_names.each do |k|
            remove_method(k)
            remove_method("#{k}=")
          end
        end

        @column_names = nil
        @custom_column_name = false
        @table_path = path
        column_names.each do |k|
          define_method(k) { @attrs[k] }
          define_method("#{k}=") { |v| @attrs[k] = v }
        end
      end

      def all
        Relation.new(self)
      end

      def scope(name, proc)
        define_singleton_method(name, &proc)
      end

      def open(&block)
        CSV.open(table_path, "r:#{encoding}:UTF-8", col_sep: self::SEPARATER, &block)
      end

      def column_names
        @column_names ||= begin
          @custom_column_name = false
          open { |csv| csv.gets }
        end
      end

      def column_names=(names)
        @custom_column_name = true
        column_names = names.map(&:to_s)
        column_names.each do |k|
          define_method(k) { @attrs[k] }
          define_method("#{k}=") { |v| @attrs[k] = v }
        end
        @column_names = column_names
      end

      def custom_column_name?
        @custom_column_name
      end

      def primary_key
        @primary_key ||= DEFAULT_PRIMARY_KEY
      end

      attr_writer :primary_key

      def encoding
        @encoding ||= Encoding::UTF_8
      end

      def encoding=(enc)
        case enc
        when String
          @encoding = Encoding.find(enc)
        when Encoding
          @encoding = enc
        else
          raise ArgumentError, "#{enc.class} dose not support"
        end
      end
    end

    def initialize(attrs = {})
      case attrs
      when Hash
        h = {}
        self.class.column_names.each do |name|
          h[name] = nil
        end
        attrs.each do |name, v|
          unless respond_to?("#{name}=")
            raise UnknownAttributeError, "unknown attribute '#{name}' for #{self.class}."
          end
          h[name.to_s] = v
        end
        @attrs = h
      when Array
        @attrs = self.class.column_names.zip(attrs).to_h
      else
        raise ArgumentError, "#{attrs.class} is not supported value"
      end
    end

    def inspect
      "#<#{self.class} #{@attrs.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}>"
    end

    def [](key)
      @attrs[key.to_s]
    end

    def []=(key, value)
      @attrs[key.to_s] = value
    end

    def attributes
      @attrs.dup
    end

    def ==(other)
      super || other.instance_of?(self.class) && @attrs == other.attributes
    end
    alias eql? ==
  end
end
