/******************************************************************************
 *
 * class for creating a ui button
 *
 *****************************************************************************/
class Button {
  int x, y;                  // the x and y position of button
  int w;                     // the width or size of button (square)
  boolean on;                // track the state of button (clicked or engaged)
  int iconx, icony;          // the x and y position for the icon images
  int iconSize;              // the icon size
  PImage icon, iconActive;   // the default and active icon image objects
  int padding;               // the padding around the icons
  double btnTimer;           // timer for info bar
  int btnTimerSpan;          // the length of time to display text (ms)
  
   /******************************************************************************
   * constructor
   * 
   * @param  _x          the x position of button (center)
   * @param  _y          the y position of button (center)
   * @param _icon        the default icon image
   * @param _iconActive  the icone image when active
   *****************************************************************************/
  Button(int _x , int _y, PImage _icon, PImage _iconActive) {
    iconSize = 50;
    icon = _icon;
    iconActive = _iconActive;
    icon.resize(50, 50);
    iconActive.resize(iconSize, iconSize);
    
    // calc x and y for button and icons
    padding = 10;
    w = iconSize + padding;
    x = _x - w/2;
    y = _y - w/2;
    iconx = (x  + (w/2)) - (icon.width/2);
    icony = (y + (w/2)) - (icon.height/2);
    
    on = false;
    btnTimerSpan = 2000;
    btnTimer = millis();
  }
  
  /******************************************************************************
   * 
   * display button basic
   * 
   *****************************************************************************/
   void display() {
    noFill();
    if(active()) fill(darkRed);
    stroke(darkRed);
    rect(x, y, w, w, 10);
    
    if(active()) {
      image(iconActive, iconx, icony);
    } else {
    image(icon, iconx, icony);
    }
  }
  
  /******************************************************************************
   * 
   * toggle on state
   * 
   *****************************************************************************/
  void update() {
    if (active()) {
      on = !on;
      
      if(on) {
        btnTimer = millis();
      }
    }
  }
  
  /******************************************************************************
   * 
   * track active state
   * 
   * @return      true if mouse is within button
   *****************************************************************************/
  boolean active() {
    if(mouseX > x && mouseX < x + w &&
       mouseY > y && mouseY < y + w &&
       millis() > btnTimer + btnTimerSpan) {
         return true;
       } else {
         return false;
       }
  }
}
