require "benchmark"

array = (1..1000).to_a
set = Set.new array

Benchmark.ips do |x|
  x.report("array includes? push") do
    ran = Random.rand(100000)
    if !array.includes? ran
      array.push ran
    end
  end

  x.report("set add?") do
    ran = Random.rand(100000)
    if set.add? ran
    end
  end
end
