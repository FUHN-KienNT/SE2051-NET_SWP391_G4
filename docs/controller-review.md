# Rà soát controller

Đã đọc toàn bộ 24 Servlet và đối chiếu mapping, filter phân quyền, các service liên quan.
Sau chỉnh sửa còn 22 Servlet và một helper package-private `ControllerSupport`.
Mọi URL cũ được giữ nguyên; không đổi JSP, database hoặc cấu hình filter.

## Các thay đổi

- `PaymentServlet` thay cho `PaymentCheckoutServlet` và `PaymentHistoryServlet`: checkout, polling và lịch sử thanh toán. Hai URL lịch sử vẫn chỉ chấp nhận GET/HEAD, không nhận POST mock-pay.
- `VNPayServlet` thay cho `VNPayReturnServlet` và `VNPayWebhookServlet`: giữ riêng handler trả JSP và handler IPN trả JSON.
- `ControllerSupport`: đọc người dùng từ session không tạo session mới; parse UUID tùy chọn, phân trang, redirect đăng nhập và thiết lập session sau đăng nhập. Giữ kiểm tra quyền và lỗi cụ thể ở từng Servlet.
- `QuizManagementServlet`: dùng chung phần nạp lựa chọn khóa học/module và tạo redirect; bỏ banner, cách xuống dòng dư thừa.
- `QuizServlet`: tái sử dụng kiểm tra quyền truy cập đăng ký từ `LearningProcessService` thay vì sao chép quy tắc.
- `AdminSettingServlet`: bỏ danh sách CORE_ROLES không có tác dụng do biểu thức `|| true`; bỏ nhánh ngăn vô hiệu hóa không thể chạy sau khi đã ép role sang active.
- Các controller khác: tái sử dụng helper khi tương đương, bỏ import không dùng. Giữ các guard khác nhau giữa admin, manager, expert và student.

## Các Servlet còn lại

| Servlet | URL |
| --- | --- |
| AdminCourseServlet | `/admin/courses`, `/manager/courses`, `/admin/course-status`, `/admin/course-detail` |
| AdminDashboardServlet | `/admin/dashboard` |
| AdminSettingServlet | `/admin/settings`, `/admin/setting-detail`, `/admin/setting-status` |
| AuthServlet | `/auth/login`, `/auth/register`, `/auth/verify-email`, `/auth/resend-code`, `/auth/logout`, `/auth/forgot-password`, `/auth/forgot-password/verify`, `/auth/reset-password` |
| CourseServlet | `/courses`, `/course-detail`, `/courses/register`, `/expert/dashboard`, `/learn/course` |
| EnrollmentServlet | `/enroll`, `/enrollment`, `/my-enrollments` |
| ErrorServlet | `/error` |
| HomeServlet | `(context root)`, `/home`, `/index` |
| LearningProcessServlet | `/learn/lesson`, `/learn/complete` |
| LessonReviewServlet | `/admin/lesson-review` |
| LessonServlet | `/lessons/manage`, `/lessons/upload` |
| ManagerDashboardServlet | `/manager/dashboard` |
| NotificationServlet | `/notifications`, `/notifications/read`, `/notifications/read-all` |
| OAuthServlet | `/auth/oauth/google`, `/auth/oauth/google/callback`, `/auth/oauth/github`, `/auth/oauth/github/callback`, `/auth/oauth/complete-profile` |
| PaymentServlet | `/payment/checkout`, `/my-payments`, `/payment/history` |
| ProfileAccountServlet | `/profile`, `/account`, `/account/profile`, `/account/password`, `/account/set-password` |
| QuestionServlet | `/questions/manage`, `/questions/detail` |
| QuizManagementServlet | `/quiz/manage`, `/quiz/detail` |
| QuizServlet | `/quiz`, `/quiz/take`, `/quiz/submit`, `/quiz/history`, `/quiz/view`, `/quiz/info` |
| SePayWebhookServlet | `/api/payment/sepay-webhook` |
| UserServlet | `/admin/users`, `/admin/user-detail`, `/admin/user-status`, `/admin/reset-password` |
| VNPayServlet | `/payment/vnpay-return`, `/api/payment/vnpay-ipn` |

Không gộp controller quản lý với controller học tập vì quyền truy cập, dữ liệu và vòng đời khác nhau. Giữ OAuth riêng với xác thực mật khẩu; giữ SePay riêng với VNPay vì định dạng webhook khác nhau. Không xóa endpoint chỉ vì không tìm thấy link trong JSP: callback có thể được gọi từ hệ thống ngoài.

## Các vấn đề có sẵn cần xử lý riêng

Đợt này giữ hành vi hiện tại; các điểm dưới đây là lỗi nghiệp vụ/bảo mật, không phải code thừa có thể xóa:

- VNPay return tính `isChecksumValid` nhưng chưa dùng để chặn cập nhật thanh toán; IPN có kiểm tra chữ ký. Không nên hiểu việc gom controller là đã sửa xác thực thanh toán.
- SePay webhook chưa kiểm tra xác thực nguồn gửi hoặc đối chiếu số tiền; checkout còn action `mock-pay`.
- Course detail còn trả chuỗi `DEBUG` khi không tìm thấy khóa học.
- Một số controller bắt `Exception` rồi bỏ qua; đổi đồng loạt sẽ thay đổi cách báo lỗi. Cần test tích hợp cho từng luồng trước khi sửa.
- Logic mã xác thực đăng ký/reset còn lặp nhưng đang lưu object Serializable trong session; tách model cần xem xét tương thích session khi triển khai.

## Kiểm tra

- Test mapping kiểm tra toàn bộ URL cũ, phát hiện URL bị mất/thêm hoặc trùng.
- Test hồi quy kiểm tra session, redirect, phân trang/UUID, bắt buộc đổi mật khẩu, các URL lịch sử thanh toán, checkout thiếu ID và VNPay IPN thiếu chữ ký.
- Chạy Maven clean test và đóng gói WAR; chưa chạy luồng thanh toán thật hoặc kiểm thử trình duyệt với database.
- Khi triển khai nên thay WAR sạch để các class Servlet cũ không còn trong thư mục ứng dụng đã bung.
