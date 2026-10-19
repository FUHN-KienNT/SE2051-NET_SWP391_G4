package com.learnhub.controller;

import com.learnhub.constant.AppConstants;
import com.learnhub.entity.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.assertEquals;

class AdminSettingServletTest {
    @Test
    void servletRejectsNonAdminsEvenWithoutFilter() throws Exception {
        for (String role : new String[]{AppConstants.Role.MANAGER, AppConstants.Role.EXPERT,
                AppConstants.Role.STUDENT}) {
            User user = new User();
            user.setRoleCode(role);
            user.setRoleName(role.equals(AppConstants.Role.MANAGER) ? "Manager" : role);
            HttpSession session = (HttpSession) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpSession.class}, (proxy, method, args) -> {
                        if ("getAttribute".equals(method.getName())) {
                            if (AppConstants.SessionKey.CURRENT_USER.equals(args[0])) return user;
                            if ("userRole".equals(args[0])) return role;
                        }
                        return null;
                    });
            for (String path : new String[]{"/admin/settings", "/admin/setting-detail", "/admin/setting-status"}) {
                HttpServletRequest request = (HttpServletRequest) Proxy.newProxyInstance(getClass().getClassLoader(),
                        new Class<?>[]{HttpServletRequest.class}, (proxy, method, args) -> switch (method.getName()) {
                            case "getSession" -> session;
                            case "getServletPath" -> path;
                            default -> null;
                        });
                AtomicInteger error = new AtomicInteger();
                HttpServletResponse response = (HttpServletResponse) Proxy.newProxyInstance(getClass().getClassLoader(),
                        new Class<?>[]{HttpServletResponse.class}, (proxy, method, args) -> {
                            if ("sendError".equals(method.getName())) error.set((Integer) args[0]);
                            return null;
                        });
                AdminSettingServlet servlet = new AdminSettingServlet();
                servlet.doGet(request, response);
                assertEquals(403, error.get(), role + " GET " + path);
                error.set(0);
                servlet.doPost(request, response);
                assertEquals(403, error.get(), role + " POST " + path);
            }
        }
    }
}
