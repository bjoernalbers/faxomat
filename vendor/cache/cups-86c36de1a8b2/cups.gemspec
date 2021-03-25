# -*- encoding: utf-8 -*-
# stub: cups 0.1.10 ruby lib
# stub: ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "cups".freeze
  s.version = "0.1.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nathan Stitt".freeze, "Tadej Murovec".freeze, "Ivan Turkovic".freeze, "Chris Mowforth".freeze]
  s.date = "2021-03-25"
  s.description = "    Ruby CUPS provides a wrapper for the Common UNIX Printing System, allowing rubyists to perform basic tasks like printer discovery, job submission & querying.\n".freeze
  s.email = ["nathan@stitt.org".freeze, "tadej.murovec@gmail.com".freeze, "me@ivanturkovic.com".freeze, "chris@mowforth.com".freeze]
  s.extensions = ["ext/extconf.rb".freeze]
  s.files = ["ext/cups.c".freeze, "ext/extconf.rb".freeze, "ext/ruby_cups.h".freeze, "lib/cups".freeze, "lib/cups/print_job".freeze, "lib/cups/print_job/transient.rb".freeze, "lib/cups/printer".freeze, "lib/cups/printer/printer.rb".freeze, "test/cups_test.rb".freeze, "test/sample.txt".freeze, "test/sample_blank.txt".freeze]
  s.homepage = "https://github.com/m0wfo/cups".freeze
  s.rubyforge_project = "cups".freeze
  s.rubygems_version = "2.6.0".freeze
  s.summary = "A lightweight Ruby library for printing.".freeze
end
