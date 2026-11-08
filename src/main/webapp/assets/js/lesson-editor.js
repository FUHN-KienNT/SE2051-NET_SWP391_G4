document.addEventListener('DOMContentLoaded', function () {
    const content = document.getElementById('content');
    if (!content) return;
    const type = document.getElementById('lessonType');
    const required = () => !type || type.value === 'content';
    if (typeof Quill === 'undefined') return;

    const wrapper = document.getElementById('lessonEditorWrapper');
    wrapper.classList.remove('hidden');
    const editor = new Quill('#lessonEditor', {
        theme: 'snow',
        formats: ['header', 'bold', 'italic', 'underline', 'list', 'blockquote', 'link'],
        modules: { toolbar: '#lessonToolbar' }
    });
    editor.root.setAttribute('role', 'textbox');
    editor.root.setAttribute('aria-multiline', 'true');
    editor.root.setAttribute('aria-describedby', content.getAttribute('aria-describedby'));
    editor.root.setAttribute('aria-invalid', content.getAttribute('aria-invalid'));
    editor.root.setAttribute('aria-labelledby', 'contentLabel');
    document.getElementById('contentLabel').htmlFor = 'lessonEditor';
    editor.setContents(editor.clipboard.convert({ html: content.value }));

    content.hidden = true;
    content.required = false;
    const syncContent = () => {
        content.value = editor.getSemanticHTML();
    };
    const syncRequired = () => editor.root.setAttribute('aria-required', String(required()));
    syncRequired();
    editor.on('text-change', syncContent);
    content.form.addEventListener('submit', syncContent);
    content.addEventListener('lesson-type-change', syncRequired);
});
