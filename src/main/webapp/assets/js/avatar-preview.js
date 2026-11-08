(function () {
    const input = document.getElementById('avatar-file');
    const preview = document.getElementById('avatar-preview');
    const current = document.getElementById('avatar-current');
    if (!input || !preview || !current) return;
    let url;
    input.addEventListener('change', function () {
        if (url) URL.revokeObjectURL(url);
        const file = input.files && input.files[0];
        if (!file || !['image/jpeg', 'image/png'].includes(file.type) || file.size > 5 * 1024 * 1024) {
            preview.classList.add('hidden');
            current.classList.remove('hidden');
            return;
        }
        url = URL.createObjectURL(file);
        preview.src = url;
        preview.classList.remove('hidden');
        current.classList.add('hidden');
    });
    preview.addEventListener('error', function () {
        preview.classList.add('hidden');
        current.classList.remove('hidden');
    });
}());
