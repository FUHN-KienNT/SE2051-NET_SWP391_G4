package com.learnhub.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebFilter(filterName = "EncodingFilter", urlPatterns = {"/*"})
public class EncodingFilter implements Filter {

    /**
     * Init.
     *
     * @param filterConfig the filter config
     */
    @Override
    public void init(FilterConfig filterConfig) {
    }

    /**
     * Filters an incoming request before it reaches the target resource.
     *
     * @param request the incoming request
     * @param response the outgoing response
     * @param chain the chain
     * @throws IOException if the operation cannot complete
     * @throws ServletException if the operation cannot complete
     */
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        // Let Tomcat choose the correct MIME type for static CSS, JS, and images.
        if (!(request instanceof HttpServletRequest httpRequest)
                || !httpRequest.getServletPath().startsWith("/assets/")) {
            response.setContentType("text/html; charset=UTF-8");
        }
        chain.doFilter(request, response);
    }

    /**
     * Destroy.
     */
    @Override
    public void destroy() {
    }
}
