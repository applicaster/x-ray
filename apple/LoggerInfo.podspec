# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name = 'LoggerInfo'
  s.version = '0.0.1'
  s.summary = 'Applicaster Logger'
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.swift_versions = '5.1'
  s.description = <<-DESC
  'Applicaster Logger'
  DESC

  s.homepage = 'git@github.com:applicaster/x-ray.git'
  s.license = 'Appache 2.0'
  s.author = { 'a.kononenko@applicaster.com' => 'a.kononenko@applicaster.com' }
  s.source = { git: 'git@github.com:applicaster/x-ray.git', tag: '0.0.1' }

  s.resources = [
    'Extensions/LoggerNavigationController/**/*.xib',
    'Extensions/LoggerNavigationController/**/*.png'
  ]
  s.source_files = 'Extensions/LoggerNavigationController/**/*.{swift}'
  s.dependency 'XrayLogger'
  s.dependency 'Reporter'
end
