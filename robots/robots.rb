# Put each of your robots here and they will be included via config/boot'

require 'wasCrawlDissemination/cdx_generator'
require 'wasCrawlDissemination/cdx_merge_sort_publish'
require 'wasCrawlDissemination/path_indexer'
require 'wasCrawlPreassembly/build_was_crawl_druid_tree'
require 'wasCrawlPreassembly/content_metadata_generator'
require 'wasCrawlPreassembly/desc_metadata_generator'
require 'wasCrawlPreassembly/end_was_crawl_preassembly'
require 'wasCrawlPreassembly/metadata_extractor'
require 'wasCrawlPreassembly/technical_metadata_generator'
require 'wasDissemination/start_special_dissemination'
require 'wasSeedDissemination/update_thumbnail_generator'
require 'wasSeedPreassembly/build_was_seed_druid_tree'
require 'wasSeedPreassembly/content_metadata_generator'
require 'wasSeedPreassembly/desc_metadata_generator'
require 'wasSeedPreassembly/thumbnail_generator'
require 'wasSeedPreassembly/end_was_seed_preassembly'
