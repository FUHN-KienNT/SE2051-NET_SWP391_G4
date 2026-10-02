<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi" class="h-full bg-surface">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty pageTitle ? pageTitle : 'LearnHub - Nền Tảng Học Trực Tuyến Hàng Đầu'}</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: {
                            50: '#ecfdf3',
                            100: '#d1fae5',
                            500: '#10b981',
                            600: '#059669',
                            700: '#028446',
                            800: '#026b3a',
                            900: '#064e3b',
                        },
                        surface: '#faf9f6',
                        'surface-footer': '#E7E2D9',
                        'surface-card': '#ffffff',
                        'surface-inverse': '#0a0a0a',
                        'text-primary': '#0f172a',
                        'text-secondary': '#64748b',
                        'border-default': '#e2e8f0',
                        'status-success': '#15803d',
                        'status-warning': '#b45309',
                        'status-danger': '#b91c1c'
                    }
                }
            }
        }
    </script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="flex flex-col min-h-screen bg-surface text-text-primary antialiased">
