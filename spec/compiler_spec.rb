describe 'Apricot' do
  def apricot(code)
    Rubinius.run_script(Apricot::Compiler.compile_string(code))
  end

  it 'compiles an empty program' do
    apricot(%q||).should == nil
  end

  it 'compiles false, true and nil' do
    apricot(%q|true|).should == true
    apricot(%q|false|).should == false
    apricot(%q|nil|).should == nil
  end

  it 'compiles numbers' do
    apricot(%q|1|).should == 1
    apricot(%q|1.0|).should == 1.0
    apricot(%q|1/3|).should == Rational(1, 3)
  end

  it 'compiles symbols' do
    apricot(%q|:foo|).should == :foo
  end

  it 'compiles strings' do
    apricot(%q|"foo"|).should == "foo"
  end

  it 'compiles arrays' do
    apricot(%q|[]|).should == []
    apricot(%q|[1 2 3]|).should == [1, 2, 3]
  end

  it 'compiles hashes' do
    apricot(%q|{}|).should == {}
    apricot(%q|{:foo 1, :bar 2}|).should == {:foo => 1, :bar => 2}
  end

  it 'compiles constants' do
    apricot(%q|Array|).should == Array
    apricot(%q|Rubinius::Compiler|).should == Rubinius::Compiler
  end

  it 'compiles send forms' do
    apricot(%q|(. 1 class)|).should == Fixnum
    apricot(%q|(. "foo" append "bar")|).should == "foobar"
  end

  it 'compiles constant defs' do
    expect { Foo }.to raise_error(NameError)
    apricot(%q|(def Foo 1)|)
    Foo.should == 1
  end

  it 'compiles if forms' do
    apricot(%q|(if true :foo :bar)|).should == :foo
    apricot(%q|(if false :foo :bar)|).should == :bar
    apricot(%q|(if true :foo)|).should == :foo
    apricot(%q|(if false :foo)|).should == nil
  end

  it 'compiles do forms' do
    apricot(%q|(do)|).should == nil
    apricot(%q|(do 1)|).should == 1
    apricot(%q|(do 1 2 3)|).should == 3
    expect { Bar }.to raise_error(NameError)
    apricot(%q|(do (def Bar 1) Bar)|).should == 1
  end
end
