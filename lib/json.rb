# Ordinarily, we would just "require 'json'", and use default library
# but by strict definition of requirements, we may not be allowed.

# The following will add simple JSON formatting to our classes

class JSON
  
  INDENT_LEVEL = 4

  def self.print obj
    obj.to_json
  end
end

# And now monkey-patch common classes so that to_json is available


class String
  def to_json( indentation = 0 )
    dump
  end
end

class Symbol
  def to_json( indentation = 0 )
    to_s.dump
  end
end

class Hash
  def to_json( indentation = 0 )
    whitespace_outer = " " * indentation
    whitespace_inner = " " * (indentation + JSON::INDENT_LEVEL)
    if size == 0 then
      "{}"
    else
      "{\n#{whitespace_inner}" + 
      collect{|key, value| "#{key.to_json}: #{value.to_json( indentation + JSON::INDENT_LEVEL )}" }.join(",\n#{whitespace_inner}") + 
      "\n#{whitespace_outer}}"
    end
  end
end

class Array
  def to_json( indentation = 0 )
    whitespace_outer = " " * indentation
    whitespace_inner = " " * (indentation + JSON::INDENT_LEVEL)
    if size == 0 then
      "[]"
    else
      "[\n#{whitespace_inner}" + 
      collect{|term| term.to_json( indentation + JSON::INDENT_LEVEL ) }.join(",\n#{whitespace_inner}") + 
      "\n#{whitespace_outer}]"
    end
  end
end

class Integer
  def to_json( indentation = 0 )
    to_s
  end
end

class Float
  def to_json( indentation = 0 )
    to_s
  end
end

class FalseClass
  def to_json( indentation = 0 )
    "false"
  end
end

class TrueClass
  def to_json( indentation = 0 )
    "true"
  end
end

class NilClass
  def to_json( indentation = 0 )
    "null"
  end
end

class Object
  def to_json( indentation = 0 )
    "\"Object::#{self.class.to_s}\""
  end
end

#o = {
#  :one => 'one_"_two',
#  :three => "four",
#  :five => [ 1, 2, 3, 4, 5 ],
#  :six => {
#    :seven => [ 1, 2, 3, 4, { :five => :eight}, 6, 7],
#    :nine => :ten,
#    :eleven => false,
#    :twelve => true,
#    :thirteen => nil
#  }
#}

#puts (JSON.print o)
