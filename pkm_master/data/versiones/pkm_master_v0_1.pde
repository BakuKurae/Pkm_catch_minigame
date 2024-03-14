PImage lvl, lvl_get, SMinM, MinM, bg, TileM, STileM, c, d, e, e_off, extra, catchB, catchB_off; //c -> pkm; d -> pkball count; e -> button //<>//
PImage[] minImage= new PImage[15];
int xRate, yRate, bttn_state, catch_state, countPKB=144, captura, gotcha = 5;//gotcha es el numero modifica el porcentaje de captura[0-todos se captura/ 10-todo se escapa]
int past_xRate, past_yRate, minX=11, indice_captura, stock_field; //minX->posicion inicial de impresion de miniaturas, indice de captura->indice de busqueda de miniaturas por pkmn capturado
int[] stock = new int[15]; //variable para el seguimiento del almacen
int[] shinyStock = new int[15];//referencia para saber si existe algun shiny almacenado
String[][] name = new String[17][11]; //matriz similar a los pokemon para reusar las coord y asi ubicar los nombres
PFont font, font1;

int R, C, coord, cont_captura;
boolean rectOver = false, circleOver = false; //funciones para deteccion de botones

int textCheck = 0;
int Shiny, Shiny_state;
int animation; //variables de referencia para usar como frames
int money = 50; //cantidad incial de dinero para mantener las pokeball en stock
String money_char = str(money);

void shiny() {
  if (Shiny >= 1 && Shiny < 21) {//generacion de shinys (10% de probabilidad de aparicion)
    fill(225, 211, 69);
    Shiny_state = 1;
  } else {
    fill(0);
    Shiny_state = 0;
  }
}

void scenario() {
  image(bg, 0, 0, 1024, 640); //impresion del fondo sobre el atlas
  image(d, 15, 15); //pkball counter
  image(c, 225, 287); //impresion del pokemon
  image(lvl_get, 419, 19); //impresion de contador de captura
}

void setup() {
  size(1024, 640);
  //Alamcenar nombres en forma de matriz
  String[] lines = loadStrings("pkmlist.txt");
  R= 1;//rows
  C= 1;//columns
  for (int i = 1; i < lines.length; i++) { //asignacion de nombres a la matriz desde el archivo txt
    //println(lines[i], " ", C, R, i); //coordX, coordY, pkmn Number
    name[C][R] = lines[i];
    C++;
    if (C > 16) {//cada fila tiene un numero maximo de 16 pkm, despues de los 16 hay un salto de renglon
      C= 1;
      R++;
    }
  }


  //Cargar imagenes---
  bg = loadImage("bg.png");
  lvl = loadImage("lvl.png");
  MinM = loadImage("miniatura-pkm.png");
  SMinM = loadImage("miniatura-shiny-pkm.png");
  TileM = loadImage("Pokemon-asset.png");
  STileM = loadImage("Pokemon-asset-shiny.png");
  extra = loadImage("extraAsset.png"); 
  //------------------

  //preconfiguracion del texto
  font = createFont("jupiterc.ttf", 12);//alphbeta.ttf
  font1 = createFont("ORANGEKI.TTF", 12);
  textAlign(CENTER, CENTER);

  image(MinM, 0, 0);
  for (int i=0; i<=14; i++) { //asignacion de imagenes por defecto al array de miniaturas "?"
    minImage[i]=get(224, 288, 32, 32);
  }

  image(extra, 0, 0);
  d = get(countPKB, 0, 72, 24); //determina el frame inicial del contador de pokeballs

  Shiny = round(random(199))+1; //calculo de posibilidad de shiny
  xRate = round(random(15))+1;//Generacion de la coord aleatoria en X

  if (xRate >= 8) {//coord Y en respuesta de X
    yRate = round(random(8))+1;
  } else {
    yRate = round(random(9))+1;
  }

  shiny();

  cont_captura=0;
  pickOne(xRate, yRate);//recorte de atlas pokemon
  Picklvl(cont_captura);//selecciona la cantidad de capturados
  //---- Imprime la imagen de los assets que comprenden los botones y el indicador de pkballs
  image(extra, 0, 0);
  e_off = get(0, 0, 72, 24);//boton compra activo
  e = get(72, 0, 72, 24);//boton compra inactivo
  //---- Imprime la imagen de los assets que comprenden los botones de captura
  image(TileM, 0, 0);//impresion del atlas de pokemon
  catchB_off = get(448, 576, 64, 64);
  catchB = get(512, 576, 64, 64);
  //---- Imprime el resto de imagenes del juego
  scenario();
}

void draw() {
  money_char = str(money);
  update();
  shiny();

  if (textCheck == 0) {//condicion para permitir al texto imprimirse una vez
    textFont(font);
    textSize(22);
    text(name[xRate][yRate], 150, 441, 210, 40); //impresion del nombre del pokemon

    fill(255);

    textFont(font1);
    textSize(22);
    text("Cantidad Actual:", 663, 24, 210, 40); //impresion del nombre del pokemon

    textSize(40);
    text(" $" + money_char, 663, 44, 190, 66); //impresion del efectivo

    if (stock_field == 15) {
      text("Has ganado!!!", 683, 94, 190, 66);
    }
    textCheck = 1;
  }

  for (int i=0; i<=14; i++) {
    image(minImage[i], minX, 511); //impresion del pokemon miniatura
    minX=minX+32;
  }
  minX=11;//reinicio de la posicion inicial de miniaturas

}


void update() { //actualizacion de datos para detectores de posicion

  if (countPKB != 360) {//cambio de estado del contador de pokeballs
    image(catchB, 431, 409); //boton de captura
  } else {
    image(catchB_off, 431, 409); //boton de captura
  }

  if (rectOver && countPKB != 144 && money >= 15) {//validacion del boton 
    image(e, 220, 400); //boton de compra
  } else {
    image(e_off, 220, 400); //boton de compra
  }

  if ( overCircle(463, 441, 64) ) {
    circleOver = true;
  } else if ( overRect(220, 400, 72, 24) ) {
    rectOver = true;
  } else {
    rectOver = false;
    circleOver = false;
  }
}


void mouseReleased() {

  if (circleOver && countPKB != 360 && stock_field != 15) { //si el mouse se encuentra sobre el boton y aun quedan pokeballs para lanzar y existen espacios vacion en el almacen [miniaturas]

    if (round(random(9))+1 <= gotcha) {//calculo de captura pkmn
      captura = 2; //se escapa
    } else {
      captura = 1;//capturado
      if (cont_captura != 5) {//reset de cantidad de captura
        cont_captura++;
      } else {//cuando se capturan 6 pkmn, se aplica un reset y hay una bonificacion de dinero
        cont_captura=0;
        money = money+30; //incremento bonus por capturar 6 pkm
      }

      money = money+10;
      println("Cantidad actual: " + "$ " + money);
    }

    pkbAsset(); //impresion de pokeball segun el estado de pokeballs faltante
    past_xRate = xRate;
    past_yRate = yRate;

    capturado(captura);//asignacion de nueva miniatura al array

    Shiny = round(random(199))+1;//indicador de pkm shiny
    xRate = round(random(15))+1;//coord X

    if (xRate >= 8) { //coord Y dependiente de la X
      yRate = round(random(8))+1;
    } else {
      yRate = round(random(9))+1;
    }

    shiny();

    pickOne(xRate, yRate);//recorte del atlas
    Picklvl(cont_captura);//selecciona la cantidad de capturados
  } else if (rectOver && countPKB > 144 && money >= 15) {
    countPKB=countPKB-144;
    pkbAsset();
    money = money-5; //costo por pokeball (15)
    println("Cantidad actual: " + "$ " + money);
  } else if (mouseX>11 && mouseX<491 && mouseY>513 && mouseY<545) { //click para eliminar del almacen el pkmn

    if (stock[floor((mouseX-11)/32)] == 1) {//generacion de shinys
      money = money+30;//incremento de dinero por pkm atrapado (20)
      println("Cantidad actual: " + "$ " + money);
    } else {
      println("Este espacio esta vacio");
    }


    indice_captura=floor((mouseX-11)/32);
    stock[floor((mouseX-11)/32)] = 0;//formula para determinar el boton en el cual se encuentra el mouse actualmente
    stock_field--;
    pickMin(8, 10, indice_captura);
  }
  scenario();
  textCheck = 0;
}



boolean overRect(int x, int y, int width, int height) {//detector de posicion [rect]
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

boolean overCircle(int x, int y, int diameter) { //detector de posicion [circle]
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

boolean minClick(int x, int y) { //detector de posicion [Miniatura]
  if (mouseX > x && mouseX < x+32 && mouseY > y && mouseY < y+32) {
    return true;
  } else {
    return false;
  }
}

void pickOne(int x, int y) {//funcion del recorte de atlas pokemon

  if (Shiny_state == 1) {//generacion de shinys
    image(STileM, 0, 0);//impresion del atlas de pokemon Shiny
  } else {
    image(TileM, 0, 0);//impresion del atlas de pokemon
  }


  int xPixel = (x - 1)*64;
  int yPixel = (y - 1)*64;
  c = get(xPixel, yPixel, 64, 64);
}

void pickMin(int x, int y, int indice) {//funcion del recorte de atlas de miniaturas

  if (Shiny_state == 1) {//generacion de shinys
    image(SMinM, 0, 0);//impresion del atlas de miniaturas Shiny
  } else {
    image(MinM, 0, 0);//impresion del atlas de miniaturas
  }

  int xPixel = (x - 1)*32;
  int yPixel = (y - 1)*32;
  minImage[indice] = get(xPixel, yPixel, 32, 32);
}

void capturado(int state) {//funcion para asignacion de miniaturas en array
  if (state == 1) {//en caso de haber capturado el pkmn

    for (int i=0; i<=14; i++) {
      if (stock[i] == 0) { //posiciona el indice de captura en el numero menor de los campos vacios del almacen
        indice_captura = i;
        break;
      }
    }

    stock_field =0;
    pickMin(past_xRate, past_yRate, indice_captura);
    stock[indice_captura] = 1;

    for (int i=0; i<=14; i++) {
      if (stock[i] == 0) { //si es cero significa que queda espacio libre en el almacen en el capo determinado por i
        indice_captura = i;
        break;
      } else {
        stock_field++;
      }
    }
  } else {
    if (Shiny_state == 1) {
      println(name[past_xRate][past_yRate] + " Shiny" + " se escapo");
    } else {
      println(name[past_xRate][past_yRate] + " se escapo");
    }
  }
}

void pkbAsset() {//funcion del recorte de atlas extras [o¿pkball counter]
  image(extra, 0, 0);
  countPKB = countPKB + 72;
  if (countPKB > 360) { //todas las pokeballs disponibles
    countPKB = 360;
  }
  d = get(countPKB, 0, 72, 24);
}

void Picklvl(int nivel) {//funcion del recorte de atlas extras [o¿pkball counter]
  image(lvl, 0, 0);
  coord = nivel * 72;
  lvl_get = get(coord, 0, 72, 20);
}
