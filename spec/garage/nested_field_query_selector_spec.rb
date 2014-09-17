require 'spec_helper'

describe Garage::NestedFieldQuery::Selector do
  def build_parsed(fields)
    Garage::NestedFieldQuery::Selector.build(fields)
  end

  it 'has default scope for everything and it can also be nested' do
    sel = build_parsed nil
    sel.includes?('foo').should be_falsy
    sel.excludes?('foo').should be_falsy
    sel['foo'].should be_a Garage::NestedFieldQuery::DefaultSelector
  end

  it 'has default scope for everything and it can be nested' do
    sel = build_parsed '__default__'
    sel.includes?('foo').should be_falsy
    sel.excludes?('foo').should be_falsy
    sel['foo'].should be_a Garage::NestedFieldQuery::DefaultSelector
  end

  it 'has full scope for everything nested' do
    sel = build_parsed '*'
    sel.includes?('foo').should be_truthy
    sel.includes?('bar').should be_truthy
    sel.excludes?('foo').should be_falsy
    sel.excludes?('bar').should be_falsy
    sel['foo'].should be_a Garage::NestedFieldQuery::FullSelector
  end

  it 'has default scope and specified ones' do
    sel = build_parsed '__default__,baz'
    sel.includes?('foo').should be_falsy
    sel.includes?('bar').should be_falsy
    sel.includes?('baz').should be_truthy
    sel.excludes?('foo').should be_falsy
    sel.excludes?('bar').should be_falsy
    sel['foo'].should be_a Garage::NestedFieldQuery::DefaultSelector
    sel['baz'].should be_a Garage::NestedFieldQuery::DefaultSelector
  end

  it 'has full scope if * is specified' do
    sel = build_parsed '__default__,bar,*'
    sel.includes?('foo').should be_truthy
    sel.includes?('bar').should be_truthy
    sel.excludes?('foo').should be_falsy
    sel.excludes?('bar').should be_falsy
    sel['foo'].should be_a Garage::NestedFieldQuery::FullSelector
  end

  it 'has default scope for foo' do
    sel = build_parsed 'foo'
    sel.includes?('foo').should be_truthy
    sel.includes?('bar').should be_falsy
    sel['foo'].should be_a Garage::NestedFieldQuery::DefaultSelector
  end

  it 'has default scope for foo' do
    sel = build_parsed 'foo[__default__]'
    sel.includes?('foo').should be_truthy
    sel.includes?('bar').should be_falsy
    sel['foo'].includes?('bar').should be_falsy
    sel['foo'].excludes?('bar').should be_falsy
  end

  it 'has a scoped selector for foo' do
    sel = build_parsed 'foo[bar]'
    sel.includes?('foo').should be_truthy
    sel['foo'].includes?('bar').should be_truthy
    sel['foo'].includes?('baz').should be_falsy
    sel['foo'].excludes?('bar').should be_falsy
    sel['foo'].excludes?('baz').should be_truthy
  end

  it 'has a scoped selector for foo with *' do
    sel = build_parsed 'foo[*]'
    sel.includes?('foo').should be_truthy
    sel['foo'].includes?('bar').should be_truthy
    sel['foo'].includes?('baz').should be_truthy
    sel['foo'].excludes?('bar').should be_falsy
    sel['foo'].excludes?('baz').should be_falsy
  end
end
