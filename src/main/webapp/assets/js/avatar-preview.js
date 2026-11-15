(function () {
    const input = document.getElementById('avatar-file');
    const form = document.getElementById('avatar-form');
    const crop = document.getElementById('avatar-crop-dialog');
    const view = document.getElementById('avatar-view-dialog');
    const canvas = document.getElementById('avatar-crop-canvas');
    const error = document.getElementById('avatar-crop-error');
    const save = document.getElementById('avatar-save');
    let zoom = 1, horizontal = 50, vertical = 50;
    if (!input || !form || !crop || !view || !canvas) return;
    const image = new Image();
    let objectUrl;
    function draw() {
        const size = Math.min(image.naturalWidth, image.naturalHeight) / zoom;
        const x = (image.naturalWidth - size) * horizontal / 100;
        const y = (image.naturalHeight - size) * vertical / 100;
        canvas.getContext('2d').drawImage(image, x, y, size, size, 0, 0, canvas.width, canvas.height);
    }
    document.getElementById('avatar-current').addEventListener('click', () => view.showModal());
    document.querySelectorAll('[data-close-avatar-dialog]').forEach(button => button.addEventListener('click', () => button.closest('dialog').close()));
    crop.addEventListener('close', () => { input.value = ''; if (objectUrl) URL.revokeObjectURL(objectUrl); objectUrl = null; });
    view.addEventListener('click', event => {
        const rect = view.getBoundingClientRect();
        if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) view.close();
    });
    function changeZoom(factor) { zoom = Math.max(1, Math.min(3, zoom * factor)); draw(); }
    canvas.addEventListener('wheel', event => { event.preventDefault(); changeZoom(event.deltaY < 0 ? 1.1 : 1 / 1.1); }, { passive: false });
    document.getElementById('avatar-zoom-in').addEventListener('click', () => changeZoom(1.1));
    document.getElementById('avatar-zoom-out').addEventListener('click', () => changeZoom(1 / 1.1));
    canvas.addEventListener('keydown', event => {
        const moves = { ArrowLeft: [-5, 0], ArrowRight: [5, 0], ArrowUp: [0, -5], ArrowDown: [0, 5] };
        if (!moves[event.key]) return;
        event.preventDefault();
        horizontal = Math.max(0, Math.min(100, horizontal + moves[event.key][0]));
        vertical = Math.max(0, Math.min(100, vertical + moves[event.key][1]));
        draw();
    });
    let drag;
    canvas.addEventListener('pointerdown', event => {
        event.preventDefault();
        drag = { x: event.clientX, y: event.clientY, horizontal: horizontal, vertical: vertical };
        canvas.setPointerCapture(event.pointerId);
    });
    canvas.addEventListener('pointermove', event => {
        if (!drag) return;
        const size = Math.min(image.naturalWidth, image.naturalHeight) / zoom;
        const width = canvas.getBoundingClientRect().width;
        const clamp = value => Math.max(0, Math.min(100, value));
        const horizontalSpace = image.naturalWidth - size;
        const verticalSpace = image.naturalHeight - size;
        if (horizontalSpace > 0) horizontal = clamp(drag.horizontal - (event.clientX - drag.x) * size / width / horizontalSpace * 100);
        if (verticalSpace > 0) vertical = clamp(drag.vertical - (event.clientY - drag.y) * size / width / verticalSpace * 100);
        draw();
    });
    canvas.addEventListener('pointerup', () => { drag = null; });
    canvas.addEventListener('pointercancel', () => { drag = null; });
    canvas.addEventListener('lostpointercapture', () => { drag = null; });
    input.addEventListener('change', () => {
        const file = input.files[0];
        if (!file) return;
        if (!['image/jpeg', 'image/png'].includes(file.type) || file.size > 5 * 1024 * 1024) {
            input.value = ''; alert('Please choose a JPEG or PNG image up to 5 MB.'); return;
        }
        objectUrl = URL.createObjectURL(file);
        image.onload = () => {
            zoom = 1; horizontal = 50; vertical = 50;
            error.textContent = ''; save.disabled = false; draw(); crop.showModal();
        };
        image.onerror = () => { URL.revokeObjectURL(objectUrl); objectUrl = null; input.value = ''; alert('Could not read this image.'); };
        image.src = objectUrl;
    });
    save.addEventListener('click', () => {
        save.disabled = true;
        canvas.toBlob(blob => {
            if (!blob) { error.textContent = 'Could not prepare the photo. Please try again.'; save.disabled = false; return; }
            const files = new DataTransfer();
            files.items.add(new File([blob], 'avatar.jpg', { type: 'image/jpeg' }));
            input.files = files.files;
            form.requestSubmit();
        }, 'image/jpeg', 0.9);
    });
}());