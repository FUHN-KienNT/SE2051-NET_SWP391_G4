package com.fpt.lms.controller;

import com.fpt.lms.dto.LessonDTO;
import com.fpt.lms.entity.Lesson;
import com.fpt.lms.service.LessonService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;

/**
 * Servlet handling Lesson administration & material uploads.
 * Implements methods specified in SDS Lesson Learning Class Diagram (4.1):
 * - showLessonList()
 * - showLessonDetail()
 * - saveAndRedirect()
 */
@WebServlet(name = "LessonServlet", urlPatterns = {"/lessons/manage", "/lessons/upload"})
@MultipartConfig(maxFileSize = 50 * 1024 * 1024)
public class LessonServlet extends HttpServlet {
    private final LessonService lessonService = new LessonService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String lessonIdStr = req.getParameter("id");
        if (lessonIdStr != null) {
            try {
                UUID lessonId = UUID.fromString(lessonIdStr);
                LessonDTO dto = lessonService.getLesson(lessonId);
                req.setAttribute("lesson", dto);
            } catch (Exception ignored) {
            }
        }
        req.getRequestDispatcher("/WEB-INF/views/learn/lesson-manage.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("upload".equalsIgnoreCase(action)) {
            String lessonIdStr = req.getParameter("lessonId");
            Part filePart = req.getPart("file");
            if (lessonIdStr != null && filePart != null) {
                try {
                    UUID lessonId = UUID.fromString(lessonIdStr);
                    InputStream inputStream = filePart.getInputStream();
                    String filename = filePart.getSubmittedFileName();
                    lessonService.attachMaterial(lessonId, inputStream, filename);
                } catch (Exception ignored) {
                }
            }
            resp.sendRedirect(req.getContextPath() + "/lessons/manage?id=" + req.getParameter("lessonId") + "&uploaded=true");
            return;
        }

        // Save lesson
        String idStr = req.getParameter("id");
        String moduleIdStr = req.getParameter("moduleId");
        String title = req.getParameter("title");
        String content = req.getParameter("content");

        try {
            UUID id = idStr != null && !idStr.isEmpty() ? UUID.fromString(idStr) : UUID.randomUUID();
            UUID moduleId = UUID.fromString(moduleIdStr);
            LessonDTO dto = new LessonDTO(id, moduleId, title, content, 1);
            lessonService.saveLesson(dto);
            resp.sendRedirect(req.getContextPath() + "/course-detail?id=" + req.getParameter("courseId"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/courses");
        }
    }
}
