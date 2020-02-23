package com.develeap.course.embedash.beans;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.InputStream;
import java.util.*;

public class TEDRepo {
    Map<String,TedTalk> tedTalks = new HashMap<>();

    public TEDRepo() {
        for (int i=1;i<8;i++) loadTalksFromResource(i);
    }

    public String getText(Element el, String xmlNodeName) {
        return el.getElementsByTagName(xmlNodeName).item(0).getTextContent();
    }

    public void loadTalksFromResource(int num) {
        try {
            InputStream in = getClass().getResourceAsStream(String.format("/ted%d.xml", num));

            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
            Document doc = dBuilder.parse(in);
            NodeList nList = doc.getElementsByTagName("item");
            for (int i = 0; i < nList.getLength(); i++) {

                Element nNode = (Element) nList.item(i);
                String title = getText(nNode, "title");
                String[] titleParts = title.split(" \\| ");
                String author = titleParts[1];
                String subject = titleParts[0];
                String description = getText(nNode, "description");
                String link = getText(nNode, "link");

                tedTalks.put(subject, new TedTalk(author,subject,description,link));

            }
        } catch (Exception ignore) {
            ignore.printStackTrace();
        }
    }

    public List<TedTalk> search(String txt) {
        List<TedTalk> ret = new ArrayList<>();
        for (TedTalk t: tedTalks.values()) if (t.searchScore(txt)>1) ret.add(t);
        Comparator<TedTalk> comparator = new Comparator<TedTalk>() {
            @Override
            public int compare(TedTalk t1, TedTalk t2) {
                return t2.searchScore(txt) - t1.searchScore(txt);
            }
        };
        ret.sort(comparator);
        return ret;
    }


}
