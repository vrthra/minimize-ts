#!/usr/bin/env ruby
require 'set'

def extra()
  tmin.each do |tx|
    # pick a mutant that uniquely kills it out of tmin.
    $mutants.each do |m, ts|
      # is m killed by any other tests in tmin?
      tsx =  tmin & ts
      if tsx.length == 1 && tsx.include?(tx)
        mmin.add(m)
        break
      end
    end
  end
  puts " T:#{$testcases.length} M:#{l} t:#{tmin.length} m:#{mmin.length}"
end

def minimize_testsuite(testcases)
  tcs = testcases.keys.sort_by{|k| testcases[k].length}
  killed_mutants = Set.new
  minsuite = Set.new
  while !tcs.empty? do
    # pick one test case.
    tc = tcs.shift
    mutants = testcases[tc]
    # find all mutants that were not killed earlier.
    non_km = mutants.select{|m| !killed_mutants.include?(m) }
    if non_km.length > 0
      minsuite.add(tc)
    end
    killed_mutants.merge(mutants)
  end
  return [killed_mutants.length, minsuite]
end

def remove_subsumes(mutants)
  mymutants = mutants.keys
  while !mymutants.empty?
    m = mymutants.shift
    tsts = mutants[m]
    next if tsts.nil?
    mutants = mutants.select{|mx, ts| mx == m || !ts.subset?(tsts)}
  end
  return mutants
end


$testcases = {}
$mutants = {}
File.readlines(ARGV[0]).each do |l|
  case l
  when /^#/
    next
  when /^=/
    puts l
  else
    testcase, *mutants = l.split(/ /)
    testcase.strip!
    mutants = mutants.map(&:strip).select{|d| d.length > 0}
    $testcases[testcase.strip] = Set.new(mutants)
    mutants.each do |m|
      $mutants[m] ||= Set.new
      $mutants[m].add(testcase)
    end
  end
end
$testcases.freeze
$mutants.freeze
l,tmin = minimize_testsuite($testcases)
mmin = Set.new
$newmutants = {}
$mutants.each do |m, tsts|
  $newmutants[m] = tsts & tmin 
end
mmin = remove_subsumes($newmutants)
puts " T:#{$testcases.length} M:#{l} t:#{tmin.length} m:#{mmin.length}"
