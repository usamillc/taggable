require 'json'
require 'singleton'

module LinkAnnotationsHelper
  def linkable_page?
    current_page?(link_task_path) || current_page?(link_annotation_path)
  end

  def link_mergeable_page?
    current_page?(link_merge_task_path) || current_page?(link_merge_annotation_path)
  end

  def build_html(paragraph, link_annotations, current)
    html = ''

    mapping = Hash.new{|h, k| h[k] = [0, []]}
    last_pos = [0, 0]
    link_annotations
      .sort { |x,y| [x.start_offset, x.end_offset] <=> [y.start_offset, y.end_offset] }
      .each do |l|
        if l.end_offset <= last_pos[1]
          mapping[last_pos[0]] = [last_pos[1], mapping[last_pos[0]][1] << l]
        else
          mapping[l.start_offset] = [l.end_offset, mapping[l.start_offset][1] << l]
          last_pos = [l.start_offset, l.end_offset]
        end
      end

    poss = []
    mapping.each do |k, v|
      poss << [k, v[0]]
    end
    poss.sort! { |x,y| x[0] <=> y[0] }

    no_tag_i = 0
    pos = poss.shift

    in_tag = false

    i = 0
    while i < paragraph.body.length
      c = paragraph.body[i]
      if c == '<'
        in_tag = true
      elsif c == '>'
        in_tag = false
      end
      unless !in_tag && c == paragraph.no_tag[no_tag_i]
        html << c
        i += 1
        next
      end

      if pos && pos[0] == no_tag_i
        diff = pos[1] - pos[0]
        value = paragraph.body[i...(i + diff)]
        if mapping[pos[0]][1].count == 1
          la = mapping[pos[0]][1].first
          if la == current
            html << render('link/current', text: value)
          elsif la.incomplete?
            html << render('link/incomplete', text: value, annotation: la)
          else
            html << render('link/complete', text: value, annotation: la)
          end
        else
          link_annotations = mapping[pos[0]][1]
          badge_class = if link_annotations.include? current
                          'badge-danger'
                        elsif link_annotations.any? { |la| la.incomplete? }
                          'badge-secondary'
                        else
                          'badge-success'
                        end
          html << render('link/multiple_links', text: value, annotations: mapping[pos[0]][1], badge_class: badge_class, current: current, dropdown_id: "#{paragraph.id}-#{pos[0]}")
        end
        no_tag_i += diff
        i += diff
        pos = poss.shift
      else
        html << c
        no_tag_i += 1
        i += 1
      end
    end

    html

  end

  class Trie
    class Node
      attr_accessor :value
      def initialize
        @next = {}
        @value = nil
      end

      def next(c)
        @next.fetch(c.to_sym, nil)
      end

      def add(c)
        n = Node.new
        @next[c.to_sym] = n
        n
      end
    end

    def initialize
      @root = Node.new
    end

    def add(s, sym)
      node = @root
      s.each_char do |c|
        unless node.next(c)
          node = node.add(c)
        else
          node = node.next(c)
        end
      end
      node.value = sym
    end

    def match(text)
      matches = []
      (0...text.length).each do |i|
        node = @root
        text[i..-1].each_char do |c|
          if node.next(c)
            node = node.next(c)
            matches << node.value if node.value
          else
            break
          end
        end
      end
      matches
    end
  end

  class Suggester
    include Singleton

    def initialize
      @redirects = {}
      @titles = Trie.new
      @title_to_pageid = {}
      @pageid_to_fs = {}
      load_redirects
      load_title_to_pageid
      load_pageid_to_fs
    end

    def suggests(value)
      s = []
      suggests = @titles.match(value).uniq.map(&:to_s).sort { |x,y| y.length <=> x.length }
      suggests.each do |suggest|
        unless s.any? {|longer| longer.include? suggest}
          s << suggest
        end
      end

      s << @redirects[value.to_sym] if @redirects[value.to_sym]

      s.uniq.map do |title|
        pageid = @title_to_pageid[title.to_sym]
        fs = @pageid_to_fs[pageid&.to_s&.to_sym]
        {title: title, pageid: pageid, first_sentence: fs} if pageid && fs
      end
    end

    def lookup_pageid(title)
      @title_to_pageid[title.to_sym]
    end

    def lookup_fs(pageid)
      fs = @pageid_to_fs[pageid&.to_s&.to_sym]
      return fs
    end

    private

    def load_redirects
      File.readlines('data/redirect-title.tsv').each do |line|
        redirect, title = line.strip.split("\t")
        @redirects[redirect.to_sym] = title if redirect
      end
    end

    def load_title_to_pageid
      File.readlines('data/title-to-pageid.tsv').each do |line|
        title, pageid = line.strip.split("\t")
        @titles.add(title, title.to_sym) unless title.length == 1 && /\p{Hiragana}|\p{Katakana}/ === title
        @title_to_pageid[title.to_sym] = pageid.to_i
      end
    end

    def load_pageid_to_fs
      File.readlines('data/pageid-first-sentence.tsv').each do |line|
        pageid, fs = line.strip.split("\t")
        @pageid_to_fs[pageid.to_sym] = fs if pageid
      end
    end
  end
end
