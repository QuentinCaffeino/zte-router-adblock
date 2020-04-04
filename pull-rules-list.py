from queue import PriorityQueue
from os import walk
import json


MAX_ELEMENTS=50

TRACKERS_CATEGORIES_WHITELIST=[
  "Advertising",
  "Analytics",
  "Audience Measurement",
  "Third-Party Analytics Marketing"
]

TRACKERS_CATEGORIES_BLACKLIST=[
  "Social Network",
  "CDN"
]

OUTPUT_FILE_PATHNAME="/tmp/zte-router-adblock-rules.txt"


def get_domains_files_pathnames(domains_files_path = "thirdparties/tracker-radar/domains"):
  domains_files_pathnamess = []
  for (dirpath, dirnames, filenames) in walk(domains_files_path):
    for filename in filenames:
      domains_files_pathnamess.append(dirpath + '/' + filename)
    break
  return domains_files_pathnamess


class Rule:
  def __init__(self, json_ = None, dict_ = None):
    self.__dict__ = json.loads(json_) if json_ else dict_

  def __lt__(self, other):
    return self.prevalence > other.prevalence

  def get(self):
    return self.rule.replace('\\', '')


class Domain(Rule):
  def is_a_tracker(self):
    is_in_whitelist = False

    for category in self.categories:
      if category in TRACKERS_CATEGORIES_BLACKLIST:
        return False

      if not is_in_whitelist and category in TRACKERS_CATEGORIES_WHITELIST:
        is_in_whitelist = True

    return is_in_whitelist

  def get(self):
    return self.domain


if __name__ == "__main__":
  rules = PriorityQueue()
  domains_files_pathnamess = get_domains_files_pathnames()

  for domain_file_pathnames in domains_files_pathnamess:
    with open(domain_file_pathnames) as domain_file_handle:
      domain = Domain(domain_file_handle.read())
      if domain.is_a_tracker():
        if domain.prevalence > 0.2:
          rules.put(domain)
        else:
          for rule_ in domain.resources:
            rule = Rule(dict_=rule_)
            rules.put(rule)


  unique_rules = []
  while not rules.empty() and len(unique_rules) < MAX_ELEMENTS:
    rule = rules.get().get()
    if rule not in unique_rules:
      unique_rules.append(rule)

  with open(OUTPUT_FILE_PATHNAME, mode="w") as output_file_handle:
    for rule in unique_rules:
      output_file_handle.write(rule + '\n')
