import '../../models/opportunity.dart';

class SkillMatcher {
  static double score(List<String> studentSkills, Opportunity opp) {
    if (opp.skillsRequired.isEmpty) return 0.0;
    final student = studentSkills.map((s) => s.toLowerCase().trim()).toSet();
    final required = opp.skillsRequired.map((s) => s.toLowerCase().trim());
    final matches = required.where(student.contains).length;
    return matches / opp.skillsRequired.length;
  }

  static List<Opportunity> recommend(
    List<String> studentSkills,
    List<Opportunity> opportunities, {
    double minScore = 0.01,
  }) {
    final scored =
        opportunities
            .where((o) => o.isOpen)
            .map((o) => MapEntry(o, score(studentSkills, o)))
            .where((e) => e.value >= minScore)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }
}
