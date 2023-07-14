/******************************************************************************
 * 
 * simple program used at work to process images of forms sent by clients
 * via text. They often need to be cleaned up and converted to PDFs. 
 * flattening an image to black and white
 * threshold filter to push values to white or black
 * export as new image or pdf 
 *
 * author: yahir 
 * https://processing.org/reference/libraries/pdf/index.html
 *****************************************************************************/
import processing.pdf.*;

PFont font;                       // the font used by the sketch
PImage icon;                      // image for app icon
PImage img;                       // the image to be adjusted (full size)
PImage imgCopy;                   // the preview image shown in window
String userDownloads;             // path to users download folder
String imgName;                   // the original image name

int previewWidth;                 // width of the preview area
int previewHeight;                // height of the preview ara

float thresholdSensativity;       // the amount of threshold filter applied (0.0 - 1.0)
float scale;                      // the difference between preview display and original image
int brushSize;                    // size for white out brush (20 default)
String previewFeedback;           // text feedback to user in the preview area

String[] imgTypes;                // list of allowed image extensions
boolean imageLoaded;              // track if an image was loaded for processing

// icons for ui (default and active versions)
PImage iconImg, iconImgActive;      
PImage iconPDF, iconPDFActive;
PImage iconSelect, iconSelectActive;

// ui buttons
Button btnSaveImg;
Button btnSavePDF;
Button btnSelect;

// the ui feedback info bar
InfoBar infobar;                  

// color palette
color darkRed;
color lightGreen;

/******************************************************************************
 * 
 * setup method
 * 
 *****************************************************************************/
void setup() {
  size(850, 850);
  surface.setTitle("WIA Image Cleaner");
  icon = loadImage("wrench.png");
  surface.setIcon(icon);

  font = createFont("Poppins-Light.ttf", 32);
  textFont(font);
  
  darkRed = color(107, 31, 49);
  lightGreen = color(236, 240, 218);
  previewWidth = 638;
  previewHeight = 825;
  brushSize = 20;
  imageLoaded = false;
  thresholdSensativity = 0.5;
  
  imgTypes = new String[]{"jpg", "JPG", "jpeg", "JPEG", "png", "PNG"};
  previewFeedback = "awaiting image selection... ";
  

  String userRoot = System.getProperty("user.home");
  userRoot = userRoot.replace("\\", "/");
  userDownloads = userRoot + "/Downloads/";
  
  iconImg = loadImage("icon-img.png");
  iconImgActive = loadImage("icon-img-white.png");
  btnSaveImg = new Button(750, 250, iconImg, iconImgActive);
  
  iconPDF = loadImage("icon-pdf.png");
  iconPDFActive = loadImage("icon-pdf-white.png");
  btnSavePDF = new Button(750, 400, iconPDF, iconPDFActive);
  
  iconSelect = loadImage("icon-select.png");
  iconSelectActive = loadImage("icon-select-white.png");
  btnSelect = new Button(750, 550, iconSelect, iconSelectActive);
  
  infobar = new InfoBar(750, 750);
  
  // prompt user to select a file through dialog box
  File file = new File(userDownloads + "select a file...");
  selectInput("Select a file to process:", "fileSelected", file);
}

/******************************************************************************
 * 
 * draw method
 * 
 *****************************************************************************/
void draw() {
  background(240);


  // display copy image as preview or inform user of status
  if (imageLoaded) {

    PGraphics pg = createGraphics(previewWidth, previewHeight);
    pg.beginDraw();
    pg.background(255);
    pg.image(imgCopy, 0, 0);
    pg.filter(THRESHOLD, thresholdSensativity);
    pg.endDraw();

    image(pg, 10, 10);
    //filter(THRESHOLD, thresholdSensativity);
  } else {
    noStroke();
    fill(255);
    rect(10, 10, previewWidth, previewHeight);
    fill(0);
    textAlign(CENTER);
    textSize(24);
    text(previewFeedback, previewWidth/2 + 10, height/2);
  }
  
 
  
  btnSaveImg.display();
  if(btnSaveImg.active()) {
    infobar.update("save as image");
  }
  if(btnSaveImg.on) {
   btnSaveImg.on = false;
   infobar.update("saved!");
   outputAsImage();
  }
  
  btnSavePDF.display();
  if(btnSavePDF.active()) {
    infobar.update("save as pdf");
  }
  if(btnSavePDF.on) {
   btnSavePDF.on = false;
   infobar.update("saved!");
   outputAsPDF();
  }
 
 btnSelect.display();
 if(btnSelect.active()) {
    infobar.update("select new file");
  }
  if(btnSelect.on) {
   btnSelect.on = false;
   resetImage();
  }
  
  infobar.display();
}


/******************************************************************************
 * 
 * mouse dragged
 *
 * LEFT    | adjust threshold sensativity
 * RIGHT   | use white out brush
 *****************************************************************************/
void mouseDragged() {
  if (mouseButton == LEFT) {
    if(mouseX >= 10 && mouseX <= previewWidth + 10) {
      thresholdSensativity = map(mouseX, 10, previewWidth + 10, 0, 1.0);
      infobar.update("threshold: " + String.format("%.2f", thresholdSensativity));
    }
  }
  if (mouseButton == RIGHT) {

    // white out for preview window
    for (int y = mouseY - brushSize; y <mouseY + brushSize; y++) {
      for (int x = mouseX - brushSize; x < mouseX + brushSize; x++) {
        float distance = dist(x, y, mouseX, mouseY);

        if ( distance < brushSize) {
          //&& x >= 0 && x < imgCopy.width &&
          //    y >= 0 && y < imgCopy.height) {
          imgCopy.set(x, y, color(255));
        }
      }
    }

    // white out for original image
    int brushSizeAdj = int(brushSize / scale);
    int mousex = int(mouseX / scale);
    int mousey = int(mouseY / scale);

    for (int y = mousey - brushSizeAdj; y < mousey + brushSizeAdj; y++) {
      for (int x = mousex - brushSizeAdj; x < mousex + brushSizeAdj; x++) {

        float distance = dist(x, y, mousex, mousey);
        if ( distance < brushSizeAdj ) {
          //&& x >= 0 && x < img.width &&
          //    y >= 0 && y < img.height) {
          img.set(x, y, color(255));
        }
      }
    }
  }
}

/******************************************************************************
 * 
 * mouse pressed
 * 
 * LEFT | update ui buttons
 *****************************************************************************/
void mousePressed() {
  if (mouseButton == LEFT) {
    btnSaveImg.update();
    btnSavePDF.update();
    btnSelect.update();
  }
}

/******************************************************************************
 * 
 * key pressed
 *
 * s or S | export as PNG with adjustments
 * p or P | export as PDF with adjustments
 * r or R | reset image selection
 *****************************************************************************/
void keyPressed() {
  if (key == 's' || key == 'S') {
    outputAsImage();
  }
  if (key == 'p' || key == 'P') {
    outputAsPDF();
  }
  if (key =='r' || key =='R') {
    resetImage();
  }
}

/******************************************************************************
 * function for resizing an image to fit within 
 * canvas width and height while preseving ratio
 *
 * @param  w    the original image width
 * @param  h    the original image height
 * @return int[]  array with new [0]width and [0]height
 *****************************************************************************/
int[] resizeDimensions(float w, float h) {
  int[] dimensions = new int[2];
  float difW = abs(previewWidth - w);
  float difH = abs(previewHeight - h);

  if (difW > difH) {
    scale = previewWidth/w;
    dimensions[0] = previewWidth;
    dimensions[1] = int(h * scale);
  } else {
    scale = previewHeight/h;
    dimensions[0] = int(w * scale);
    dimensions[1] = previewHeight;
  }
  return dimensions;
}

/******************************************************************************
 * 
 * check if mouse is within the preview area
 * 
 * @return    true when mouse hover within preview area
 *****************************************************************************/
boolean previewActive() {
 if(mouseX > 10 && mouseX <= previewWidth + 10 &&
 mouseY > 10 && mouseY <= previewHeight + 10) {
   return true;
 } else {
   return false;
 }
}

/******************************************************************************
 * 
 * set the text feedback to user within the preview area
 * 
 *****************************************************************************/
void setPreviewFeedback(String msg) {
  previewFeedback = msg;
}

/******************************************************************************
 * 
 * run to trigger new image selection to process
 *****************************************************************************/
void resetImage() {
  imageLoaded = false;
  thresholdSensativity = 0.5;
  
  // prompt user to select a file through dialog box
  File file = new File(userDownloads + "select a file...");
  selectInput("Select a file to process:", "fileSelected", file);
}

/******************************************************************************
 * 
 * process file selection from user
 * 
 *****************************************************************************/
void fileSelected(File selection) {
  // check if not null and also extension type is within the allowed type list
  if (selection != null) {
    boolean acceptedType = false;
    String extension = selection.getName().substring( selection.getName().lastIndexOf(".") + 1);

    for (int i = 0; i < imgTypes.length; i++) {
      if (extension.equals(imgTypes[i])) {
        acceptedType = true;
        break;
      }
    }
    
    // load if appropriate
    if (acceptedType) {
      // try to load selected file
      img = loadImage(selection.getAbsolutePath());
      imgCopy = loadImage(selection.getAbsolutePath());

      // set dimensiosn for preview image
      int[] copyDimensions = resizeDimensions(imgCopy.width, imgCopy.height);
      imgCopy.resize(copyDimensions[0], copyDimensions[1]); 

      // get image name 
      imgName = selection.getName().substring(0, selection.getName().lastIndexOf("."));
      imageLoaded = true;
    } else {
      setPreviewFeedback("Not able to load\nfile type: " + extension);
    }
  }
}

 /******************************************************************************
 * 
 * function for creating an output jpg based
 * on adjustments from preview image
 * 
 *****************************************************************************/
void outputAsImage() {
  //println("saving img...");
  PGraphics pg = createGraphics(img.width, img.height);
  pg.beginDraw();
  pg.background(255);
  pg.image(img, 0, 0);
  pg.filter(THRESHOLD, thresholdSensativity);
  pg.save(userDownloads + imgName + "-filtered.jpg");
  pg.endDraw();
  //println("saved:", userDownloads + imgName + "-cleaned.jpg");
}

 /******************************************************************************
 * 
 * function for creating an output pdf based
 * on adjustments to preview image 
 * 
 *****************************************************************************/
void outputAsPDF() {
  //println("saving pdf...");
  // create image
  PGraphics pg = createGraphics(img.width, img.height);
  pg.beginDraw();
  pg.background(255);
  pg.image(img, 0, 0);
  pg.filter(THRESHOLD, thresholdSensativity);
  pg.endDraw();

  PGraphics pdf = createGraphics(img.width, img.height, PDF, userDownloads + imgName + "-cleaned.pdf");
  pdf.beginDraw();
  pdf.background(255);
  pdf.image(pg, 0, 0);
  pdf.dispose();
  pdf.endDraw();
  //println("saved:", userDownloads + imgName + "-cleaned.pdf");
}
