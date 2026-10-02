package com.learnhub.controller;

import com.learnhub.dto.CourseDTO;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;
import com.learnhub.service.CourseService;
import com.learnhub.service.LearningProcessService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 *
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"", "/home", "/index"})
public class HomeServlet extends HttpServlet {
    private final CourseService courseService = new CourseService();
    private final LearningProcessService learningService = new LearningProcessService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("currentUser") : null;
        ContinueLearningDTO continueLearning = null;
        if (user != null) {
            continueLearning = learningService.getContinueLearning(user.getId());
            req.setAttribute("continueLearning", continueLearning);
        }
        List<CourseDTO> featuredCourses = courseService.searchPublicCourses("", null, 1, continueLearning == null ? 6 : 7);
        if (continueLearning != null) {
            ContinueLearningDTO current = continueLearning;
            featuredCourses.removeIf(course -> course.getId().equals(current.getCourseId()));
            if (featuredCourses.size() > 6) {
                featuredCourses = featuredCourses.subList(0, 6);
            }
        }
        List<Setting> categories = courseService.getActiveCategories();
        req.setAttribute("featuredCourses", featuredCourses);
        req.setAttribute("categories", categories);
        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
