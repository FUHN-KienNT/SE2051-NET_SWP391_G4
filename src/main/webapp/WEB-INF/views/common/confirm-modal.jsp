<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!-- LearnHub Global Confirmation Web Modal -->
<div id="lhConfirmModal" 
     class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-text-primary/60 backdrop-blur-xs hidden opacity-0 transition-opacity duration-200"
     role="dialog" 
     aria-modal="true" 
     aria-labelledby="lhConfirmTitle">
    <div id="lhConfirmCard" class="bg-surface-card rounded-2xl max-w-md w-full p-6 shadow-2xl border border-border-default transform scale-95 transition-transform duration-200">
        <div class="flex items-start space-x-4">
            <div id="lhConfirmIconContainer" class="w-12 h-12 rounded-2xl bg-rose-50 border border-rose-100 text-status-danger flex items-center justify-center shrink-0 text-xl shadow-xs">
                <i id="lhConfirmIcon" class="fa-solid fa-triangle-exclamation"></i>
            </div>
            <div class="flex-1 min-w-0">
                <h3 id="lhConfirmTitle" class="text-lg font-bold text-text-primary leading-snug">Xác nhận</h3>
                <p id="lhConfirmMessage" class="text-sm text-text-secondary mt-1.5 leading-relaxed">Bạn có chắc chắn muốn thực hiện thao tác này không?</p>
            </div>
        </div>
        <div class="mt-6 flex items-center justify-end space-x-3">
            <button type="button" 
                    id="lhConfirmCancelBtn" 
                    class="px-4 py-2.5 rounded-xl border border-border-default bg-surface-card hover:bg-surface text-text-primary font-semibold text-sm transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 cursor-pointer">
                Hủy bỏ
            </button>
            <button type="button" 
                    id="lhConfirmOkBtn" 
                    class="px-5 py-2.5 rounded-xl bg-status-danger hover:bg-status-danger/90 text-white font-bold text-sm transition shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-status-danger focus-visible:ring-offset-2 cursor-pointer">
                Xác nhận
            </button>
        </div>
    </div>
</div>

<script>
(function() {
    let pendingAction = null;

    window.showConfirmModal = function(options) {
        options = options || {};
        const modal = document.getElementById('lhConfirmModal');
        const card = document.getElementById('lhConfirmCard');
        const titleEl = document.getElementById('lhConfirmTitle');
        const msgEl = document.getElementById('lhConfirmMessage');
        const iconContainer = document.getElementById('lhConfirmIconContainer');
        const iconEl = document.getElementById('lhConfirmIcon');
        const cancelBtn = document.getElementById('lhConfirmCancelBtn');
        const okBtn = document.getElementById('lhConfirmOkBtn');

        if (!modal) return;

        titleEl.textContent = options.title || 'Xác nhận';
        msgEl.textContent = options.message || 'Bạn có chắc chắn muốn thực hiện thao tác này không?';
        cancelBtn.textContent = options.cancelText || 'Hủy bỏ';
        okBtn.textContent = options.confirmText || 'Xác nhận';

        const type = options.type || 'danger';
        if (type === 'danger') {
            iconContainer.className = 'w-12 h-12 rounded-2xl bg-rose-50 border border-rose-100 text-status-danger flex items-center justify-center shrink-0 text-xl shadow-xs';
            iconEl.className = 'fa-solid fa-triangle-exclamation';
            okBtn.className = 'px-5 py-2.5 rounded-xl bg-status-danger hover:bg-status-danger/90 text-white font-bold text-sm transition shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-status-danger focus-visible:ring-offset-2 cursor-pointer';
        } else if (type === 'warning') {
            iconContainer.className = 'w-12 h-12 rounded-2xl bg-amber-50 border border-amber-100 text-status-warning flex items-center justify-center shrink-0 text-xl shadow-xs';
            iconEl.className = 'fa-solid fa-circle-exclamation';
            okBtn.className = 'px-5 py-2.5 rounded-xl bg-status-warning hover:bg-status-warning/90 text-white font-bold text-sm transition shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-status-warning focus-visible:ring-offset-2 cursor-pointer';
        } else {
            iconContainer.className = 'w-12 h-12 rounded-2xl bg-brand-50 border border-brand-100 text-brand-700 flex items-center justify-center shrink-0 text-xl shadow-xs';
            iconEl.className = 'fa-solid fa-circle-check';
            okBtn.className = 'px-5 py-2.5 rounded-xl bg-brand-700 hover:bg-brand-800 text-white font-bold text-sm transition shadow-sm focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-700 focus-visible:ring-offset-2 cursor-pointer';
        }

        pendingAction = options.onConfirm || null;

        modal.classList.remove('hidden');
        requestAnimationFrame(() => {
            modal.classList.remove('opacity-0');
            card.classList.remove('scale-95');
            card.classList.add('scale-100');
            cancelBtn.focus();
        });
    };

    window.closeConfirmModal = function() {
        const modal = document.getElementById('lhConfirmModal');
        const card = document.getElementById('lhConfirmCard');
        if (!modal || modal.classList.contains('hidden')) return;
        modal.classList.add('opacity-0');
        card.classList.remove('scale-100');
        card.classList.add('scale-95');
        setTimeout(() => {
            modal.classList.add('hidden');
            pendingAction = null;
        }, 200);
    };

    document.addEventListener('DOMContentLoaded', function() {
        const modal = document.getElementById('lhConfirmModal');
        const cancelBtn = document.getElementById('lhConfirmCancelBtn');
        const okBtn = document.getElementById('lhConfirmOkBtn');

        if (cancelBtn) {
            cancelBtn.addEventListener('click', window.closeConfirmModal);
        }

        if (okBtn) {
            okBtn.addEventListener('click', function() {
                const action = pendingAction;
                window.closeConfirmModal();
                if (typeof action === 'function') {
                    action();
                }
            });
        }

        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === modal) {
                    window.closeConfirmModal();
                }
            });
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                window.closeConfirmModal();
            }
        });

        // Global delegate listener for elements with data-confirm attribute
        document.body.addEventListener('click', function(e) {
            const trigger = e.target.closest('[data-confirm]');
            if (!trigger) return;

            e.preventDefault();
            const message = trigger.getAttribute('data-confirm') || 'Bạn có chắc chắn muốn thực hiện thao tác này?';
            const title = trigger.getAttribute('data-confirm-title') || 'Xác nhận';
            const confirmText = trigger.getAttribute('data-confirm-btn') || 'Xác nhận';
            const cancelText = trigger.getAttribute('data-confirm-cancel');
            const type = trigger.getAttribute('data-confirm-type') || 'danger';

            showConfirmModal({
                title: title,
                message: message,
                confirmText: confirmText,
                cancelText: cancelText,
                type: type,
                onConfirm: function() {
                    if (trigger.tagName === 'A') {
                        window.location.href = trigger.href;
                    } else if (trigger.tagName === 'BUTTON' || trigger.tagName === 'INPUT') {
                        const form = trigger.closest('form');
                        if (form) {
                            if (trigger.name) {
                                const hidden = document.createElement('input');
                                hidden.type = 'hidden';
                                hidden.name = trigger.name;
                                hidden.value = trigger.value;
                                form.appendChild(hidden);
                            }
                            form.submit();
                        }
                    }
                }
            });
        }, true);
    });
})();
</script>
