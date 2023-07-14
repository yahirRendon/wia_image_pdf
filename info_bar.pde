/******************************************************************************
 *
 * class for creating an info text bar for user ui feedback
 *
 *****************************************************************************/
class InfoBar {
  int x, y;             // the x and y position of the info bar
  String infoBarText;   // the text to display in info bar
  double infoTimer;     // timer for info bar
  int infoTimerSpan;    // the length of time to display text (ms)

  /******************************************************************************
   * constructor
   * 
   * @param  _x    the x position of info bar
   * @param  _y    the y position of info bar
   *****************************************************************************/
  InfoBar(int _x, int _y) {
    x = _x;
    y = _y;
    infoBarText = "";
    infoTimerSpan = 1000;
    infoTimer = millis();
  }

  /******************************************************************************
   * 
   * check the timer to clear text after specified time
   * 
   *****************************************************************************/
  void checkTimer() {
    if (millis() > infoTimer + infoTimerSpan) {
      infoBarText = "";
    }
  }

  /******************************************************************************
   * 
   * update the info bar text
   * 
   *****************************************************************************/
  void update(String infoMessage) {
    infoBarText = infoMessage;
    infoTimer = millis();
  }

  /******************************************************************************
   * 
   * display timer
   * 
   *****************************************************************************/
  void display() {
    checkTimer();
    textSize(14);
    fill(0);
    textAlign(CENTER, CENTER);
    text(infoBarText, x, y);
  }
}
