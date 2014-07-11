# encoding utf-8

require_relative "../parser"
require "test/unit"

class ExtParserTest < Test::Unit::TestCase
  def test_parse_xtype
    text = "panel"   
    res = ExtParser.parse(text)
    assert_equal [ "panel", {} ], res
  end
  
  def test_parse_key_consist_id
    idtext = "panel#id"
    res_idtext = ExtParser.parse(idtext)
    assert_equal ["panel", { :id => "id"} ], res_idtext
  end

  def test_parse_key_consist_classname
    classtext = "panel.class"  
    res_classtext = ExtParser.parse(classtext)
    assert_equal ["panel", { :cls => "class"} ], res_classtext
  end

  def test_parse_key_consist_multiclass
    muticlass = "panel.class1-x_class2"
    res = ExtParser.parse(muticlass)
    assert_equal ["panel", { :cls => "class1-x class2"} ], res
  end

  def test_parse_key_consist_mix_class_and_id
    mixtext = "panel#id.class"
    res = ExtParser.parse(mixtext)
    assert_equal ["panel", { :id => "id", :cls => "class"} ], res
  end

  def test_parse_key_consist_dash
    text = "panel#form-wrapper"
    res = ExtParser.parse text 
    assert_equal ["panel", { :id => "form-wrapper" }], res
  end

  def test_parse_only_one_inline_config
    text = "panel@{ :title(test) }" 
    res = ExtParser.parse text
    assert_equal [ "panel", {title: "test"} ], res
  end

  def test_parse_only_multiword_value_inline_config
    text = "panel@{ :title(test test) }" 
    res = ExtParser.parse text
    assert_equal [ "panel", {title: "test test"} ], res
  end

  def test_parse_only_underscored_word_value_inline_config
    text = "panel@{ :title(test_test) }" 
    res = ExtParser.parse text
    assert_equal [ "panel", {title: "test_test"} ], res
  end
  
  def test_parse_only_multiple_underscored_word_value_inline_config
    text = "panel@{ :title(test_test) :value(id) :number(123) }" 
    res = ExtParser.parse text
    assert_equal [ "panel", {title: "test_test", value: "id", number: 123} ], res
  end

  def test_parse_inline_config_with_integer_value
    text = "panel@{ :title(test) :number(123) }" 
    res = ExtParser.parse text
    assert_equal [ "panel", {title: "test", :number => 123} ], res
  end

#  def test_parse_inline_with_thai_language
#    text = "panel@{ :title(test) :thai(กขค) }" 
#    res = ExtParser.parse text
#    assert_equal [ "panel", {title: "test", :thai => "กขค" } ], res
#  end
  
  def test_parse_more_inline_config_attributes
    text = "panel@{ :title(test) :text(aaa) }" 
    res = ExtParser.parse text
    assert_equal [ "panel", {title: "test", text: "aaa"} ], res
  end

  def test_parse_id_and_inline_config
    text = "panel#some-id@{ :config(config) }"
    res = ExtParser.parse text
    assert_equal [ "panel", {:id => "some-id", :config => "config"}], res
  end

  def test_parse_id_class_and_inline_config
    text = "panel#some-id.some-class@{ :config(config) }"
    res = ExtParser.parse text
    assert_equal [ "panel", {:id => "some-id", :cls => "some-class", :config => "config"}], res
  end

end
