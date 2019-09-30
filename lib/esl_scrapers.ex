defmodule EslScrapers do
  @moduledoc false

  import Meeseeks.CSS

  # floki_unoptimized

  def floki_unoptimized(html) do
    urls =
      html
      |> Floki.find("a.more")
      |> Floki.attribute("href")

    title =
      html
      |> Floki.find("article.blog_post h1:first-child")
      |> Floki.text()

    author =
      html
      |> Floki.find("article.blog_post p.subheading")
      |> Floki.text(deep: false, sep: "")
      |> String.trim_leading()
      |> String.trim_trailing()

    text =
      html
      |> Floki.find("article.blog_post")
      |> Floki.text()

    %{
      urls: urls,
      post: %{
        title: title,
        author: author,
        text: text
      }
    }
  end

  # floki_optimized

  def floki_optimized(html) do
    parsed_html = Floki.parse(html)

    urls =
      parsed_html
      |> Floki.find("a.more")
      |> Floki.attribute("href")

    post = Floki.find(parsed_html, "article.blog_post")

    title =
      post
      |> Floki.find("h1:first-child")
      |> Floki.text()

    author =
      post
      |> Floki.find("p.subheading")
      |> Floki.text(deep: false, sep: "")
      |> String.trim_leading()
      |> String.trim_trailing()

    text = Floki.text(post)

    %{
      urls: urls,
      post: %{
        title: title,
        author: author,
        text: text
      }
    }
  end

  # meeseeks

  def meeseeks(html) do
    parsed_html = Meeseeks.parse(html)

    urls =
      parsed_html
      |> Meeseeks.all(css("a.more"))
      |> Enum.map(&Meeseeks.attr(&1, "href"))

    post = Meeseeks.one(parsed_html, css("article.blog_post"))

    title =
      post
      |> Meeseeks.one(css("h1:first-child"))
      |> Meeseeks.own_text(collapse_whitespace: false)

    author =
      post
      |> Meeseeks.one(css("p.subheading"))
      |> Meeseeks.own_text(collapse_whitespace: false)

    text = Meeseeks.text(post, collapse_whitespace: false)

    %{
      urls: urls,
      post: %{
        title: title,
        author: author,
        text: text
      }
    }
  end
end
