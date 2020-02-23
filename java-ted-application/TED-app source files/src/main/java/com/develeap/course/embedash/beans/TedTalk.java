package com.develeap.course.embedash.beans;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class TedTalk {
    private final String author;
    private final String title;
    private final String description;
    private final String link;
    private final String lctitle;
    private static Set<String> worthless = new HashSet<>();

    static {
        worthless.addAll(Arrays.asList("the","in","on","of","this","to","as","a","how"));
    }


    public TedTalk(String author, String title, String description, String link) {
        this.author = author.toLowerCase();
        this.title = title;
        this.lctitle = title.toLowerCase();
        this.description = description.toLowerCase();
        this.link = link;
    }

    public String getAuthor() {
        return author;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getLink() {
        return link;
    }

    private int has(String txt,String subtxt,int score) {
        if (txt.indexOf(subtxt)>-1) return score;
        return 0;
    }


    public int searchScore(String stxt) {
        String txt = stxt.toLowerCase();
        String[] terms = txt.split(" ");
        int ret = 0;
        for (String t : terms) {
            if (!worthless.contains(t)) {
                ret += has(lctitle,t,2) + has(description,t,1);
            }
        }
        return has(lctitle,txt,20) + has(description,txt,10) + has(author,txt,20) + ret;
    }


}
