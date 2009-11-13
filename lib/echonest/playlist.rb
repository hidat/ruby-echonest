module Echonest
  class Playlist
    attr_reader :songs

    def initialize(files)
      @songs = files.collect{ |file| Track.analyze(file) }
    end

    # Defaults to 4/4
    def filter_by_time_signature!(opts={})
      target_sig = opts.delete(:target) || 4
      songs.reject! do |data|
        data.time_signature != target_sig
      end

      self
    end

    # Defaults to 120 BPM.
    # Allow the :range option to be passed which is a number (1-100)
    # denoting the desired margin the tempo should fall within.
    def filter_by_tempo!(opts={})
      target_tempo = (opts.delete(:target) || 120).to_f

      if opts[:range]
        diff = target_tempo * (opts[:range].to_f/100.00)
        minimum = target_tempo - diff
        maximum = target_tempo + diff
      else
        minimum = (opts.delete(:min) || 100).to_f
        maximum = (opts.delete(:max) || 140).to_f
      end

      songs.reject! do |data|
        raise "No tempo for #{data.filename}" if !data.tempo
        data.tempo > maximum || data.tempo < minimum
      end

      self
    end

    # Defaults to -10 dB.
    def filter_by_loudness!(opts={})
      target_db = opts.delete(:target) || -10
      songs.reject! do |data|
        data.loudness < target_db.to_f
      end

      self
    end

    def sort_by(key)
      @songs = songs.sort_by{|data| data.key }
    end

    # Output the songs in the desired +format+.
    # Default is PLS (and the only one implemented as of now).
    def print(format = :pls)
      if format == :pls
        puts print_pls
      else
        raise "The '#{format}' format is not implemented yet."
      end
    end

    private
    def print_pls
      pls = "[playlist]\n"
      pls << "NumberOfEntries=#{songs.size}\n\n"

      i = 0
      while i < songs.size do
        num = i+1
        pls << "File#{num}=#{songs[i].filename}\n"
        pls << "Title#{num}=#{songs[i].title || songs[i].filename}\n"
        pls << "Length#{num}=#{songs[i].duration.round}\n\n"
        i+=1
      end

      pls << "Version=2"
    end
  end
end