warmup = 3
time = 9
memory_time = 3

html = File.read!("data/introducing_telemetry.html")

Benchee.run %{
  "Floki unoptimized" => fn -> EslScrapers.floki_unoptimized(html) end,
  "Floki optimized" => fn -> EslScrapers.floki_optimized(html) end,
  "Meeseeks" => fn -> EslScrapers.meeseeks(html) end
}, warmup: warmup, time: time, memory_time: memory_time
