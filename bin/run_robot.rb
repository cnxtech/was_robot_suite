#!/usr/bin/env ruby
# Will run one robot as specified, either for a druid a file containing one druid per line
#
# To run With Options
# Options must be placed AFTER workflow and robot name
# robot_root$ ./bin/run_robot dor:accessionWF:shelve -e test -d druid:aa12bb1234
require 'bundler/setup'
require 'slop'

slop = Slop.new do
  banner 'Usage: run_robot repo:workflow:step [options]'
  on :e, :environment=, 'Environment to run in (i.e. test, production). Defaults to development'
  on :d, :druid=, 'One druid to run the robot with'
  on :f, :file=, 'One file containing a druid per line'
end

unless ARGV.first =~ /^\w+:\w+:[-_\w]+$/
  puts slop.help
  exit 1
end

robot = ARGV.shift
slop.parse
opts = slop.to_h

ENV['ROBOT_ENVIRONMENT'] = opts[:environment] unless opts[:environment].nil?
require File.expand_path(File.dirname(__FILE__) + '/../config/boot')

# generate the robot job class name
class_name = LyberCore::Robot.step_to_classname robot

# instantiate a Robot object using the name
klazz = class_name.split('::').inject(Object) { |o, c| o.const_get c }
bot = klazz.new
bot.check_queued_status = false  # skipping the queued workflow status check

if opts[:file]
  druids = IO.readlines(opts[:file]).map {|l| l.strip}
else
  druids = [opts[:druid]]
end

robot_split = robot.split(":")
druids.each do |druid|
  # the step must be queued, otherwise the run robot step will fail
  Dor::Config.workflow.client.update_workflow_status(robot_split[0], druid, robot_split[1], robot_split[2], 'queued')
  bot.work druid
end
