[![Build Status](https://travis-ci.org/sul-dlss/was_robot_suite.svg?branch=was-robots-base)](https://travis-ci.org/sul-dlss/was_robot_suite)
[![Coverage Status](https://coveralls.io/repos/sul-dlss/was_robot_suite/badge.png)](https://coveralls.io/r/sul-dlsswas_robot_suite)
[![Code Climate](https://codeclimate.com/github/sul-dlss/was_robot_suite/badges/gpa.svg)](https://codeclimate.com/github/sul-dlss/was_robot_suite)
[![Test Coverage](https://codeclimate.com/github/sul-dlss/was_robot_suite/badges/coverage.svg)](https://codeclimate.com/github/sul-dlss/was_robot_suite/coverage)
[![Dependency Status](https://gemnasium.com/badges/github.com/sul-dlss/was_robot_suite.svg)](https://gemnasium.com/github.com/sul-dlss/was_robot_suite)
[![GitHub tagged version](https://badge.fury.io/gh/sul-dlss%2Fwas_robot_suite.svg)](https://badge.fury.io/gh/sul-dlss%2Fwas_robot_suite)

WAS_Robot_Suite
---------------

Robot code for accessioning and preservation of Web Archiving Service Seed and Crawl objects.

## General Robot Documentation

Check the [Wiki](https://github.com/sul-dlss/robot-master/wiki) in the robot-master repo.

To run, use the `lyber-core` infrastructure, which uses `bundle exec controller boot`
to start all robots defined in `config/environments/robots_ENV.yml`.

## Deployment

The WAS robots depend on some java projects:

- [WasMetadataExtractor](https://github.com/sul-dlss/WASMetadataExtractor)
  - to extract metadata from web archiving ARC and WARC files, used by wasCrawlPreassemblyWF.
- [openwayback](https://github.com/sul-dlss/openwayback)
  - to index WARC materials for the Stanford Web Archiving Portal, used by cdx-generator step in wasCrawlDisseminationWF

These java projects use [jenkinsqa](https://jenkinsqa.stanford.edu/) to create deployment artifacts, which are then deployed with capistrano via `config/deploy.rb` (see lines 40-54).

The deployed `was_robot_suite` houses these java artifacts in the `jar` directory.

Various other dependencies can be teased out of `config/environments/example.rb` and [shared_configs](https://github.com/sul-dlss/shared_configs) (was-robotsxxx branches)

# Documentation

See consul pages in Web Archival portal, esp Web Archiving Development Documentation

## wasCrawlPreassembly

Preassembly workflow for web archiving crawl objects (that include (W)ARCs files) to extract and create metadata stream.  It consists of 6 robots:

* `build-was-crawl-druid-tree`: this robot reads the crawl object content (ARCs or WARCs and logs) from directory defined by crawl object label, then it builds druid tree, and copy the content to the druid tree content directory.
* `metadata_extractor`: this robot extracts the metadata from the (W)ARCs files using java jar file. The output is an xml includes metadata for the (W)ARCs and general information about the other files.
* `content_metadata_generator`: this robot generates content metadata based on the xml created from `metadata_extractor` and `contentMetadata.xslt` template.
* `desc_metadata_generator`: this robot generates desc metadata based on the xml created from `metadata_extractor` and `descMetadata.xslt` template.
* `technical_metadata_generator`: this robot generates technical metadata based on the xml created from `metadata_extractor` and `techicalMetadata.xslt` template.
* `end_was_crawl_preassembly`: initiates the accessionWF (of common-accessioning).

## wasCrawlDissemination

Dissemination workflow for web archiving crawl objects.  It is kicked off automagically by the last step in the common-accession/end-accession, as that reads the disseminationWF that is suitable for this object type based on APO. It consists of 3 robots:

* `cdx-generator`: performs the basic indexing for the WARC/ARC files and generates CDX files (Web Archiving index files used by WayBack Machine). Generates 1 CDX file for each WARC file; the generated CDX files will be copied to `/web-archiving-stacks`.
* `cdx-merge-sort-publish`: performs two main tasks:  1) Merge the individual cdx files that are generated in the previous step with the main index file 2) Sort the new generated index file
* `path-indexer`: Creates an inverted index for each WARC file and its physical location in the desk for the WayBack machine.

## wasSeedPreassembly

Preassembly workflow for web archiving seed objects.  It starts with the output of the registration process (via was-registrar service) which is a source xml file that contains the metadata for the seed object.  The metadata source xml file is expected to be in the appropriate xml format, which will then be converted using XSLT.

It consists of 5 robots:

* `build-was-seed-druid-tree`: reads the seed object source xml file from `/was_unaccessioned_data/seed` directory and creates the druid tree under `/dor/workspace`. The content folder contains the `source.xml` that has been generated by was-registrar.
* `desc-metadata-generator`: generates the descMetadata in MODS format for the seed object. The process includes processing the `source.xml` with a predefined XSLT based on the metadata source. For example, if the source.xml has <source>AIT</source> element, the robot will match it with descMetadata_AIT.xslt.
* `thumbnail-generator`: captures a screenshot for the first memento using PhantomJS and includes it as the main image for the object. This image will be used in Argo and SearchWorks.  If the robot fails to generate a thumbnail, it shows as an error in Argo.
* `content-metadata-generator`: generates contentMetadata.xml for the thumbnail by processing the contentMetadata.XSLT template against the available thumbnail.jp2.
* `end-was-seed-preassembly`: initiates the accessionWF (of common-accessioning) and opens/closes version for the old object.

## wasSeedDissemination

This workflow provides the connection between the SDR and the actual web archiving components.  It consists of 1 robot:

* `update-thumbnail-generator`: sends the information about the seed object URI and DRUID to `was-thumbnail-service`.

## wasDissemination

Worfklow to route web archiving objects to the wasSeedDisseminationWF or wasCrawlDisseminationWF based on content type.  Note that the wasDisseminationWF itself is fired off by the accessionWF by using the custom <dissemination><workflow> tag in the APO. For example, if the APO has the following, it'll fire off wasDisseminationWF:

```
<administrativeMetadata>
...
  <dissemination>
    <workflow id="wasDisseminationWF"/>
  </dissemination>
</administrativeMetadata>
```

It consists of 1 robot:

* `start_special_dissemination`: chooses the proper disseminationWF (seed or crawl) based on the WAS object type.
