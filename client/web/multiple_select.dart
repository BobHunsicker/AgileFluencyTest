part of test;

/**
 * a multiple select question
 */
class MultipleSelect extends Question{
  /**
   * the selectable answers for this question
   */
  List<Answer> answers = new List<Answer>();
  
  /**
   * the answer selected by the test taker
   */
  List<Answer> selected;
  
  /**
   * constructor
   */
  MultipleSelect(text){
    this.text = text;
  }
  
  /**
   * Get the greatest number of points it is possible to receive on this question
   */
  List<Answer> getAgileAnswers() {
    List<Answer> answers;
    for (var iterator in this.answers) {
      if (iterator.points > 0)
        answers.add(iterator);
    }
    return answers;
  }
  
  /**
   * Get the question displayed in html.
   */
  String display()
  {
    var output = new StringBuffer();
    output.add("<p>");
    output.add(this.text);
    output.add("</p>");
    for (var iterator in this.answers)
    {
      output.add("<input type=\"checkbox\" name=\"group1\"");
      output.add(iterator.text);
      output.add(">");
      output.add(iterator.text);
      output.add("<br/>");
    }
    output.add("<br/>");
    output.add("<input type=\"button\" value=\"Submit\">");
    
    return output.toString();
  }
}