require 'bundler/setup'
require 'logasm/preprocessors/whitelist'
require 'benchmark/ips'

pointers = %w[
  /scalar
  /flat_hash/~
  /nested_hash/~/deep_hash/~
  /flat_array/~
  /nested_array/~/deep_array/~
]

preprocessor = Logasm::Preprocessors::Whitelist.new(pointers: pointers)


Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report('Scalar value whitelisting') do
    preprocessor.process(scalar: 'value', bad_scalar: 'value', hash: {})
  end

  x.report('Flat hash whitelisting') do
    preprocessor.process(flat_hash: { scalar: 'value', array: [1, 2], hash: {} })
  end

  x.report('Nested hash whitelisting') do
    preprocessor.process(
      nested_hash: {
        next_level_hash: {
          deep_hash: { scalar: 'value', array: [1, 2] }
        },
        next_level_hash2: {
          deep_hash: { scalar: 'value', array: [1, 2] }
        },
        next_level_hash3: {
          deep_hash: { scalar: 'value', array: [1, 2] }
        }
      }
    )
  end

  x.report('Flat array whitelisting') do
    preprocessor.process(
      nested_array: [
        { deep_array: [1, 2, 3] },
        { deep_array: [1, 2, 3] },
        { deep_array: [1, 2, 3] }
      ]
    )
  end
end
