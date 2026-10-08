(function () {
    const trigger = document.getElementById('notificationButton');
    const panel = document.getElementById('notificationPanel');
    if (!trigger || !panel) return;
    const profileButton = document.getElementById('userMenuBtn');
    const profilePanel = document.getElementById('userMenuPanel');

    const list = document.getElementById('notificationList');
    const status = document.getElementById('notificationStatus');
    const retry = document.getElementById('notificationRetry');
    const readAll = document.getElementById('notificationReadAll');
    const unreadDot = document.getElementById('notificationUnreadDot');
    const limitNote = document.getElementById('notificationLimitNote');
    const url = panel.dataset.notificationUrl;
    const dateFormatter = new Intl.DateTimeFormat('vi-VN', {
        timeZone: 'Asia/Ho_Chi_Minh',
        day: 'numeric', month: 'numeric', year: 'numeric'
    });

    let csrfToken = null;
    let notifications = [];
    let unreadCount = 0;
    let mutationPending = false;
    let requestVersion = 0;

    function isOpen() {
        return !panel.classList.contains('hidden');
    }

    function showStatus(message, canRetry) {
        status.textContent = message;
        status.classList.toggle('hidden', !message);
        retry.classList.toggle('hidden', !canRetry);
    }

    function closePanel(restoreFocus) {
        if (!isOpen()) return;
        panel.classList.add('hidden');
        trigger.setAttribute('aria-expanded', 'false');
        trigger.setAttribute('aria-label', 'Mở thông báo');
        if (restoreFocus) trigger.focus();
    }

    function formatDate(value) {
        if (!value) return '';
        const date = new Date(value);
        return Number.isNaN(date.getTime()) ? '' : dateFormatter.format(date);
    }

    function renderItems(items) {
        notifications = items;
        list.replaceChildren();
        limitNote.classList.toggle('hidden', items.length < 20);

        if (items.length === 0) {
            showStatus('Bạn chưa có thông báo nào.', false);
            return;
        }
        showStatus('', false);

        const fragment = document.createDocumentFragment();
        items.forEach(item => {
            const unread = item.status === 'unread';
            const row = document.createElement('li');
            row.className = 'border-b border-brand-100 last:border-b-0';

            const content = document.createElement(unread ? 'button' : 'div');
            content.className = 'flex w-full items-start gap-3 px-4 py-3 text-left ' +
                (unread
                    ? 'hover:bg-brand-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-brand-700'
                    : 'bg-surface-card');
            if (unread) {
                content.type = 'button';
                content.dataset.notificationId = item.id;
                content.setAttribute('aria-label', 'Đánh dấu đã đọc: ' + item.content);
                content.addEventListener('click', () => markRead(item.id));
            }

            const dot = document.createElement('span');
            dot.className = 'mt-1.5 h-2 w-2 shrink-0 rounded-full ' +
                (unread ? 'bg-status-success' : 'bg-text-secondary');
            dot.setAttribute('aria-hidden', 'true');

            const text = document.createElement('span');
            text.className = 'min-w-0 flex-1';
            const description = document.createElement('span');
            description.className = 'block break-words text-sm leading-relaxed text-text-primary';
            description.textContent = item.content || '';
            const metadata = document.createElement('span');
            metadata.className = 'mt-1 block text-xs text-text-secondary';
            const date = formatDate(item.sentAt);
            metadata.textContent = (item.typeName || 'Hệ thống') + (date ? ' · ' + date : '');

            text.append(description, metadata);
            content.append(dot, text);
            row.appendChild(content);
            fragment.appendChild(row);
        });
        list.appendChild(fragment);
    }

    async function readJson(response) {
        let body;
        try {
            body = await response.json();
        } catch (error) {
            throw new Error('Không thể kết nối đến máy chủ.');
        }
        if (!response.ok) {
            throw new Error(body.error || 'Yêu cầu không thành công.');
        }
        return body;
    }

    function errorMessage(error, fallback) {
        return error instanceof TypeError ? 'Không thể kết nối đến máy chủ.' :
            (error.message || fallback);
    }

    async function loadNotifications() {
        const version = ++requestVersion;
        list.replaceChildren();
        limitNote.classList.add('hidden');
        readAll.disabled = true;
        panel.setAttribute('aria-busy', 'true');
        showStatus('Đang tải thông báo…', false);

        try {
            const response = await fetch(url, { credentials: 'same-origin', cache: 'no-store' });
            const body = await readJson(response);
            if (version !== requestVersion) return false;
            csrfToken = body.csrfToken;
            renderItems(body.notifications || []);
            unreadCount = body.unreadCount;
            readAll.disabled = unreadCount === 0;
            unreadDot.classList.toggle('hidden', unreadCount === 0);
            return true;
        } catch (error) {
            if (version !== requestVersion) return false;
            csrfToken = null;
            notifications = [];
            unreadCount = 0;
            unreadDot.classList.add('hidden');
            showStatus(errorMessage(error, 'Không thể tải thông báo.'), true);
            return false;
        } finally {
            if (version === requestVersion) panel.removeAttribute('aria-busy');
        }
    }

    async function post(path, parameters) {
        if (!csrfToken) throw new Error('Hãy tải lại thông báo.');
        const response = await fetch(url + path, {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'X-CSRF-Token': csrfToken,
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
            },
            body: parameters || ''
        });
        return readJson(response);
    }

    async function markRead(id) {
        if (mutationPending) return;
        mutationPending = true;
        readAll.disabled = true;
        list.querySelectorAll('button').forEach(button => { button.disabled = true; });
        const index = notifications.findIndex(item => item.id === id);
        const next = notifications.slice(index + 1).find(item => item.status === 'unread')
            || notifications.slice(0, index).find(item => item.status === 'unread');

        try {
            await post('/read', new URLSearchParams({ id }).toString());
            const loaded = await loadNotifications();
            if (loaded && isOpen()) {
                const nextButton = [...list.querySelectorAll('button')]
                    .find(button => next && button.dataset.notificationId === next.id);
                (nextButton || panel).focus();
            }
        } catch (error) {
            showStatus(errorMessage(error, 'Không thể cập nhật thông báo.'), false);
            list.querySelectorAll('button').forEach(button => { button.disabled = false; });
        } finally {
            mutationPending = false;
            readAll.disabled = unreadCount === 0;
        }
    }

    async function markAllRead() {
        if (mutationPending || readAll.disabled) return;
        mutationPending = true;
        readAll.disabled = true;
        list.querySelectorAll('button').forEach(button => { button.disabled = true; });
        try {
            await post('/read-all');
            const loaded = await loadNotifications();
            if (loaded && isOpen()) panel.focus();
        } catch (error) {
            showStatus(errorMessage(error, 'Không thể cập nhật thông báo.'), false);
            list.querySelectorAll('button').forEach(button => { button.disabled = false; });
        } finally {
            mutationPending = false;
            readAll.disabled = unreadCount === 0;
        }
    }

    trigger.addEventListener('click', () => {
        if (isOpen()) {
            closePanel(false);
        } else {
            if (profilePanel) {
                profilePanel.classList.remove('opacity-100', 'visible', 'translate-y-0', 'pointer-events-auto');
                profilePanel.classList.add('opacity-0', 'invisible', 'translate-y-1', 'pointer-events-none');
                if (profileButton) profileButton.setAttribute('aria-expanded', 'false');
            }
            panel.classList.remove('hidden');
            trigger.setAttribute('aria-expanded', 'true');
            trigger.setAttribute('aria-label', 'Đóng thông báo');
            panel.focus();
            loadNotifications();
        }
    });
    readAll.addEventListener('click', markAllRead);
    retry.addEventListener('click', loadNotifications);
    document.addEventListener('click', event => {
        if (isOpen() && !panel.contains(event.target) && !trigger.contains(event.target)) {
            closePanel(false);
        }
    });
    document.addEventListener('keydown', event => {
        if (event.key === 'Escape' && isOpen()) {
            event.preventDefault();
            closePanel(true);
        }
    });
})();
