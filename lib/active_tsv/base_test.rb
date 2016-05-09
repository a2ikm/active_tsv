require 'active_tsv'

module ActiveTsvBaseTest
  class User < ActiveTsv::Base
    self.table_path = "data/users.tsv"
    scope :thirty, -> { where(age: 30) }
    scope :age, ->(a) { where(age: a) }
  end

  def test_s_scope(t)
    unless User.thirty.to_a == User.where(age: 30).to_a
      t.error("named scope not expected behavior")
    end

    unless User.age(29) == User.where(age: 29)
      t.error("foo")
    end
  end

  def test_s_table_path(t)
    begin
      User.class_eval do
        self.table_path = nil
      end
    rescue TypeError
    else
      t.error("expect raise ArgumentError but nothing")
    end

    begin
      User.class_eval do
        self.table_path = 'a'
      end
    rescue Errno::ENOENT
    else
      t.error("expect raise ArgumentError but nothing")
    end

    User.class_eval do
      self.table_path = "data/names.tsv"
    end
    unless User.first.name == "foo"
      t.error("load error when table_path was changed")
    end

  ensure
    User.class_eval do
      self.table_path = "data/users.tsv"
    end
  end

  def test_s_all(t)
    r = User.all
    unless ActiveTsv::Relation === r
      t.error("break return value")
    end

    all = r.to_a
    unless all.all? { |i| User === i }
      t.error("unexpected classes")
    end

    unless all.length == 3
      t.error("unexpected size")
    end
  end

  def test_initialize(t)
    u = User.new
    unless User === u
      t.error("break return value")
    end

    {
      id:   nil,
      name: nil,
      age:  nil,
    }.each do |k, v|
      unless u[k] == v
        t.error("User##{k} expect #{v} got #{u[k]}")
      end
    end

    [
      -> { User.new(1) },
      -> { User.new(nil) },
    ].each do |block|
      begin
        block.call
      rescue ArgumentError
      else
        t.error("Should raise ArgumentError but nothing")
      end
    end
  end

  def test_where(t)
    r = User.where(age: "30")
    unless ActiveTsv::Relation === r
      t.error("return value was break")
    end
  end

  def test_first(t)
    u = User.first
    unless User === u
      t.error("return value was break")
    end

    {
      id:   "1",
      name: "ksss",
      age:  "30",
    }.each do |k, v|
      unless u[k] == v
        t.error("User##{k} expect #{v} got #{u[k]}")
      end
    end
  end

  def test_last(t)
    u = User.last
    unless User === u
      t.error("break return value")
    end

    {
      id:   "3",
      name: "bar",
      age:  "30",
    }.each do |k, v|
      unless u[k] == v
        t.error("User##{k} expect #{v} got #{u[k]}")
      end
    end
  end

  def test_count(t)
    unless User.count === 3
      t.error("all count expect 3")
    end

    unless User.where(age: 30).count == 2
      t.error("where(age: 30) count expect 2")
    end
  end

  def test_equal(t)
    unless User.first == User.first
      t.error("expect same object")
    end
    unless User.first.eql?(User.first)
      t.error("expect same object")
    end
  end
end
