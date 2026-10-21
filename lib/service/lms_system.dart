import '../model/course.dart';
import '../model/course_result.dart';
import '../model/student.dart';

class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> results = [];

  void addStudent({required String studentId, required String studentName}) {
    // ! Student shall not exist already
    Student? student = _findStudentOrNull(studentId);
    if (student != null) {
      throw Exception('Student $student already exists');
    }

    students.add(Student(id: studentId, name: studentName));
  }

  void addCourse({required String courseId, required String courseName}) {
    Course? course = _findCourseOrNull(courseId);
    if (course != null) {
      throw Exception('Course $course already exists');
    }
    courses.add(Course(id: courseId, name: courseName));
  }

  void removeStudent({required String studentId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }
    // 1- Remove student from the students list
    students.removeWhere((student) => student.id == studentId);

    // 2- Remove student from every course in which they are enrolled
    for (Course course in courses) {
      course.studentIds.remove(studentId);
    }

    // 3- Remove all results belonging to this student
    results.removeWhere((result) => result.studentId == studentId);
  }

  void removeCourse({required String courseId}) {
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    // 1- Remove course from the courses list
    courses.removeWhere((course) => course.id == courseId);

    // 2- Remove all results belonging to this course
    results.removeWhere((result) => result.courseId == courseId);
  }

  // Task 2 — Enroll a student in a course
  void enrollStudent({required String studentId, required String courseId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    if (course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is already enrolled in course $courseId');
    }

    course.studentIds.add(studentId);
  }

  // Task 3 — Remove a student from a course
  void discardStudentFromCourse({required String studentId, required String courseId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }

    // Remove student from the course enrollment list
    course.studentIds.remove(studentId);

    // Remove all results belonging to this student for this course
    results.removeWhere((r) => r.studentId == studentId && r.courseId == courseId);
  }

  // Task 4 — Add a result to a course
  void addResult({
    required String studentId,
    required String courseId,
    required double score,
    String? resultId,
  }) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }

    if (score < 0 || score > 100) {
      throw Exception('Invalid score: $score. Score must be between 0 and 100');
    }

    // Policy: A student can only have one result per course
    CourseResult? existingResult = _findResultForStudentAndCourse(studentId, courseId);
    if (existingResult != null) {
      throw Exception('Result already exists for student $studentId in course $courseId');
    }

    final id = resultId ?? 'R_${studentId}_$courseId';
    results.add(CourseResult(
      id: id,
      studentId: studentId,
      courseId: courseId,
      score: score,
    ));
  }

  // Task 5 — Remove a student result
  void removeResult({required String resultId}) {
    CourseResult? result = _findResultOrNull(resultId);
    if (result == null) {
      throw Exception('Result $resultId not found');
    }

    results.removeWhere((r) => r.id == resultId);
  }


  Student? _findStudentOrNull(String studentId) {
    for (Student s in students) {
      if (s.id == studentId) {
        return s;
      }
    }
    return null; // not found
  }

  Course? _findCourseOrNull(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) {
        return c;
      }
    }
    return null;
  }

  CourseResult? _findResultOrNull(String resultId) {
    for (CourseResult r in results) {
      if (r.id == resultId) {
        return r;
      }
    }
    return null;
  }

  CourseResult? _findResultForStudentAndCourse(String studentId, String courseId) {
    for (CourseResult r in results) {
      if (r.studentId == studentId && r.courseId == courseId) {
        return r;
      }
    }
    return null;
  }
}
