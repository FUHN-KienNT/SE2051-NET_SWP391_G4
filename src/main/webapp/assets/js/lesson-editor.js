document.addEventListener('DOMContentLoaded', function () {
    const content = document.getElementById('content');
    if (!content || typeof Quill === 'undefined') return;

    const wrapper = document.getElementById('lessonEditorWrapper');
    const validation = document.getElementById('contentValidation');
    wrapper.classList.remove('hidden');
    const editor = new Quill('#lessonEditor', {
        theme: 'snow',
        formats: ['header', 'bold', 'italic', 'underline', 'list', 'blockquote', 'link'],
        modules: { toolbar: '#lessonToolbar' }
    });
    editor.root.setAttribute('role', 'textbox');
    editor.root.setAttribute('aria-multiline', 'true');
    editor.root.setAttribute('aria-required', 'true');
    editor.root.setAttribute('aria-labelledby', 'contentLabel');
    document.getElementById('contentLabel').htmlFor = 'lessonEditor';
    editor.setContents(editor.clipboard.convert({ html: content.value }));

    content.hidden = true;
    content.required = false;
    content.setCustomValidity('');
    validation.disabled = false;
    validation.dataset.error = content.dataset.error || '';
    let serverError = validation.dataset.error;
    const sync = () => {
        content.value = editor.getSemanticHTML();
        const hasText = editor.getText().replace(/[\s\u200B-\u200D\uFEFF]/g, '').length > 0;
        validation.setCustomValidity(serverError || (hasText ? '' : 'Please enter lesson content.'));
    };
    sync();
    editor.on('text-change', () => {
        serverError = '';
        validation.dataset.error = '';
        sync();
    });
    validation.addEventListener('invalid', () => editor.focus());
    content.form.addEventListener('submit', sync);
});
