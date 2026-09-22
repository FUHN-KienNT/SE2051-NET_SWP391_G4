<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<footer class="mt-auto bg-slate-900 text-slate-400 border-t border-slate-800">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div class="col-span-1 md:col-span-2">
                <div class="flex items-center space-x-2 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-brand-600 flex items-center justify-center text-white">
                        <i class="fa-solid fa-graduation-cap text-lg"></i>
                    </div>
                    <span class="text-xl font-black text-white">LearnHub</span>
                </div>
                <p class="text-sm text-slate-400 max-w-sm mb-4">
                    Hệ thống quản lý học tập trực tuyến hiện đại (LMS) dành cho sinh viên và chuyên gia, thiết kế theo tiêu chuẩn công nghệ Jakarta EE & PostgreSQL.
                </p>
                <div class="flex space-x-4 text-slate-400">
                    <a href="#" class="hover:text-white"><i class="fa-brands fa-facebook"></i></a>
                    <a href="#" class="hover:text-white"><i class="fa-brands fa-github"></i></a>
                    <a href="#" class="hover:text-white"><i class="fa-brands fa-youtube"></i></a>
                </div>
            </div>
            <div>
                <h4 class="text-sm font-bold text-white uppercase tracking-wider mb-4">Danh mục</h4>
                <ul class="space-y-2 text-sm">
                    <li><a href="${pageContext.request.contextPath}/courses" class="hover:text-white">Tất cả khóa học</a></li>
                    <li><a href="${pageContext.request.contextPath}/courses?category=it" class="hover:text-white">Lập trình & CNTT</a></li>
                    <li><a href="${pageContext.request.contextPath}/courses?category=business" class="hover:text-white">Kinh doanh</a></li>
                    <li><a href="${pageContext.request.contextPath}/courses?category=language" class="hover:text-white">Ngoại ngữ</a></li>
                </ul>
            </div>
            <div>
                <h4 class="text-sm font-bold text-white uppercase tracking-wider mb-4">Hỗ trợ & Pháp lý</h4>
                <ul class="space-y-2 text-sm">
                    <li><a href="#" class="hover:text-white">Hướng dẫn sử dụng</a></li>
                    <li><a href="#" class="hover:text-white">Chính sách bảo mật</a></li>
                    <li><a href="#" class="hover:text-white">Điều khoản dịch vụ</a></li>
                    <li><a href="#" class="hover:text-white">Thanh toán VNPay</a></li>
                </ul>
            </div>
        </div>
        <div class="border-t border-slate-800 mt-8 pt-6 flex flex-col sm:flex-row items-center justify-between text-xs text-slate-500">
            <p>&copy; 2026 LearnHub Platform - SWP391 Group 4. Tất cả các quyền được bảo lưu.</p>
            <p>Developed with Jakarta EE & PostgreSQL</p>
        </div>
    </div>
</footer>
</body>
</html>
