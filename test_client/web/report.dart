import 'dart:html';
import 'dart:json';
import 'dart:math';
import "../lib/test.dart";
import "package:presentation/presentation.dart";

// Server Info :
String _serverAddress = "172.16.4.27";
String _serverPort = "8083";

// powers 3d transitions
SlideShow slideshow = new BasicSlideShow(query("#viewBox"));

// slide placement settings
num currentSlidePosition = 0;

// camera default settings
num camTransDuration = 1;
num camX = 1330;
num camY = 400;
num camZ = 50000;
num camXr = 0;
num camYr = 0;
num camZr = 0;

/**
 *  Method  : addBackground
 *
 *  Purpose : This method creates the background slide, and adds it to the presentation
 *            object. This method does not have inputs or outputs.
 */
void addBackground()
{
  var element = new ImageElement();
  element.src = "images/world_8bit.png";
  var slide = new Slide(element, 50.0, 0 , 0, 0, 0, 0);
  slideshow.addBackgroundSlide(slide);
  //no transitions because this slide is never focused / transitioned to.
}

/**
 *  Method  : getUriParams
 *
 *  Purpose : This method gets information from the URI parameter (../report.dart?id=HEX).
 *            This method receives a string, and returns a mapping with the id.
 */
Map<String, String> getUriParams(String uriSearch) {
  if (uriSearch != '') {
    final List<String> paramValuePairs = uriSearch.substring(1).split('&');

    var paramMapping = new HashMap<String, String>();
    paramValuePairs.forEach((e) {
      if (e.contains('=')) {
        final paramValue = e.split('=');
        paramMapping[paramValue[0]] = paramValue[1];
      } else {
        paramMapping[e] = '';
      }
    });
    return paramMapping;
  }
}

/**
 *  Method  : lookAtMap
 *
 *  Purpose : This method is a wrapper for the camera move method. It sets the default
 *            camera positions as arguments. This method does not have inputs or outputs.
 */
void lookAtMap()
{
  slideshow.cam.move(camTransDuration, camX, camY, camZ, camXr, camYr, camZr);
}

/**
 *  Method  : displayResults
 *
 *  Purpose : This method adds content to the presentation viewbox. It calls
 *            addBackground, lookAtMap, and addSummary. This method receives
 *            jsonResults, and does not have outputs.
 */
void displayResults(jsonResults)
{
  var viewBox = query("#viewBox");
  viewBox.style.transition = "0.5";

  viewBox.style.backgroundImage = "none";
  viewBox.innerHTML = "";

  addBackground();
  lookAtMap();

  window.setTimeout(()
  {
    //add map and first slide
    addSummary(jsonResults);
  }, 1500);
}

/**
 *  Method  : addSlideToMap
 *
 *  Purpose : This method adds a slide to the presentation, and places it along
 *            a sin curve. The method receives an Element, and returns a Slide.
 */
Slide addSlideToMap(Element slideContents)
{
  // use a sin wave and scale it to look like a global journey
  num slidePositionXScale = 2000;
  num slidePositionYScale = 10000;
  num waveScale = 2.0;
  num waveShift = -3.0;
  var x = currentSlidePosition * slidePositionXScale;
  var y = sin(currentSlidePosition / waveScale + waveShift) * slidePositionYScale;
  return slideshow.addElementSlide(slideContents, 1.0, x, y, 0, 0, 0, 0);
}

/**
 *  Method  : getStamp
 *
 *  Purpose : This method creates a stampContainer element for presentation.
 *            It receives the stamp number, placed flag, and date string. The
 *            method returns a DivElement.
 */
Element getStamp(int number, bool placed, String theDate)
{
  var stampContainer = new DivElement();
  var dateTxt = new DivElement();
  var stamp = new ImageElement();

  stampContainer.classes.add("stampContainer");

  dateTxt.classes.add("dateStamp");
  dateTxt.innerHTML = theDate;
  dateTxt.style.zIndex = "1";
  dateTxt.id = "dateStamp$number";

  stamp.classes.add("passportStamp");
  stamp.src = "images/stamp_$number.png";

  stamp.id = "stamp${number}Img";

  if(!placed)
  {
    stampContainer.id = "stamp${number}Hidden";

    window.setTimeout(()
      {
      stampContainer.id = "stamp${number}Show";
      }, 1500);
  }
  else
  {
    stampContainer.id = "stamp${number}Show";
  }
  stampContainer.style.width = "250px";
  stampContainer.insertAdjacentElement("beforeEnd", dateTxt);
  stampContainer.insertAdjacentElement("beforeEnd", stamp);

  return stampContainer;
}

String stripNameHtml(String theName)
{
  int startIdx = theName.indexOf("<name>") + 6;
  int endIdx = theName.indexOf("</name>");

  return theName.substring(startIdx, endIdx);
}

/**
 *  Method  : addSummary
 *
 *  Purpose : This method creates a summary slide, and adds it to the presentation map.
 *            This method receives jsonResults, and does not have outputs.
 */
void addSummary(jsonResults)
{
  /// Summary for each completed section: stamp and progress.
  //content for the right side
  var output = new DivElement();

  var stampsDiv = new DivElement();

  stampsDiv.id = "stampsDiv";
  stampsDiv.classes.add("stampsDiv");

  //stamp image placeholder. The plan will be to zoom into this, to show the summary information.

  //use section parameter from testResults
  output.id = "report";
  output.classes.add("summary");

  //passport image as a backdrop
  var passport = new ImageElement();
  passport.classes.add("passportImage");
  //TODO: add logic to use the correct passport (with animation).
  passport.src = "images/passport_m.png";
  passport.style.zIndex = "-10";
  output.insertAdjacentElement("beforeEnd", passport);

  var passportBottomLeftDiv = new DivElement();
  passportBottomLeftDiv.id = "passportBottomLeftDiv";
  passportBottomLeftDiv.classes.add("passportBottomLeftDiv");

  output.insertAdjacentElement("beforeEnd", passportBottomLeftDiv);

  passportBottomLeftDiv.appendHtml("Results from an <b>Agile Fluency Assessment</b>.<br /><br />Read more about it at <a href='http://labs.catalystsolves.com/?q=AgileFluency'>our blog</a>.");


  var passportBottomRightDiv = new DivElement();
  passportBottomRightDiv.id = "passportBottomRightDiv";
  passportBottomRightDiv.classes.add("passportBottomRightDiv");

  output.insertAdjacentElement("beforeEnd", passportBottomRightDiv);

  output.insertAdjacentElement("beforeEnd", stampsDiv);

  //content for the right side
  var content = new ParagraphElement();
  content.classes.add("detail");

  var theDate = jsonResults['date'];

  content.appendHtml("<h4>Date of assessment: $theDate</h4><br />");

  var sectionList = jsonResults['stampList'];

  for (var i=0; i<sectionList.length; i++)
  {
    var Fluency = sectionList[i]['fluency'];
    var TotalAgile = sectionList[i]['totalAgile'];
    var MostAgile = sectionList[i]['mostAgile'];
    var Section = sectionList[i]['section'];

    content.appendHtml("<h4>${stripNameHtml(sectionList[i]['name'])} : $Fluency%</h4>");

    //Progress information...
    content.appendHtml("<li>Total Agile Answers: $TotalAgile</li>");

    content.appendHtml("<li>Most Fluent Answers: $MostAgile</li></ul>");

    if (i != (sectionList.length - 1))
    {
      content.appendHtml("<hr />");
    }
  }

  output.insertAdjacentElement("beforeEnd", content);

  for(var i=0; i<sectionList.length; i++)
  {
    int fluencyInt = parseInt(sectionList[i]['fluency']);
    int sectionInt = sectionList[i]['section'];

    if (fluencyInt > 70)
    {
      // stamp is not place...set id to unplaced, then use callback function to switch it to placed
      Element stamp = getStamp(sectionInt, false, theDate);
      stampsDiv.insertAdjacentElement("beforeEnd", stamp);
      // set the stamp to placed...no animation needed
      stamp = getStamp(sectionInt, true, theDate);
    }
  }

  var slideElement = query("#summary");
  var slide = slideshow.addElementSlide(output, 1.0, 0, 0, 2000, 0, 0, 0);

  // set camera at splash slide and script start button
  slideshow.cam.lookAtSlide(slide, 2);
  // sets splash as the current slide and gives it focus
  slideshow.start();
}

/**
 *  Method  : getIdFromUri
 *
 *  Purpose : This method retrieves the Uri, and parses for the id parameter. This method does not have
 *            inputs, and returns the id as a string.
 */
String getIdFromUri()
{
  var uriSearch = window.location.search;
  Map paramMapping = getUriParams(uriSearch);

  if (paramMapping == null)
    return null;

  String hexString = paramMapping['id'];

  return hexString;
}

/**
 *  Method  : main
 *
 *  Purpose : This method sends request information to the server application. When successful, it will
 *            be presented on a slide. This method does not have inputs or outputs.
 */
void main()
{
  var hexstring = getIdFromUri();

  print("hexstring : $hexstring");

  if (hexstring != null)
  {
    //query the server application for the results
    HttpRequest req = new HttpRequest();

    req.on.load.add((Event e) {
        var responseText = req.responseText;
        var jsonObj = JSON.parse(req.responseText);
        displayResults(jsonObj);
      }
    );

    req.on.error.add((Event e) {
        print("Error!");
      }
    );

    req.open("GET", "http://$_serverAddress:$_serverPort/results?id=$hexstring");
    req.send();
  }
}
