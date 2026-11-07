package com.learnhub.service;

import com.learnhub.dao.ModuleDAO;
import java.sql.SQLException;
import java.util.UUID;

public class ModuleService {
    private final ModuleDAO moduleDAO = new ModuleDAO();

    private String validateTitle(String title) {
        String name = title == null ? "" : title.strip();
        if (name.isEmpty() || name.codePointCount(0, name.length()) > 255) {
            throw new IllegalArgumentException("Enter a module name of 1 to 255 characters.");
        }
        return name;
    }

    public void createForExpert(UUID courseId, UUID expertId, String title) {
        String name = validateTitle(title);
        try {
            if (!moduleDAO.appendForExpert(courseId, expertId, name)) {
                throw new SecurityException("Course access denied.");
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot create module.", e);
        }
    }
    public void renameForExpert(UUID courseId, UUID moduleId, UUID expertId, String title) {
        updateForExpert(courseId, moduleId, expertId, validateTitle(title), null);
    }

    public void setHiddenForExpert(UUID courseId, UUID moduleId, UUID expertId, boolean hidden) {
        updateForExpert(courseId, moduleId, expertId, null, hidden);
    }

    private void updateForExpert(UUID courseId, UUID moduleId, UUID expertId, String title, Boolean hidden) {
        try {
            if (!moduleDAO.updateForExpert(courseId, moduleId, expertId, title, hidden)) {
                throw new SecurityException("Module access denied.");
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot update module.", e);
        }
    }
}
