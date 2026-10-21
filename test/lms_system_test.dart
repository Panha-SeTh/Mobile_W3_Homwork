import 'package:test/test.dart';
import '../lib/service/lms_system.dart';

void main() {
  test('creates a student', () {
    final lms = LmsSystem();

    // Create a student
    lms.addStudent(studentId: 'S1', studentName: "ronan");

    expect(lms.students.first.name, 'ronan');

    // Remove the student
    lms.removeStudent(studentId: 'S1');
    expect(lms.students.length, 0);
  });

  group('Task 1 — Add and remove courses', () {
    test('Add and remove a course successfully', () {
      final lms = LmsSystem();
      lms.addCourse(courseId: 'C101', courseName: 'Mobile Development');
      expect(lms.courses.length, 1);
      expect(lms.courses.first.name, 'Mobile Development');

      lms.removeCourse(courseId: 'C101');
      expect(lms.courses.isEmpty, true);
    });

    test('Reject duplicate course ID', () {
      final lms = LmsSystem();
      lms.addCourse(courseId: 'C101', courseName: 'Mobile Development');
      expect(
        () => lms.addCourse(courseId: 'C101', courseName: 'Web Development'),
        throwsException,
      );
    });

    test('Reject removal of a nonexistent course', () {
      final lms = LmsSystem();
      expect(
        () => lms.removeCourse(courseId: 'NON_EXISTENT'),
        throwsException,
      );
    });
  });

  group('Task 2 — Enroll a student in a course', () {
    test('Enroll an existing student in an existing course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');

      lms.enrollStudent(studentId: 'S01', courseId: 'C01');

      final course = lms.courses.firstWhere((c) => c.id == 'C01');
      expect(course.studentIds.contains('S01'), true);
    });

    test('Reject enrollment if student does not exist', () {
      final lms = LmsSystem();
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');

      expect(
        () => lms.enrollStudent(studentId: 'GHOST', courseId: 'C01'),
        throwsException,
      );
    });

    test('Reject enrollment if course does not exist', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');

      expect(
        () => lms.enrollStudent(studentId: 'S01', courseId: 'GHOST'),
        throwsException,
      );
    });

    test('Reject duplicate enrollment', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');

      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      expect(
        () => lms.enrollStudent(studentId: 'S01', courseId: 'C01'),
        throwsException,
      );
    });
  });

  group('Task 3 — Remove a student from a course', () {
    test('Remove an existing enrollment', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');

      lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C01');

      final course = lms.courses.firstWhere((c) => c.id == 'C01');
      expect(course.studentIds.contains('S01'), false);
    });

    test('Reject removal of a nonexistent enrollment', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');

      expect(
        () => lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C01'),
        throwsException,
      );
    });

    test('Verify that student and course still exist after enrollment is removed', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');

      lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C01');

      expect(lms.students.any((s) => s.id == 'S01'), true);
      expect(lms.courses.any((c) => c.id == 'C01'), true);
    });

    test('Verify results are removed when student is removed from course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 90);

      expect(lms.results.length, 1);

      lms.discardStudentFromCourse(studentId: 'S01', courseId: 'C01');

      expect(lms.results.isEmpty, true);
    });

    test('Test removing a student who has enrollments in multiple courses', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
      lms.addCourse(courseId: 'C02', courseName: 'Web Development');

      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S01', courseId: 'C02');
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
      lms.addResult(studentId: 'S01', courseId: 'C02', score: 95);

      lms.removeStudent(studentId: 'S01');

      expect(lms.students.any((s) => s.id == 'S01'), false);
      final c1 = lms.courses.firstWhere((c) => c.id == 'C01');
      final c2 = lms.courses.firstWhere((c) => c.id == 'C02');
      expect(c1.studentIds.contains('S01'), false);
      expect(c2.studentIds.contains('S01'), false);
      expect(lms.results.isEmpty, true);
    });
  });

  group('Task 4 — Add a result to a course', () {
    test('Add a valid result', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');

      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);

      expect(lms.results.length, 1);
      expect(lms.results.first.score, 85);
      expect(lms.results.first.studentId, 'S01');
      expect(lms.results.first.courseId, 'C01');
    });

    test('Reject a result for nonexistent student or course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');

      // Nonexistent student
      expect(
        () => lms.addResult(studentId: 'GHOST', courseId: 'C01', score: 80),
        throwsException,
      );

      // Nonexistent course
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'GHOST', score: 80),
        throwsException,
      );
    });

    test('Reject result for a student who is not enrolled', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');

      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'C01', score: 80),
        throwsException,
      );
    });

    test('Reject an invalid score (< 0 or > 100)', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');

      // Negative score
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'C01', score: -10),
        throwsException,
      );

      // Score above 100
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'C01', score: 105),
        throwsException,
      );
    });

    test('Reject duplicate results for the same course and student', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');

      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85);
      expect(
        () => lms.addResult(studentId: 'S01', courseId: 'C01', score: 90),
        throwsException,
      );
    });
  });

  group('Task 5 — Remove a student result', () {
    test('Remove an existing result', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85, resultId: 'RES_01');

      expect(lms.results.length, 1);
      lms.removeResult(resultId: 'RES_01');
      expect(lms.results.isEmpty, true);
    });

    test('Reject removal of a nonexistent result', () {
      final lms = LmsSystem();
      expect(
        () => lms.removeResult(resultId: 'NON_EXISTENT'),
        throwsException,
      );
    });

    test('Verify student, course, and other results remain unchanged when a result is removed', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S01', studentName: 'Alice');
      lms.addStudent(studentId: 'S02', studentName: 'Bob');
      lms.addCourse(courseId: 'C01', courseName: 'Mobile Development');

      lms.enrollStudent(studentId: 'S01', courseId: 'C01');
      lms.enrollStudent(studentId: 'S02', courseId: 'C01');

      lms.addResult(studentId: 'S01', courseId: 'C01', score: 85, resultId: 'RES_01');
      lms.addResult(studentId: 'S02', courseId: 'C01', score: 95, resultId: 'RES_02');

      lms.removeResult(resultId: 'RES_01');

      // Student and course still exist
      expect(lms.students.length, 2);
      expect(lms.courses.length, 1);

      // Remaining result is intact
      expect(lms.results.length, 1);
      expect(lms.results.first.id, 'RES_02');
      expect(lms.results.first.studentId, 'S02');
      expect(lms.results.first.score, 95);
    });
  });
}

