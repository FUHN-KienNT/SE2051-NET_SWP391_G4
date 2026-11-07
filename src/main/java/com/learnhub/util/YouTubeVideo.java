package com.learnhub.util;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Set;

/** Parses YouTube links without accepting arbitrary iframe URLs or HTML. */
public final class YouTubeVideo {
    private YouTubeVideo() {}

    public static String videoId(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            URI uri = URI.create(value.strip());
            if (!Set.of("https", "http").contains(uri.getScheme())
                    || uri.getUserInfo() != null || uri.getPort() != -1) return null;
            String host = uri.getHost();
            if (host == null) return null;
            host = host.toLowerCase(java.util.Locale.ROOT);
            String path = uri.getPath();
            String id = null;
            if ("youtu.be".equals(host)) {
                id = path.substring(1);
            } else if (Set.of("youtube.com", "www.youtube.com", "m.youtube.com",
                    "youtube-nocookie.com", "www.youtube-nocookie.com").contains(host)) {
                if ("/watch".equals(path) && uri.getRawQuery() != null) {
                    for (String part : uri.getRawQuery().split("&")) {
                        if (part.startsWith("v=")) id = URLDecoder.decode(part.substring(2), StandardCharsets.UTF_8);
                    }
                } else if (path.startsWith("/embed/") || path.startsWith("/shorts/") || path.startsWith("/live/")) {
                    id = path.substring(path.lastIndexOf('/') + 1);
                }
            }
            return id != null && id.matches("[A-Za-z0-9_-]{11}") ? id : null;
        } catch (IllegalArgumentException | IndexOutOfBoundsException e) {
            return null;
        }
    }

    public static String embedUrl(String value) {
        String id = videoId(value);
        return id == null ? null : "https://www.youtube-nocookie.com/embed/" + id
                + "?autoplay=1&mute=1&playsinline=1&rel=0";
    }
}
