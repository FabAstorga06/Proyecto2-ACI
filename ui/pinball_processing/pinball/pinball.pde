import processing.serial.*;
import processing.sound.*;

final int DISPLAY_DURATION = 300;
Serial _port;
int _numFrames = 19;
int _numFrames2 = 31;
PImage[] _images = new PImage[_numFrames], _images2 = new PImage[_numFrames2];
PImage _img, _x, _v;
PFont _font;
int _vidas, _puntaje;
SoundFile _file, _check, _uncheck, _loose;
String _path = "C:\\Users\\astor\\Desktop\\Pinball - Proyecto II\\pinball_processing\\pinball\\";
int _index = 0, _index2 = 0, _startTime;
boolean _decreaseLife  = false, _increaseLife = false;
boolean _play = true, _save = false, _click = false, flag_loose = false;
int[] _scores = new int[3];
int _width = 700, _height = 500;

void setup() {  
   //crea ventana
   size(700, 500);
   
   for (int i=0; i<_numFrames; i++) {
     _img = loadImage("images/img" + i + ".gif");
     _img.resize(_width, _height);
     _images[i] = _img;
   }
   for (int i=0; i<_numFrames2; i++) {
     _img = loadImage("images2/img" + i + ".gif");
     _img.resize(_width, _height);
     _images2[i] = _img;
   }   
   _x = loadImage("x.png");
   _x.resize(_width, _height);
   _v = loadImage("v.png");
   _v.resize(_width, _height);
   
   _file = new SoundFile(this, _path + "song2.mp3");
   
   _check = new SoundFile(this, _path + "v.MP3");
   _uncheck = new SoundFile(this, _path + "x.mp3");
   _loose = new SoundFile(this, _path + "loose.mp3");
   
   _font = loadFont("Unability-48.vlw"); 
   
   _scores[0] = 0;
   _scores[1] = 0;
   _scores[2] = 0;   
   
   // Abre el puerto específico
   _port = new Serial(this, "COM8", 9600);
 
   reset();
}
 
void draw() {
   
   if (_increaseLife) {
     background(_v);
     if (millis() - _startTime > DISPLAY_DURATION)
     {
        _increaseLife = false;
     } 
   } 
   else if (_decreaseLife) {
     background(_x);
     if (millis() - _startTime > DISPLAY_DURATION)
     {
        _decreaseLife = false;
     } 
   }
   else if (flag_loose) {
     showScreen3(); 
   } 
   else {
   
     if (_index == _numFrames) { 
     _index = 0; 
     } 
     background(_images[_index]);      
     initUserInterface();    
     _index += 1;  
   }      
   
   //Recibe datos del arduino       
   listenPort();
   
   delay(100);  
}

void listenPort() {
  if (_port.available() > 0) {
    int _data = _port.read();     
    print("dato recibido: ");
    println(_data);
    evaluate_data(_data);
      
  } 
  
}

void initUserInterface () {
  //Texto pinball
     textSize(100);
     fill(255, 255, 255);
     textFont(_font);
     text("PINBALL", 230, 80);
     
     //Texto para vidas
     textSize(20);
     textFont(_font);
     text("ATTEMPTS: " + _vidas, 10, 450);
     
     //Texto para puntajes
     textSize(20);
     textFont(_font);
     text("SCORE: " + _puntaje, 10, 380);
     
     stroke(0,0,0);
}

void evaluate_data(int pdata) {
  switch(pdata) {
  //Aumentar vidas
  case 0: 
    _vidas++;
    showScreen1();
    break;
    
  //Perder vidas / Perder la partida
  case 2: 
    if(looser() ) {
      flag_loose = true;
      _save = true;
      _play = true;
    } 
    else {
      _vidas--; 
      showScreen2();
    }
    break;
    
   //Reset
  case 3: 
    flag_loose = false;
    reset();
    break;
    
  //Aumentar puntaje
  default:
    _puntaje += pdata;
    showScreen1();
    break;
  }
}

void reset() {
  _vidas = 3;
  _puntaje = 0;
  _file.stop();
  _file.play();
}

void showScreen1() {
  _check.play();
  _increaseLife = true;
  _startTime = millis();
  
}


void showScreen2() {
  _uncheck.play();
  _decreaseLife = true;
  _startTime = millis();
  
}

void showScreen3() {    
    if(_save) { saveScore(); }
    if (_play ) { _loose.play(); }
    _file.stop();
    
    if (_index2 == _numFrames2) { 
     _index2 = 0; 
     } 
     background(_images2[_index2]);
     _index2 += 1;
    
    showScores();
    text("PRESS RESET BUTTON",20, 475);
    _play = false;
    _save = false;
}

void saveScore() {
  for (int i = 0; i < 3; i++) {
    if (_scores[i] < _puntaje) {
      if (i == 0) {
        int tmp = _scores[i+1];
        _scores[i+1] = _scores[i];
        _scores[i+2] = tmp;
      } else if (i == 1) {
        _scores[i+1] = _scores[i];
      }
      _scores[i] = _puntaje;
      break;
    }
  }
}

void showScores() {
  text("TOP SCORES", 30, 70);
  text("Best Score: " + _scores[0], 30, 200);
  text("Second Score: " + _scores[1], 30, 270);
  text("Third Score: " + _scores[2], 30, 340);
}

boolean looser() {
  if (_vidas == 0) return true;
  else return false;
}

void mouseClicked() {
  _click = true;
}

void clickAction(int act) {
  if (_click) {
     evaluate_data(act);
     _click = false;
   }
}