# -*- coding: utf-8 -*-

class RelationshipAnalyzer

  def initialize(items, weight, threshold = 0)
    @items = items
    @weight = weight
    @threshold = threshold
    @sum = {}
    @tf = {}
    @df = Hash.new(0)
    @tfidf = {}
    @length = {}
    @scores = {}
    items = Hash[*items.map {|id, item| [ id, occurrences(item) ] }.flatten]
    items.values.map {|item| item.keys }.flatten.each do |word|
      @df[word] += 1
    end
    items.each do |lid, lhs|
      items.each do |rid, rhs|
        next unless lid < rid
        score = union_vector(lhs, rhs).map {|word|
          tfidf(lhs, word) * tfidf(rhs, word)
        }.inject(0, &:+) / (length(lhs) * length(rhs))
        next unless score >= @threshold
        @scores[[ lid, rid ]] = score
      end
    end
  end

  def relationship(id)
    @scores.select {|key, score|
      key[0] == id || key[1] == id
    }.sort_by {|key, score|
      -score
    }.map {|key, score|
      { :id => key.find {|i| i != id }, :score => score }
    }
  end

  def self.relationships(items, weight, threshold = 0)
    analyzer = self.new(items, weight, threshold)
    Hash[*items.keys.map {|id| [ id, analyzer.relationship(id) ] }.flatten(1)]
  end

  private

  def union_vector(lhs, rhs)
    lhs.keys.select {|word| rhs.include? word }
  end

  def occurrences(data)
    occurrences = Hash.new(0)
    @weight.each do |name, w|
      data[name].each do |word|
        occurrences[word] += w
      end
    end
    occurrences
  end

  def tf(item, word)
    @sum[item] ||= item.values.inject(&:+)
    @tf[item] ||= item[word] / @sum[item]
  end

  def idf(word)
    1 + Math.log(@items.size / @df[word])
  end

  def tfidf(item, word)
    @tfidf[[item, word]] ||= tf(item, word) * idf(word)
  end

  def inner_product(lhs, rhs)
    lhs.occurrences.keys.map {|word|
      lhs.fetch(word, 0) * rhs.fetch(word, 0)
    }.inject(&:+)
  end

  def length(item)
    @length[item] ||= Math.sqrt(item.keys.map {|word|
      tfidf(item, word)
    }.map {|x|
      x ** 2
    }.inject(&:+))
  end

end

