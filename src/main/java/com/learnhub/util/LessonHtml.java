package com.learnhub.util;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.safety.Safelist;

/** Shared HTML policy for lesson authoring, review, and student reading. */
public final class LessonHtml {
    private static final Safelist ALLOWED = Safelist.basic()
            .addTags("h1", "h2", "h3", "h4", "h5", "h6", "s", "hr",
                    "table", "thead", "tbody", "tr", "th", "td")
            .removeProtocols("a", "href", "ftp")
            .addEnforcedAttribute("a", "rel", "nofollow noopener noreferrer");

    private LessonHtml() {}

    public static String sanitize(String html) {
        if (html == null || html.isEmpty()) return "";
        Document document = Jsoup.parseBodyFragment(html);
        document.outputSettings().prettyPrint(false);
        // Preserve line breaks in legacy plain-text lessons.
        if (document.body().children().isEmpty()) {
            document.body().html(document.body().html().replace("\r\n", "\n")
                    .replace("\r", "\n").replace("\n", "<br>"));
        }
        return Jsoup.clean(document.body().html(), "", ALLOWED,
                new Document.OutputSettings().prettyPrint(false));
    }

    public static boolean hasText(String html) {
        String text = Jsoup.parseBodyFragment(sanitize(html)).text();
        return text.codePoints().anyMatch(c -> !Character.isWhitespace(c)
                && !Character.isSpaceChar(c) && Character.getType(c) != Character.FORMAT);
    }
}
