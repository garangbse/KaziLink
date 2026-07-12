enum OpportunityCategory {
  development,
  design,
  marketing,
  operations,
  research,
  community,
}

extension OpportunityCategoryX on OpportunityCategory {
  String get label => switch (this) {
    OpportunityCategory.development => 'Development',
    OpportunityCategory.design => 'Design',
    OpportunityCategory.marketing => 'Marketing',
    OpportunityCategory.operations => 'Operations',
    OpportunityCategory.research => 'Research',
    OpportunityCategory.community => 'Community',
  };
}
