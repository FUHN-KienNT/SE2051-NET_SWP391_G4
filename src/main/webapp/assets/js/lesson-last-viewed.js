(() => {
    const viewer = document.querySelector('[data-lesson-id]');
    if (!viewer) return;
    const data = viewer.dataset;
    if (!data.lessonUser || !data.lessonCourse || !data.lessonId) return;
    const key = 'learnhub:lastLesson:' + data.lessonContext + ':' + data.lessonUser + ':' + data.lessonCourse;
    try {
        localStorage.setItem(key, JSON.stringify({ lessonId: data.lessonId, lessonTitle: data.lessonTitle }));
    } catch (error) { /* Learning also works without browser storage. */ }
})();
