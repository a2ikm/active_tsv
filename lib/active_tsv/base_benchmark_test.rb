require 'active_tsv'
require 'benchmark'

module ActiveTsvTest
  def benchmark_where(b)
    Tempfile.create(["", ".tsv"]) do |f|
      f.puts [*'a'..'z'].join("\t")
      10000.times do |i|
        f.puts [*1..26].map{ |j| i * j }.join("\t")
      end
      bench_klass = Class.new(ActiveTsv::Base) do
        self.table_path = f.path
      end
      f.flush

      b.reset_timer

      i = 0
      n = 5000
      while i < b.n
        bench_klass.where(a: 1 * n, b: 2 * n, c: 3 * n)
                   .where(d: 4 * n, e: 5 * n, f: 6 * n)
                   .where(g: 7 * n, h: 8 * n, i: 9 * n)
                   .where(j: 10 * n, k: 11 * n, l: 12 * n)
                   .where(m: 13 * n, n: 14 * n, o: 15 * n)
                   .where(p: 16 * n, q: 17 * n, r: 18 * n)
                   .where(s: 19 * n, t: 20 * n, u: 21 * n)
                   .where(v: 22 * n, w: 23 * n, x: 24 * n)
                   .where(y: 25 * n, z: 26 * n).first
        i += 1
      end
    end
  end
end