#!/usr/bin/env ruby

system("git tag deploy-#{Time.now.to_i}")
system('git push origin --tags')
