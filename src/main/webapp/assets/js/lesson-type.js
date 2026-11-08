document.addEventListener('DOMContentLoaded', function () {
    const type = document.getElementById('lessonType');
    const module = document.getElementById('moduleId');
    const quiz = document.getElementById('quizId');
    const video = document.getElementById('videoUrl');
    const content = document.getElementById('content');
    const update = () => {
        const isVideo = type.value === 'video';
        const isQuiz = type.value === 'quiz';
        document.getElementById('videoFields').hidden = !isVideo;
        document.getElementById('quizFields').hidden = !isQuiz;
        document.getElementById('contentFields').hidden = isQuiz;
        document.getElementById('contentRequired').hidden = type.value !== 'content';
        video.disabled = !isVideo;
        video.required = isVideo;
        quiz.disabled = !isQuiz;
        quiz.required = isQuiz;
        for (const option of quiz.options) {
            if (!option.value) continue;
            const matches = option.dataset.moduleId === module.value;
            option.hidden = !matches;
            option.disabled = !matches;
            if (!matches && option.selected) quiz.value = '';
        }
        content.disabled = isQuiz;
        content.dispatchEvent(new Event('lesson-type-change'));
    };
    type.addEventListener('change', update);
    module.addEventListener('change', update);
    update();
});
