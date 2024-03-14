//Implementacion de pantallas de "partida ganada"  normal y especial. //<>//
//logros activos (4/4) : Bancarrota, Maestro de los shinys, Mewtastic, comunidad de legendarios
//adaptacion del vector de pkm shiny en el cual se conoce la posicion del pkm shiny almacenado
//adaptacion de variable shinyNumber que contiene la cantidad total de shinys capturados
//adaptacion del vector mew en el cual se conoce la posicion del mew almacenado
//adaptacion de variable mewNumber que contiene la cantidad total de mews capturados
//adaptacion de vector que indica cuales y en que posicion se almacenan los pkm legendarios
//adaptacion de variable legendNumber que valida si se tiene en almacenamiento los 5 legendarios a la vez

PImage lvl, lvl_get, SMinM, MinM, bg_n, bg_m, TileM, STileM, c, d, e, e_off, extra, catchB, catchB_off, McatchB, McatchB_off; //c -> pkm; d -> pkball count; e -> button
PImage reroll, reroll_off, mb, mb_off, percent, percent_off;
PImage A_win, win, lose;
PImage[] minImage= new PImage[15];
int shinyNumber = 0;//Variable indicador de la cantidad actual de shiny almacenados
int mewNumber = 0;//Variable indicador de la cantidad actual de shiny almacenados
int legendNumber = 1;//Variable indicador para llevar un seguimiento del logro de comunidad legendaria
int xRate, yRate, bttn_state, catch_state, countPKB=144, captura, gotcha = 6;//gotcha es el numero modifica el porcentaje de captura[0-todos se captura/ 10-todo se escapa]
int past_xRate, past_yRate, minX=11, indice_captura, stock_field; //minX->posicion inicial de impresion de miniaturas, indice de captura->indice de busqueda de miniaturas por pkmn capturado
int[] stock = new int[15]; //variable para el seguimiento del almacen
int[] shinyStock = new int[15];//referencia para conocer con exactitud cuales son los shiny almacenados
int[] mewStock = new int[15];//referencia para conocer con exactitud cuales son los mew almacenados
int[] legendaryStock = new int[15];//referencia para conocer si se ha completado el logro de comunidad legendaria
String[][] name = new String[17][11]; //matriz similar a los pokemon para reusar las coord y asi ubicar los nombres
String[] Arch;//Vector que captura los valores de referencia de los logros
PFont font, font1;

int R, C, coord, cont_captura;
boolean rectOver = false, circleOver = false; //funciones para deteccion de botones
boolean rerollOver = false, mbOver = false, percentOver = false;//deteccion de botones
boolean switchPokeball = false; //false -> pokeball, true -> masterball
boolean especialPkm = false;//indicador de opcion generador shinys
boolean outPkblls;//out of pokeballs indica si se han agotado las pokeballs disponibles
boolean end = false;//variable que determina si el juego ha terminado (hayas o no ganado la partida)
boolean flush = false;//Variable de seguridad para que solo se haga un flush unicamente

int textCheck = 0;//filtro para imprimir el texto una vez
int Shiny, Shiny_state;
int animation; //variables de referencia para usar como frames
int money = 50; //cantidad incial de dinero para mantener las pokeball en stock
String money_char = str(money);

PrintWriter output;

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
  image(bg_n, 0, 0, 1024, 640); //impresion del fondo sobre el atlas
  image(d, 15, 15); //pkball counter
  image(c, 225, 287); //impresion del pokemon
  image(lvl_get, 419, 19); //impresion de contador de captura
}

void setup() {
  size(1024, 640);
  //Alamcenar nombres en forma de matriz
  String[] lines = loadStrings("pkmlist.txt");
  //fileExists(dataPath("arch.txt"));
  if (fileExists(dataPath("arch.txt"))) {
    Arch = loadStrings("arch.txt");//archivements
    output = createWriter("data/arch.txt");
  } else {
    //Se crea el documento de almcenamiento local para los logros (en caso no de haber uno creado)
    output = createWriter("data/arch.txt");
    for (int j = 0; j <= 3; j++) {
      output.println("0");
    }
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
    //carga los datos del archivo creado
    Arch = loadStrings("arch.txt");//archivements
    output = createWriter("data/arch.txt");
  }

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
  A_win = loadImage("achievement_win_screen.png");
  win = loadImage("win_screen.png");
  lose = loadImage("lose_screen.png");
  bg_n = loadImage("bg_normal.png");
  bg_m = loadImage("bg_master.png");
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
  reroll = get(432, 0, 24, 24);//boton reroll activo
  reroll_off = get(456, 0, 24, 24);//boton reroll inactivo
  mb = get(480, 0, 24, 24);//boton masterball activo
  mb_off = get(504, 0, 24, 24);//boton masterball inactivo
  percent = get(528, 0, 24, 24);//boton porcentaje activo
  percent_off = get(552, 0, 24, 24);//boton porcentaje inectivo
  //---- Imprime la imagen de los assets que comprenden los botones de captura
  image(TileM, 0, 0);//impresion del atlas de pokemon
  catchB_off = get(448, 576, 64, 64);
  catchB = get(512, 576, 64, 64);
  McatchB_off = get(576, 576, 64, 64);
  McatchB = get(640, 576, 64, 64);
  //---- Imprime el resto de imagenes del juego
  scenario();
}

void draw() {

  if (stock_field == 15) {
    if (end == false) {//esta condicion es para limitar la ejecucion a una unica vez
      for (int i=0; i<=14; i++) {
        if (shinyStock[i] == 1) { //realiza un conteo final de shinys capturados
          shinyNumber++;
        }
        if (mewStock[i] == 1) {
          mewNumber++;
        }
      }
      for (int i=0; i<=14; i++) {
        if (legendaryStock[i] == legendNumber) {
          legendNumber++;
          for ( i=0; i<=14; i++) {
            if (legendaryStock[i] == legendNumber) {
              legendNumber++;
              for ( i=0; i<=14; i++) {
                if (legendaryStock[i] == legendNumber) {
                  legendNumber++;
                  for ( i=0; i<=14; i++) {
                    if (legendaryStock[i] == legendNumber) {
                      legendNumber++;
                      for ( i=0; i<=14; i++) {
                        if (legendaryStock[i] == legendNumber) {
                          legendNumber++;
                          break;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      println("total de pkm shiny capturados: " + shinyNumber);
      println("total de mew capturados: " + mewNumber);
      if (Integer.parseInt(Arch[0]) == 0 && shinyNumber >= 15) {
        Arch[0] = "1";
      } else if (Integer.parseInt(Arch[3]) == 0 && mewNumber >= 15) {
        Arch[3] = "1";
      } else if (Integer.parseInt(Arch[2]) == 0 && legendNumber > 5) {
        Arch[2] = "1";
      }
    }

    end = true;
    text("Has ganado!!!", 683, 94, 190, 320);
    if (Integer.parseInt(Arch[0]) == 1 && Integer.parseInt(Arch[1]) == 1 && Integer.parseInt(Arch[2]) == 1 && Integer.parseInt(Arch[3]) == 1) {
      image(A_win, 0, 0);//En caso de conseguir todos los logros, la pantalla final es diferente
    } else {
      image(win, 0, 0);
    }
    //---- Impresion de segmento de logros
    fill(255);
    textFont(font1);
    textSize(22);
    text("Presiona la tecla [ESPACIO] para salir.", 512, 390);
    text("Logros obtenidos:", 512, 500);
    if (Integer.parseInt(Arch[0]) == 0) {
      text("????", 512, 530);
    } else {
      text("Maestro recolector de Shinys", 512, 530);
    }
    if (Integer.parseInt(Arch[1]) == 0) {
      text("????", 512, 550);
    } else {
      text("Bancarrota", 512, 550);//Pierde una partida
    }
    if (Integer.parseInt(Arch[2]) == 0) {
      text("????", 512, 570);
    } else {
      text("Comunidad de legendarios", 512, 570);//Haber capturado un mewtwo, mew, zapdos, articuno y moltres
    }
    if (Integer.parseInt(Arch[3]) == 0) {
      text("????", 512, 590);
    } else {
      text("Mewtastic", 512, 590);//llena el almacen solo de mew's
    }
    //----
  } else if (stock_field != 15 && money <= 1 && outPkblls) {

    if (end == false) {//esta condicion es para limitar la ejecucion a una unica vez
      for (int i=0; i<=14; i++) {
        if (shinyStock[i] == 1) { //realiza un conteo final de shinys capturados
          shinyNumber++;
        }
      }
      for (int i=0; i<=14; i++) {
        if (legendaryStock[i] == legendNumber) {
          legendNumber++;
          for ( i=0; i<=14; i++) {
            if (legendaryStock[i] == legendNumber) {
              legendNumber++;
              for ( i=0; i<=14; i++) {
                if (legendaryStock[i] == legendNumber) {
                  legendNumber++;
                  for ( i=0; i<=14; i++) {
                    if (legendaryStock[i] == legendNumber) {
                      legendNumber++;
                      for ( i=0; i<=14; i++) {
                        if (legendaryStock[i] == legendNumber) {
                          legendNumber++;
                          break;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      println("total de pkm shiny capturados: " + shinyNumber);
    }

    end = true;
    text("Has perdido!!!", 683, 94, 190, 320);
    image(lose, 0, 0);
    if (Integer.parseInt(Arch[1]) == 0) {
      Arch[1] = "1";
    } else if (Integer.parseInt(Arch[2]) == 0 && legendNumber > 5) {
      Arch[2] = "1";
    }
    //---- Impresion de segmento de logros
    fill(255);
    textFont(font1);
    textSize(22);
    text("Presiona la tecla [ESPACIO] para salir.", 512, 390);
    text("Logros obtenidos:", 512, 500);
    if (Integer.parseInt(Arch[0]) == 0) {
      text("????", 512, 530);
    } else {
      text("Maestro recolector de Shinys", 512, 530);
    }
    if (Integer.parseInt(Arch[1]) == 0) {
      text("????", 512, 550);
    } else {
      text("Bancarrota", 512, 550);
    }
    if (Integer.parseInt(Arch[2]) == 0) {
      text("????", 512, 570);
    } else {
      text("Comunidad de legendarios", 512, 570);
    }
    if (Integer.parseInt(Arch[3]) == 0) {
      text("????", 512, 590);
    } else {
      text("Mewtastic", 512, 590);
    }
    //----
  } else {

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
      text("Cantidad Actual:", 663, 24, 210, 40);
      text("El costo por re-roll es: $2\n El costo por pokeball: $5\n Pierdes si agotas el dinero.\n Ganas al conseguir atrapar 15 pokemon.", 770, 168);
      text("Asegura la siguiente captura en un 100% de exito ($10)", 770, 308);
      text("Asegura la siguiente aparacion como Shiny ($20)", 748, 368);
      text("Logros:", 770, 500);
      if (Integer.parseInt(Arch[0]) == 0) {
        text("????", 770, 530);
      } else {
        text("Maestro recolector de Shinys", 770, 530);
      }
      if (Integer.parseInt(Arch[1]) == 0) {
        text("????", 770, 550);
      } else {
        text("Bancarrota", 770, 550);
      }
      if (Integer.parseInt(Arch[2]) == 0) {
        text("????", 770, 570);
      } else {
        text("Comunidad de legendarios", 770, 570);
      }
      if (Integer.parseInt(Arch[3]) == 0) {
        text("????", 770, 590);
      } else {
        text("Mewtastic", 770, 590);
      }

      textSize(40);
      text(" $" + money_char, 663, 44, 190, 66); //impresion del efectivo

      textCheck = 1;
    }

    for (int i=0; i<=14; i++) {
      image(minImage[i], minX, 511); //impresion del pokemon miniatura
      minX=minX+32;
    }
    minX=11;//reinicio de la posicion inicial de miniaturas
  }
}


void update() { //actualizacion de datos para detectores de posicion

  if (countPKB != 360) {//cambio de estado del contador de pokeballs
    if (switchPokeball) {
      image(McatchB, 431, 409); //boton de captura
    } else {
      image(catchB, 431, 409); //boton de captura
    }
    outPkblls = false;
  } else {
    if (switchPokeball) {
      image(McatchB_off, 431, 409); //boton de captura
    } else {
      image(catchB_off, 431, 409); //boton de captura
    }
    outPkblls = true;
  }

  if ( overCircle(463, 441, 64) ) {
    circleOver = true;
  } else if ( overRect(220, 400, 72, 24) && countPKB != 144 && money >= 15) {
    image(e, 220, 400); //boton de compra
    rectOver = true;
  } else if (overCircle(465, 314, 24)) {
    image(reroll_off, 453, 302);//boton de reroll
    rerollOver = true;
  } else if (overCircle(545, 314, 24)) {
    image(mb_off, 533, 302); //boton de captura masterball
    mbOver = true;
  } else if (overCircle(545, 372, 24)) {
    image(percent_off, 533, 360); //boton de porcentaje
    percentOver = true;
  } else {
    image(mb, 533, 302); //boton de captura masterball
    image(reroll, 453, 302);//boton de reroll
    image(percent, 533, 360); //boton de porcentaje
    image(e_off, 220, 400); //boton de compra
    rectOver = false;
    circleOver = false;
    rerollOver = false;
    mbOver = false;
    percentOver = false;
  }
}


void mouseReleased() {
  if (end) {
    //El juego ha finalizado, se cancelan las demas acciones.
  } else {
    if (circleOver && countPKB != 360 && stock_field != 15) { //si el mouse se encuentra sobre el boton y aun quedan pokeballs para lanzar y existen espacios vacion en el almacen [miniaturas]
      if (switchPokeball) {
        captura = 1;//capturado
        if (cont_captura != 5) {//reset de cantidad de captura
          cont_captura++;
        } else {//cuando se capturan 6 pkmn, se aplica un reset y hay una bonificacion de dinero
          cont_captura=0;
          money = money+30; //incremento bonus por capturar 6 pkm
        }
        money = money+10;
        println("Cantidad actual: " + "$ " + money);
      } else {
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
      }

      pkbAsset(); //impresion de pokeball segun el estado de pokeballs faltante
      past_xRate = xRate;
      past_yRate = yRate;

      capturado(captura);//asignacion de nueva miniatura al array

      //El codigo siguiente es para genera el siguiente pkm
      Shiny = round(random(199))+1;//indicador de pkm shiny
      xRate = round(random(15))+1;//coord X

      if (xRate >= 8) { //coord Y dependiente de la X
        yRate = round(random(8))+1;
      } else {
        yRate = round(random(9))+1;
      }

      if (especialPkm) {
        Shiny = 10;
      }
      shiny();

      pickOne(xRate, yRate);//recorte del atlas
      Picklvl(cont_captura);//selecciona la cantidad de capturados
      switchPokeball = false;
      especialPkm = false;
      //captura realizada (o no)
    } else if (rectOver && countPKB > 144 && money >= 5) {
      countPKB=countPKB-144;
      pkbAsset();
      money = money-5; //costo por pokeball (15)
      println("Cantidad actual: " + "$ " + money);
    } else if (mouseX>11 && mouseX<491 && mouseY>513 && mouseY<545) { //click para eliminar del almacen el pkmn

      if (stock[floor((mouseX-11)/32)] == 1) {
        if (shinyStock[floor((mouseX-11)/32)] == 1) {//Si esta condision se cumple, significa que en esta posicion se almacena un pkm shiny y al ser eliminado, regresara mas dinero
          money = money+50;//incremento de dinero por pkm atrapado (40)
          println("Cantidad actual: " + "$ " + money);
        } else {
          money = money+30;//incremento de dinero por pkm atrapado (20)
          println("Cantidad actual: " + "$ " + money);
        }
      } else {
        println("Este espacio esta vacio");
      }


      indice_captura=floor((mouseX-11)/32);
      stock[floor((mouseX-11)/32)] = 0;//formula para determinar el boton en el cual se encuentra el mouse actualmente
      stock_field--;

      if (shinyStock[floor((mouseX-11)/32)] == 1) {//Si el pkm eliminado es shiny, se actualiza el vector stock que lleva el conteo de shinys
        shinyStock[floor((mouseX-11)/32)] = 0;
        println("Has liberado a un pokemon shiny");
      }
      if (mewStock[floor((mouseX-11)/32)] == 1) {
        mewStock[floor((mouseX-11)/32)] = 0;
        println("Has liberado a un Mew");
      }
      if (legendaryStock[floor((mouseX-11)/32)] != 0) {
        legendaryStock[floor((mouseX-11)/32)] = 0;
        println("Has liberado a un pkm legendario");
      }

      pickMin(8, 10, indice_captura);
    } else if (rerollOver && money >= 2) {
      money = money - 2;//costo por reroll
      reroll(especialPkm);
    } else if (mbOver && money >= 10 && switchPokeball == false) {
      money = money - 10;//costo por Masterball
      switchPokeball = true;
    } else if (percentOver && money >= 20) {
      money = money - 20;
      percent();
    }
    scenario();
    textCheck = 0;
  }
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

    stock_field = 0;

    //detector de mew capturado
    if (past_xRate == 7 && past_yRate == 10) {
      mewStock[indice_captura] = 1;
    }

    //deteccion de legendarios capturados
    if (past_xRate == 7 && past_yRate == 10) {
      legendaryStock[indice_captura] = 1;//mew
    } else if (past_xRate == 6 && past_yRate == 10) {
      legendaryStock[indice_captura] = 2;//mewtwo
    } else if (past_xRate == 16 && past_yRate == 9) {
      legendaryStock[indice_captura] = 3;//articuno
    } else if (past_xRate == 1 && past_yRate == 10) {
      legendaryStock[indice_captura] = 4;//zapdos
    } else if (past_xRate == 2 && past_yRate == 10) {
      legendaryStock[indice_captura] = 5;//moltres
    }

    pickMin(past_xRate, past_yRate, indice_captura);
    stock[indice_captura] = 1;
    //Si se detecta que el pokemon capturado es shiny, se almacena la posicion en la cual se encuentra este pkm
    if (Shiny_state == 1) {
      shinyStock[indice_captura] = 1;
    }

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

void reroll(boolean esp) {
  Shiny = round(random(199))+1;//indicador de pkm shiny
  xRate = round(random(15))+1;//coord X

  if (xRate >= 8) { //coord Y dependiente de la X
    yRate = round(random(8))+1;
  } else {
    yRate = round(random(9))+1;
  }
  if (esp) {
    Shiny = 10;
  }
  shiny();
  pickOne(xRate, yRate);//recorte del atlas
  scenario();
  textCheck = 0;
  especialPkm=false;
}

void percent() {
  especialPkm = true;
}

boolean fileExists(String path) { //revisa si existe el archivo en la carpeta data
  File file=new File(path);
  println(file.getName());
  boolean exists = file.exists();
  if (exists) {
    println("true");
    return true;
  } else {
    println("false");
    return false;
  }
} 

void keyPressed() { 
  if (key == ' ' && end) {//Sue la partida ha concluido y se presiona la tecla espacio...
    exit(); // Termina el programa
  }
}

void exit() {//Antes de finalizar el programa, almacena los datos de los logros y cierra el documento
  for (int j = 0; j <= 3; j++) {
    output.println(Arch[j]);
  }
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  super.exit();//let processing carry with it's regular exit routine
}
