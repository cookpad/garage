require 'spec_helper'

describe Garage::NestedFieldQuery::Selector do
  def build_parsed(fields)
    Garage::NestedFieldQuery::Selector.build(fields)
  end

  it 'has default scope for everything but not nested' do
    sel = build_parsed nil
    sel.includes?('foo').should be_false
    sel.excludes?('foo').should be_false
    sel['foo'].should be_nil
  end

  it 'has full scope for everything nested' do
    sel = build_parsed '*'
    sel.includes?('foo').should be_true
    sel.includes?('bar').should be_true
    sel.excludes?('foo').should be_false
    sel.excludes?('bar').should be_false
    sel['foo'].should be_a Garage::NestedFieldQuery::FullSelector
  end

  it 'has default scope for foo' do
    sel = build_parsed 'foo'
    sel.includes?('foo').should be_true
    sel.includes?('bar').should be_false
    sel['foo'].should be_a Garage::NestedFieldQuery::DefaultSelector
  end

  it 'has a scoped selector for foo' do
    sel = build_parsed 'foo[bar]'
    sel.includes?('foo').should be_true
    sel['foo'].includes?('bar').should be_true
    sel['foo'].includes?('baz').should be_false
    sel['foo'].excludes?('bar').should be_false
    sel['foo'].excludes?('baz').should be_true
  end

  it 'has a scoped selector for foo with *' do
    sel = build_parsed 'foo[*]'
    sel.includes?('foo').should be_true
    sel['foo'].includes?('bar').should be_true
    sel['foo'].includes?('baz').should be_true
    sel['foo'].excludes?('bar').should be_false
    sel['foo'].excludes?('baz').should be_false
  end
end
