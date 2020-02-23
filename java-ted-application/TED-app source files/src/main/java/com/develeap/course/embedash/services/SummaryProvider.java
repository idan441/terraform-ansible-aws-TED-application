package com.develeap.course.embedash.services;

import com.develeap.course.embedash.beans.TEDRepo;
import com.develeap.course.embedash.beans.TedTalk;
import com.nmote.oembed.DefaultOEmbedProvider;
import com.nmote.oembed.OEmbed;
import com.nmote.oembed.OEmbedProvider;
import io.micrometer.core.instrument.Counter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import io.micrometer.core.instrument.MeterRegistry;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/api")
public class SummaryProvider {
    Logger logger = LoggerFactory.getLogger(SummaryProvider.class);
    private final MeterRegistry registry;
    private Counter numCallsToSummary;
    private Counter numThumbnailsPrepared;
    private Counter numAnswersFoundDuringSearch;
    private Counter numAnswersSuggested;

    public SummaryProvider(MeterRegistry registry) {
        this.registry = registry;
        this.numCallsToSummary = Counter.builder("tedsearch_summary_returned_total")
                .description("Counts times a summary was calculated")
                .register(this.registry);
        this.numThumbnailsPrepared = Counter.builder("tedsearch_thumbnail_returned_total")
                .description("Counts number of thumbnails prepared")
                .register(this.registry);
        this.numAnswersFoundDuringSearch = Counter.builder("tedsearch_answers_found_total")
                .description("Counts number of answers found by by search api")
                .register(this.registry);
        this.numAnswersSuggested = Counter.builder("tedsearch_answers_suggested_total")
                .description("Counts number of answers actually returned by by search api")
                .register(this.registry);
    }


    @Autowired
    TEDRepo tedRepo;

    @RequestMapping(value="/summary", method = RequestMethod.GET)
    @ResponseBody
    @Cacheable("oembed")
    public Map<String,String> suggest(@RequestParam("url") String url) throws IOException {
        Map<String,String> ret = new HashMap();
        ret.put("url",url);

        OEmbedProvider ep = new DefaultOEmbedProvider();
        OEmbed oEmbed = ep.resolve(url);

        ret.put("title",oEmbed.getTitle());
        if (oEmbed.getThumbnailUrl()!=null) {
            ret.put("thumbnail",oEmbed.getThumbnailUrl());
            numThumbnailsPrepared.increment();
        }
        ret.put("summary",oEmbed.getDescription()!=null ? oEmbed.getDescription() : "No Description");

        logger.info(String.format("%s fetched via oembed", url));
        numCallsToSummary.increment();

        return ret;
    }

    @RequestMapping(value = "/search", method = RequestMethod.GET)
    @ResponseBody
    public List<TedTalk> search(@RequestParam("q") String q) {
        logger.info("Search called with '"+q+"'");
        List<TedTalk> found = tedRepo.search(q);
        int numToRet = found.size()>8 ? 8 : found.size();
        List<TedTalk> ret = found.subList(0,numToRet);
        numAnswersFoundDuringSearch.increment( found.size());
        numAnswersSuggested.increment( numToRet);
        if (numToRet==0) {
            logger.warn("Failed to find anything");
        }
        return ret;
    }
}
