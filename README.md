# RelationshipAnalyzer

RelationshipAnalyzer analyzes relationships of articles.

# Install

Add the following line to Gemfile.

    gem 'relationshipanalyzer', :git => 'https://github.com/mono0x/relationshipanalyzer.git'

Install the gem.

    $ bundle install

# Getting started

Here is an example of how to analyze related articles.

    require 'MeCab'

    class Tagger

      def initialize
        @tagger = MeCab::Tagger.new
      end

      def tokenize(src)
        @tagger.parse(src).force_encoding(Encoding::UTF_8).split("\n").map {|line|
          parts = line.split(',')
          word, category = parts[0].split("\t")
          [ word, category, parts[6] ]
        }.select {|item|
          case
          when item[1] != '名詞'
            false
          when item[2] != '*'
            false
          when item[0].size < 2
            false
          else
            true
          end
        }.map {|item|
          item[0].downcase
        }
      end

    end

    articles = [
      { :id => ..., :title => ..., :content => ... },
      ...
    ]

    tagger = Tagger.new
    items = Hash[*articles.map {|article|
      [ article.id, { :title => tagger.tokenize(article.title), :content => tagger.tokenize(article.content) } ]
    }.flatten]
    weight = { :title => 3.0, :content => 1.0 }
    threshold = 0.1
    relationships = RelationshipAnalyzer.relationships(items, weight, threshold)

    p relationships[id] # [ { :id => ..., :score => ... }, ... ]

