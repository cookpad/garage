require 'spec_helper'

describe Garage::NestedFieldQuery::Selector do
  def build_parsed(fields)
    Garage::NestedFieldQuery::Selector.build(fields)
  end

  it 'has default scope for everything and it can also be nested' do
    sel = build_parsed nil
    expect(sel.includes?('foo')).to be_falsey
    expect(sel.excludes?('foo')).to be_falsey
    expect(sel['foo']).to be_a Garage::NestedFieldQuery::DefaultSelector
  end

  it 'has default scope for everything and it can be nested' do
    sel = build_parsed '__default__'
    expect(sel.includes?('foo')).to be_falsey
    expect(sel.excludes?('foo')).to be_falsey
    expect(sel['foo']).to be_a Garage::NestedFieldQuery::DefaultSelector
  end

  it 'has full scope for everything nested' do
    sel = build_parsed '*'
    expect(sel.includes?('foo')).to be_truthy
    expect(sel.includes?('bar')).to be_truthy
    expect(sel.excludes?('foo')).to be_falsey
    expect(sel.excludes?('bar')).to be_falsey
    expect(sel['foo']).to be_a Garage::NestedFieldQuery::FullSelector
  end

  it 'has default scope and specified ones' do
    sel = build_parsed '__default__,baz'
    expect(sel.includes?('foo')).to be_falsey
    expect(sel.includes?('bar')).to be_falsey
    expect(sel.includes?('baz')).to be_truthy
    expect(sel.excludes?('foo')).to be_falsey
    expect(sel.excludes?('bar')).to be_falsey
    expect(sel['foo']).to be_a Garage::NestedFieldQuery::DefaultSelector
    expect(sel['baz']).to be_a Garage::NestedFieldQuery::DefaultSelector
  end

  it 'has full scope if * is specified' do
    sel = build_parsed '__default__,bar,*'
    expect(sel.includes?('foo')).to be_truthy
    expect(sel.includes?('bar')).to be_truthy
    expect(sel.excludes?('foo')).to be_falsey
    expect(sel.excludes?('bar')).to be_falsey
    expect(sel['foo']).to be_a Garage::NestedFieldQuery::FullSelector
  end

  it 'has default scope for foo' do
    sel = build_parsed 'foo'
    expect(sel.includes?('foo')).to be_truthy
    expect(sel.includes?('bar')).to be_falsey
    expect(sel['foo']).to be_a Garage::NestedFieldQuery::DefaultSelector
  end

  it 'has default scope for foo' do
    sel = build_parsed 'foo[__default__]'
    expect(sel.includes?('foo')).to be_truthy
    expect(sel.includes?('bar')).to be_falsey
    expect(sel['foo'].includes?('bar')).to be_falsey
    expect(sel['foo'].excludes?('bar')).to be_falsey
  end

  it 'has a scoped selector for foo' do
    sel = build_parsed 'foo[bar]'
    expect(sel.includes?('foo')).to be_truthy
    expect(sel['foo'].includes?('bar')).to be_truthy
    expect(sel['foo'].includes?('baz')).to be_falsey
    expect(sel['foo'].excludes?('bar')).to be_falsey
    expect(sel['foo'].excludes?('baz')).to be_truthy
  end

  it 'has a scoped selector for foo with *' do
    sel = build_parsed 'foo[*]'
    expect(sel.includes?('foo')).to be_truthy
    expect(sel['foo'].includes?('bar')).to be_truthy
    expect(sel['foo'].includes?('baz')).to be_truthy
    expect(sel['foo'].excludes?('bar')).to be_falsey
    expect(sel['foo'].excludes?('baz')).to be_falsey
  end
end
