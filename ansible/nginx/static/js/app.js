var sites=[];
timer = window.setTimeout(countWaits,4000);

$(document).ready(function(){
    $("#query").keypress(function (e) {
        if (e.which == 13) {
            q=$("#query").val();
            search(q);
            $("#query").val("");
            return false;
        }
    });
});

function search(q) {
    $.get({
        url:"/api/search?q="+encodeURIComponent(q),
        success: loadTitles
    });
}

function loadTitles(data) {
    var newHtml="";
    var i=0;
    for (it in data) {
        var item = data[it];
        i++;
        newHtml+="<div id='card"+i+"' class='card'>";
        newHtml+="<div class='title'>"+item.title+"</div>";
        newHtml+="<span>Loading... <span class='wait'>1</span></span>"
        newHtml += "</div>";
        (function (index) {
                $.get({
                    url:"/api/summary?url="+encodeURIComponent(item.link),
                    success: function(d) { fillCard("card"+index,d); }
                });
        })(i);
    }
    $("#cards").html(newHtml);
}

function fillCard(id,data) {
    var newHtml="";
    newHtml += "<span class='title'>" + data.title + "</span>";
    newHtml += "<div class='row'>"
    newHtml += "<span class='description'>" + data.summary + "</span>";
    if (data.thumbnail) {
        newHtml += "<span class='tncol'><img class='tn' src='" + data.thumbnail + "'/></span>"
    }
    newHtml += "</div>";

    $("#"+id).html(newHtml);
}

function getIndex(url) {
    for (site in sites) {
        if (sites[site].url==url) return site;
    }

    return -1;
}


// function updateSummary(data) {
//     var i = getIndex(data.url);
//     sites[i] = data;
//     refreshDisplay();
// }
//
// function refreshDisplay() {
//     var newHtml="";
//     for (site in sites) {
//         data=sites[site];
//         newHtml+="<div class='card'>";
//         if (data.wait) {
//             newHtml+="<span>Loading... <span class='wait'>"+data.wait+"</span></span>"
//         } else {
//             newHtml += "<span class='title'>" + data.title + "</span>";
//             newHtml += "<div class='row'>"
//             newHtml += "<span class='description'>" + data.summary + "</span>";
//             if (data.thumbnail) {
//                 newHtml += "<span class='tncol'><img class='tn' src='" + data.thumbnail + "'/></span>"
//             }
//             newHtml += "</div>";
//         }
//         newHtml += "</div>";
//     }
//     $("#cards").html(newHtml);
// }

function countWaits() {
    var waits = $(".wait");
    for (var w=0; w<waits.length;w++) {
        var t = $(waits[w]);
        var v = parseInt(t.text(),10)+1;
        t.text(v);
    }
    timer = window.setTimeout(countWaits,500);
}