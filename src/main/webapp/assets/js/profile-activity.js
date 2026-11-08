(function () {
    const calendar = document.getElementById('activity-calendar');
    const tooltip = document.getElementById('activity-tooltip');
    if (!calendar || !tooltip) return;

    const scroller = calendar.querySelector('.overflow-x-auto');
    const days = Array.from(calendar.querySelectorAll('.activity-day'));
    if (!days.length) return;

    // On narrow screens, start at the most recent weeks while keeping the full year scrollable.
    scroller.scrollLeft = scroller.scrollWidth;

    let activeDay = null;
    let pinnedDay = null;
    days.forEach((day, index) => { day.tabIndex = index === days.length - 1 ? 0 : -1; });

    function placeTooltip(day) {
        const rect = day.getBoundingClientRect();
        const box = tooltip.getBoundingClientRect();
        const left = Math.max(8, Math.min(rect.left + rect.width / 2 - box.width / 2, window.innerWidth - box.width - 8));
        const top = rect.top - box.height - 10 >= 8 ? rect.top - box.height - 10 : rect.bottom + 10;
        tooltip.style.left = left + 'px';
        tooltip.style.top = top + 'px';
    }

    function show(day) {
        activeDay = day;
        const date = new Date(day.dataset.date + 'T00:00:00');
        const count = Number(day.dataset.count);
        const label = date.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
        tooltip.textContent = (count === 0 ? 'No learning activity' : count + ' learning ' + (count === 1 ? 'activity' : 'activities')) + ' on ' + label;
        tooltip.classList.remove('hidden');
        placeTooltip(day);
    }

    function hide() {
        activeDay = null;
        tooltip.classList.add('hidden');
    }

    days.forEach((day, index) => {
        day.addEventListener('pointerenter', (event) => {
            if (event.pointerType === 'mouse' && !pinnedDay) show(day);
        });
        day.addEventListener('pointerleave', () => {
            if (!pinnedDay && document.activeElement !== day) hide();
        });
        day.addEventListener('focus', () => {
            days.forEach((item) => { item.tabIndex = -1; });
            day.tabIndex = 0;
            if (!pinnedDay) show(day);
        });
        day.addEventListener('blur', () => {
            if (!pinnedDay) hide();
        });
        day.addEventListener('click', () => {
            if (pinnedDay === day) {
                pinnedDay = null;
                hide();
            } else {
                pinnedDay = day;
                show(day);
            }
        });
        day.addEventListener('keydown', (event) => {
            const step = { ArrowUp: -1, ArrowDown: 1, ArrowLeft: -7, ArrowRight: 7 }[event.key];
            if (step !== undefined) {
                event.preventDefault();
                pinnedDay = null;
                days[Math.max(0, Math.min(days.length - 1, index + step))].focus();
            } else if (event.key === 'Escape') {
                pinnedDay = null;
                hide();
            }
        });
    });

    document.addEventListener('pointerdown', (event) => {
        if (pinnedDay && !event.target.closest('.activity-day')) {
            pinnedDay = null;
            hide();
        }
    });
    window.addEventListener('scroll', () => { if (activeDay) placeTooltip(activeDay); }, true);
    window.addEventListener('resize', () => { if (activeDay) placeTooltip(activeDay); });
})();
