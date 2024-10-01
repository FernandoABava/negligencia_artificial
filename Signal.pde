class Signal {
  float rawValue;
  float value;
  float pValue;
  float normValue;
  float maxValue = 1;
  float smooth;
  
  float total;
  long frames;
  float average;
  
  float contraste; // NO ME ACUERDO EL NOMBRE MATEMATICO DE ESTO
  float sContraste;
  
  int pos =0 ;
  
  Signal(float s) {
    smooth = s;
  }
  
  void update(float s) {
    rawValue = s;
    pValue = value;
    value = lerp(value, s, smooth);
    
    maxValue *= 0.999;
    maxValue = value > maxValue ? value : maxValue;
    // maxValue = maxValue > 12000 ? 12000 : maxValue;
    
    if(s != 0) {
      total += s;
      frames ++;
      average = total/frames;
    }
    
    contraste = abs(value - pValue);
    sContraste = lerp(sContraste, contraste, smooth);
    
    normValue = value/maxValue;
  }
  
  void testUpdate(float s) {
    rawValue = s;
    pValue = value;
    value = lerp(s, value, smooth);
    
    maxValue = value > maxValue ? value : maxValue;    
    
    if(s != 0) {
      total += s;
      frames ++;
      average = total/frames;
    }
    
    contraste = abs(value - pValue);
    sContraste = lerp(sContraste, contraste, smooth);
    
    normValue = value/maxValue;
  }
  
  void draw(float base, float amp) {
    pushMatrix();
    pos ++;
    
    translate(0, base);
    if(pos > width) {
      background(255);
      resetMatrix();
      pos = 0;
    }
    strokeWeight(1);
    stroke(255, 0, 0);
    
    line(
      (frames%width) - 1, normValue * amp, 
      (frames%width) - 2, pValue / maxValue * amp
    );
    
    strokeWeight(2);
    
    stroke(0, 255, 0);
    point((frames%width) - 1, average / maxValue * amp);
    
    stroke(0, 0, 255);
    point((frames%width) - 1, rawValue / maxValue * amp);
    popMatrix();
    
    
  }
  
  
}
