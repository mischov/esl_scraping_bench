# ESL Scraping Benchmark

An Elixir language HTML parsing and data extraction benchmark inspired by [this Erlang Solutions blog post](https://www.erlang-solutions.com/blog/web-scraping-with-elixir.html).

The post presents unoptimized use of [Floki](https://github.com/philss/floki) to parse and extract information about an ESL blog post and find additional blog links to crawl.

This benchmark compares the performance of original code from the article, the performance of an optimized version of the original Floki code, and the performance of a [Meeseeks](https://github.com/mischov/meeseeks) implementation of the optimized version.

All that is being compared is the time it takes to parse the HTML, extract the required data, and return it in a map.

The three versions being benchmarked can be found [here](https://github.com/mischov/esl_scraping_bench/blob/master/lib/esl_scrapers.ex).

## Notes

### Parsers

The underlying HTML parser being used for Floki is the `mochiweb_html` parser, which is a pure Erlang, non-HTML5 compliant parser.

The underlying HTML parser being used for Meeseeks is the `meeseeks_html5ever` parser, which uses the HTML5 compliant Rust library `html5ever` under the hood.

These two libraries have different performance characteristics, ones which don't universally favor either library in every situation, but if you are planning on parsing HTML when you don't know if it's malformed or not I strongly suggest that you use an HTML5 compliant parser that will handle malformed HTML in the same manner that your browser would (rather than parsing it in an unexpected fashion or not parsing it at all).

Floki has access to an `html5ever`-based parser as well, but it isn't used in this benchmark because

1. The blog post doesn't use it.
2. I couldn't get `html5ever_elixir` to compile on Erlang/OTP 22 when I was writing this.

### Optimizations

The optimized version makes two main optimizations to the unoptimized version

1. The unoptimized version uses the HTML string in `Floki.find`, which means that the whole document is parsed each of the four times `Floki.find` is used.

   The optimized version first parses the HTML string with `Floki.parse` then uses the result of that in `Floki.find`, so that the document is only parsed one time.

2. The unoptimized version selects over the whole document in every call of `Floki.find` even though three of the selectors begins with `article.blog_post`.

   The optimized version selects `article.blog_post`, then sub-selects from the result so that a much smaller space is searched.

## Results

```
$ mix deps.get
$ MIX_ENV=prod mix compile
$ MIX_ENV=prod mix run bench/introducing_telemetry.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-5557U CPU @ 3.10GHz
Number of Available Cores: 4
Available memory: 8 GB
Elixir 1.9.1
Erlang 22.0.7

Benchmark suite executing with the following configuration:
warmup: 3 s
time: 9 s
memory time: 3 s
parallel: 1
inputs: none specified
Estimated total run time: 45 s

Benchmarking Floki optimized...
Benchmarking Floki unoptimized...
Benchmarking Meeseeks...

Name                        ips        average  deviation         median         99th %
Meeseeks                 225.19        4.44 ms     ±3.55%        4.39 ms        5.02 ms
Floki optimized          166.03        6.02 ms     ±7.36%        5.96 ms        7.82 ms
Floki unoptimized         55.46       18.03 ms     ±6.26%       17.77 ms       22.34 ms

Comparison:
Meeseeks                 225.19
Floki optimized          166.03 - 1.36x slower +1.58 ms
Floki unoptimized         55.46 - 4.06x slower +13.59 ms

Memory usage statistics:

Name                 Memory usage
Meeseeks                  0.42 MB
Floki optimized           6.25 MB - 14.98x memory usage +5.84 MB
Floki unoptimized        20.90 MB - 50.04x memory usage +20.48 MB

**All measurements for memory usage were the same**
```
