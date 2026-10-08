<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/common/navbar.jsp" />

<main class="flex-grow bg-surface py-8 md:py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
        <!-- Quiz Header Sticky Top -->
        <div class="sticky top-20 z-40 bg-surface-card/90 backdrop-blur-md p-6 rounded-xl border border-border-default shadow-sm mb-8 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-text-primary tracking-tight">${quiz.title}</h1>
                <p class="text-sm text-text-secondary mt-1 flex flex-wrap items-center gap-2">
                    <span><i class="fa-solid fa-book-bookmark text-brand-700 mr-1"></i> Module: ${quiz.moduleTitle}</span>
                    <span class="text-border-default">•</span>
                    <span><i class="fa-solid fa-bullseye text-brand-700 mr-1"></i> Điểm đạt: ${quiz.passScore} / 10</span>
                </p>
            </div>
            
            <c:if test="${not empty quiz.timeLimit}">
                <div id="timer-container" class="px-4 py-2.5 bg-brand-50 border border-brand-100 rounded-lg text-brand-700 font-semibold text-base flex items-center shrink-0">
                    <i class="fa-regular fa-clock mr-2 text-brand-600"></i>
                    <span class="text-xs uppercase font-medium mr-2 text-text-secondary">Thời gian:</span>
                    <span id="countdown-timer" class="font-bold font-mono">--:--</span>
                </div>
            </c:if>
        </div>

        <!-- Quiz Form -->
        <form id="quiz-form" action="${pageContext.request.contextPath}/quiz" method="post" class="pb-24">
            <input type="hidden" name="action" value="submit">
            <input type="hidden" name="quizId" value="${quiz.id}">
            <input type="hidden" name="attemptId" value="${attempt.id}">

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
                <!-- Left Column: Questions List -->
                <div class="lg:col-span-8 space-y-6">
                    <c:forEach var="q" items="${questions}" varStatus="status">
                        <div id="question-card-${status.count}" class="bg-surface-card p-6 sm:p-8 rounded-xl border border-border-default shadow-sm scroll-mt-28">
                            <div class="flex items-start space-x-3 mb-6">
                                <span id="q-badge-${q.id}" class="w-8 h-8 rounded-lg bg-brand-50 border border-brand-100 text-brand-700 font-bold flex items-center justify-center text-sm shrink-0 mt-0.5 transition-colors">
                                    ${status.count}
                                </span>
                                <h3 class="text-base sm:text-lg font-semibold text-text-primary leading-relaxed">${q.content}</h3>
                            </div>

                            <div class="space-y-3 sm:pl-11">
                                <c:choose>
                                    <c:when test="${q.type == 'multiple_choice'}">
                                        <c:forEach var="opt" items="${q.options}">
                                            <label class="flex items-start p-4 rounded-lg border border-border-default hover:border-brand-500 hover:bg-brand-50/30 cursor-pointer transition-all duration-150 group">
                                                <div class="relative flex items-center justify-center mt-0.5 shrink-0">
                                                    <input type="checkbox" name="question_${q.id}" value="${opt.id}" class="peer sr-only">
                                                    <div class="w-5 h-5 border border-slate-300 rounded bg-white peer-checked:bg-brand-700 peer-checked:border-brand-700 transition-colors"></div>
                                                    <i class="fa-solid fa-check text-white text-xs absolute opacity-0 peer-checked:opacity-100 transition-opacity"></i>
                                                </div>
                                                <span class="ml-3 text-sm sm:text-base text-text-primary group-hover:text-brand-900">${opt.optionText}</span>
                                            </label>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="opt" items="${q.options}">
                                            <label class="flex items-start p-4 rounded-lg border border-border-default hover:border-brand-500 hover:bg-brand-50/30 cursor-pointer transition-all duration-150 group">
                                                <div class="relative flex items-center justify-center mt-0.5 shrink-0">
                                                    <input type="radio" name="question_${q.id}" value="${opt.id}" class="peer sr-only">
                                                    <div class="w-5 h-5 border border-slate-300 rounded-full bg-white peer-checked:border-brand-700 transition-colors"></div>
                                                    <div class="w-2.5 h-2.5 bg-brand-700 rounded-full absolute opacity-0 peer-checked:opacity-100 transition-opacity"></div>
                                                </div>
                                                <span class="ml-3 text-sm sm:text-base text-text-primary group-hover:text-brand-900">${opt.optionText}</span>
                                            </label>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Right Column: Sidebar Question Overview -->
                <div class="lg:col-span-4 space-y-6 lg:sticky lg:top-24 z-30">
                    <div class="bg-surface-card p-6 rounded-xl border border-border-default shadow-sm">
                        <div class="flex items-center justify-between mb-4 pb-3 border-b border-border-default">
                            <h2 class="text-base font-bold text-text-primary flex items-center">
                                <i class="fa-solid fa-list-check text-brand-700 mr-2"></i> Bảng câu hỏi
                            </h2>
                            <span class="text-xs font-semibold px-2.5 py-1 bg-brand-50 text-brand-700 border border-brand-100 rounded-full">
                                Tổng: ${questions.size()} câu
                            </span>
                        </div>

                        <!-- Progress Bar Section -->
                        <div class="mb-5">
                            <div class="flex justify-between items-center text-xs text-text-secondary font-medium mb-1.5">
                                <span>Tiến độ hoàn thành</span>
                                <span id="sidebar-progress-text" class="font-bold text-brand-700">0 / ${questions.size()} câu</span>
                            </div>
                            <div class="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
                                <div id="sidebar-progress-bar" class="bg-brand-600 h-2 rounded-full transition-all duration-300" style="width: 0%"></div>
                            </div>
                        </div>

                        <!-- Question Grid Buttons -->
                        <div class="grid grid-cols-5 sm:grid-cols-8 lg:grid-cols-5 gap-2 max-h-[50vh] overflow-y-auto pr-1">
                            <c:forEach var="q" items="${questions}" varStatus="status">
                                <button type="button"
                                        data-q-nav="${q.id}"
                                        onclick="scrollToQuestion(${status.count})"
                                        class="q-nav-btn w-full aspect-square flex items-center justify-center font-bold text-sm rounded-lg border transition-all duration-150 bg-slate-100 text-slate-700 border-slate-200 hover:bg-slate-200 hover:border-slate-300"
                                        title="Chuyển đến câu ${status.count}">
                                    ${status.count}
                                </button>
                            </c:forEach>
                        </div>

                        <!-- Legend -->
                        <div class="mt-5 pt-4 border-t border-border-default flex items-center justify-around text-xs text-text-secondary font-medium">
                            <div class="flex items-center gap-2">
                                <span class="w-3.5 h-3.5 rounded bg-brand-600 border border-brand-600 inline-block shadow-sm"></span>
                                <span>Đã làm</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="w-3.5 h-3.5 rounded bg-slate-100 border border-slate-200 inline-block"></span>
                                <span>Chưa làm</span>
                            </div>
                        </div>

                        <!-- Sidebar Submit Action -->
                        <div class="mt-5 pt-4 border-t border-border-default">
                            <button type="submit" class="w-full py-3 bg-brand-700 hover:bg-brand-800 text-white font-semibold rounded-lg shadow-sm transition-colors flex items-center justify-center text-sm">
                                <i class="fa-solid fa-paper-plane mr-2"></i> Nộp Bài Thi
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sticky Bottom Submit Action -->
            <div class="fixed bottom-0 left-0 right-0 p-4 bg-surface-card/95 backdrop-blur border-t border-border-default shadow-lg z-50">
                <div class="max-w-7xl mx-auto flex flex-col sm:flex-row justify-between items-center gap-3 px-4 sm:px-6">
                    <p class="text-sm text-text-secondary font-medium hidden sm:flex items-center">
                        <i class="fa-solid fa-circle-info text-brand-700 mr-2"></i>
                        Đã làm&nbsp;<span id="bottom-answered-count" class="font-bold text-brand-700">0</span>/${questions.size()}&nbsp;câu. Vui lòng kiểm tra kỹ trước khi nộp bài.
                    </p>
                    <button type="submit" id="submit-btn" class="w-full sm:w-auto px-8 py-3 bg-brand-700 hover:bg-brand-800 text-white font-semibold rounded-lg shadow-sm transition-colors flex items-center justify-center">
                        <i class="fa-solid fa-paper-plane mr-2"></i> Nộp Bài Thi
                    </button>
                </div>
            </div>
        </form>
    </div>
</main>

<script>
    function scrollToQuestion(index) {
        var card = document.getElementById("question-card-" + index);
        if (card) {
            card.scrollIntoView({ behavior: "smooth", block: "start" });
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        var quizForm = document.getElementById("quiz-form");
        var totalQuestions = ${questions.size()};

        function updateProgress() {
            var answeredCount = 0;
            var navButtons = document.querySelectorAll(".q-nav-btn");

            navButtons.forEach(function(btn) {
                var qId = btn.getAttribute("data-q-nav");
                var inputs = document.querySelectorAll("input[name='question_" + qId + "']");
                var isAnswered = false;

                inputs.forEach(function(input) {
                    if (input.checked) {
                        isAnswered = true;
                    }
                });

                var qBadge = document.getElementById("q-badge-" + qId);

                if (isAnswered) {
                    answeredCount++;
                    btn.className = "q-nav-btn w-full aspect-square flex items-center justify-center font-bold text-sm rounded-lg border transition-all duration-150 bg-brand-600 text-white border-brand-600 shadow-sm";
                    if (qBadge) {
                        qBadge.className = "w-8 h-8 rounded-lg bg-brand-600 text-white font-bold flex items-center justify-center text-sm shrink-0 mt-0.5 transition-colors shadow-sm";
                    }
                } else {
                    btn.className = "q-nav-btn w-full aspect-square flex items-center justify-center font-bold text-sm rounded-lg border transition-all duration-150 bg-slate-100 text-slate-700 border-slate-200 hover:bg-slate-200 hover:border-slate-300";
                    if (qBadge) {
                        qBadge.className = "w-8 h-8 rounded-lg bg-brand-50 border border-brand-100 text-brand-700 font-bold flex items-center justify-center text-sm shrink-0 mt-0.5 transition-colors";
                    }
                }
            });

            var progressPercent = totalQuestions > 0 ? Math.round((answeredCount / totalQuestions) * 100) : 0;
            var sidebarProgressText = document.getElementById("sidebar-progress-text");
            var sidebarProgressBar = document.getElementById("sidebar-progress-bar");
            var bottomAnsweredCount = document.getElementById("bottom-answered-count");

            if (sidebarProgressText) sidebarProgressText.textContent = answeredCount + " / " + totalQuestions + " câu (" + progressPercent + "%)";
            if (sidebarProgressBar) sidebarProgressBar.style.width = progressPercent + "%";
            if (bottomAnsweredCount) bottomAnsweredCount.textContent = answeredCount;
        }

        if (quizForm) {
            quizForm.addEventListener("change", updateProgress);
            updateProgress();
        }

        var timeLimitMinutes = parseInt("${quiz.timeLimit}");
        if (!isNaN(timeLimitMinutes) && timeLimitMinutes > 0) {
            var now = new Date().getTime();
            var endTime = now + (timeLimitMinutes * 60 * 1000);
            
            var timerDisplay = document.getElementById("countdown-timer");
            var timerContainer = document.getElementById("timer-container");

            var updateTimer = setInterval(function() {
                var currentTime = new Date().getTime();
                var distance = endTime - currentTime;

                if (distance <= 0) {
                    clearInterval(updateTimer);
                    if (timerDisplay) timerDisplay.textContent = "00:00";
                    if (timerContainer) {
                        timerContainer.className = "px-4 py-2.5 bg-rose-50 border border-rose-200 rounded-lg text-status-danger font-semibold text-base flex items-center shrink-0 animate-pulse";
                    }
                    var submitBtns = quizForm ? quizForm.querySelectorAll("button[type='submit']") : [];
                    submitBtns.forEach(function(btn) {
                        btn.innerHTML = "<i class='fa-solid fa-spinner fa-spin mr-2'></i> Đang tự động nộp bài...";
                        btn.disabled = true;
                    });
                    if (quizForm) quizForm.submit();
                    return;
                }

                var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((distance % (1000 * 60)) / 1000);

                var minsStr = minutes < 10 ? "0" + minutes : minutes;
                var secsStr = seconds < 10 ? "0" + seconds : seconds;

                if (timerDisplay) timerDisplay.textContent = minsStr + ":" + secsStr;
                
                if (minutes === 0 && seconds <= 30 && timerContainer) {
                    timerContainer.className = "px-4 py-2.5 bg-amber-50 border border-amber-200 rounded-lg text-status-warning font-semibold text-base flex items-center shrink-0 animate-pulse";
                }
            }, 1000);
        }

        if (quizForm) {
            quizForm.addEventListener("submit", function(e) {
                var submitBtns = quizForm.querySelectorAll("button[type='submit']");
                submitBtns.forEach(function(btn) {
                    if (!btn.disabled) {
                        btn.innerHTML = "<i class='fa-solid fa-circle-notch fa-spin mr-2'></i> Đang gửi bài...";
                        btn.disabled = true;
                        btn.classList.add("opacity-80", "cursor-not-allowed");
                    }
                });
            });
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
