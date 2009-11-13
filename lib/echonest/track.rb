require 'benchmark'

module Echonest
  class Track < Sequel::Model

    # Returns the corresponding letter for the key number value.
    def key_letter
      %w(C C# D D# E F F# G G# A A# B)[key]
    end

    def minor?
      mode == 0
    end

    def major?
      !minor?
    end

    # TODO: Make global/class var?
    def self.echonest
      Echonest('KT7FDAYYNP4OGOMSI')
    end

    # TODO: Look @ putting this in some Util mixin
    # so the Api class can use it as well.
    def self.md5(filename)
      content = open(filename).read
      Digest::MD5.hexdigest(content)
    end

    def self.analyze(file, force_reanalyze=false)
      file_md5 = md5(file)
      existing = find(:md5 => file_md5)

      if force_reanalyze
        puts "Forcing a re-analyze for #{file}"
      end

      if existing
        puts "Using existing record for #{file}"
        return existing unless force_reanalyze
      end

      puts "Analyzing #{file} (#{file_md5}) remotely..."
      results = existing || new
      time = Benchmark.realtime do
        results.filename = File.expand_path(file)
        results.md5 = file_md5
        results.key = echonest.get_key(file).value
        meta = echonest.get_metadata(file)
        results.artist = meta['artist']
        results.title = meta['title']
        results.album = meta['release']
        results.duration = echonest.get_duration(file)
        results.mode = echonest.get_mode(file).value
        results.loudness = echonest.get_loudness(file)
        results.time_signature = echonest.get_time_signature(file).value
        results.tempo = echonest.get_tempo(file)
        results.fade_out = echonest.get_start_of_fade_out(file)
        results.fade_in = echonest.get_end_of_fade_in(file)
        results.save
      end
      puts "Analyzing took #{time.round} sec."
      results
    end

    private
    def before_create
      self.created_on ||= Time.now
    end

    def before_update
      self.updated_on ||= Time.now
    end
  end
end