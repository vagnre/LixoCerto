import processing.video.*;
import processing.sound.*;

PImage arara;
PImage papel, plastico, organico, vidro, naoReciclavel, metal;
PImage[] lixoPapel = new PImage[3];
PImage[] lixoPlastico = new PImage[3];
PImage[] lixoOrganico = new PImage[3];
PImage[] lixoVidro = new PImage[3];
PImage[] lixoNaoReciclavel = new PImage[3];
PImage[] lixoMetal = new PImage[3];

Lixeira[] lixeiras = new Lixeira[6];
Lixo lixoAtual;

int placar = 0;

Movie[] videos = new Movie[5];
Movie videoAtual = null;
Movie endingScreen;
Movie initialScreen;
boolean isEnding = false;
boolean isInitialScreen = true;
int endingDuration = 10000;
int endingStartTime;

SoundFile[] somFases = new SoundFile[5];
SoundFile somInitialScreen;
SoundFile somEndingScreen;
SoundFile somAtual = null;
int faseAtual = -1;

SoundFile somJogarPapel;
SoundFile somJogarVidro;
SoundFile somJogarLixo;

void setup() {
  size(720, 720);
  smooth();

  carregaImagens();
  criaLixeiras();
  gerarLixo();

  for (int i = 0; i < videos.length; i++) {
    videos[i] = new Movie(this, "videos/video" + (i+1) + ".mp4");
    videos[i].volume(0);
  }
  endingScreen = new Movie(this, "videos/endingscreen.mp4");
  endingScreen.volume(0);
  
  initialScreen = new Movie(this, "videos/initialscreen.mp4");
  initialScreen.volume(0);

  carregaAudios();
  
  videoAtual = initialScreen;
  videoAtual.play();
  tocarAudio(somInitialScreen);
}

void draw() {
  if (isInitialScreen) {
    if (videoAtual.available()) {
      videoAtual.read();
    }
    image(videoAtual, 0, 0, width, height);
    
    if (videoAtual.time() >= videoAtual.duration() - 0.1) {
      isInitialScreen = false;
      iniciarVideo(0);
      tocarAudio(somFases[0]);
    }
    return;
  }
  
  if (isEnding) {
    if (videoAtual.available()) {
      videoAtual.read();
    }
    image(videoAtual, 0, 0, width, height);
    if (millis() - endingStartTime >= endingDuration) {
      isEnding = false;
      placar = 0;
      gerarLixo();
      iniciarVideo(0);
      tocarAudio(somFases[0]);
    }
    return;
  }

  if (videoAtual != null) {
    if (videoAtual.available()) {
      videoAtual.read();
    }
    image(videoAtual, 0, 0, width, height);
    if (videoAtual.time() >= videoAtual.duration()) {
      videoAtual.jump(0);
      videoAtual.play();
    }
  } else {
    background(200, 200, 250);
  }

  image(arara, 0, 0);

  textSize(16);
  textAlign(LEFT);
  String msg = "Pontuação: " + placar;
  float pad = 5;
  float h   = textAscent() + textDescent();
  float w   = textWidth(msg);
  pushStyle();
    fill(255);
    noStroke();
    rect(280 - pad, 35 - h - pad, w + 2*pad, h + 2*pad);
  popStyle();
  fill(0);
  text(msg, 280, 35);

  for (Lixeira lx : lixeiras) lx.display();

  if (lixoAtual != null) {
    lixoAtual.displayCenter();
  }

  checaMetasParaVideo();
}

void carregaAudios() {
  for (int i = 0; i < 5; i++) {
    somFases[i] = new SoundFile(this, "sons/somFase" + (i+1) + ".mp3");
  }
  
  somInitialScreen = new SoundFile(this, "sons/somInitialScreen.mp3");
  somEndingScreen = new SoundFile(this, "sons/somEndingScreen.mp3");
  
  somJogarPapel = new SoundFile(this, "sons/somJogarPapel.mp3");
  somJogarVidro = new SoundFile(this, "sons/somJogarVidro.mp3");
  somJogarLixo = new SoundFile(this, "sons/somJogarLixo.mp3");
}

void tocarAudio(SoundFile novoSom) {
  if (somAtual != null && somAtual.isPlaying()) {
    somAtual.stop();
  }
  
  somAtual = novoSom;
  somAtual.loop();
}

void mousePressed() {
  if (lixoAtual == null || isEnding || isInitialScreen) return;
  for (Lixeira lx : lixeiras) {
    if (lx.contains(mouseX, mouseY)) {
      lixoAtual.playSound();
      
      if (lx.tipo.equals(lixoAtual.tipo)) {
        placar++;
      } else {
        placar--;
      }
      gerarLixo();
      break;
    }
  }
}

void movieEvent(Movie m) {
  m.read();
}

void checaMetasParaVideo() {
  int idx = placar / 10;
  if (idx < videos.length) {
    if (videoAtual != videos[idx]) {
      iniciarVideo(idx);
      if (idx != faseAtual) {
        faseAtual = idx;
        tocarAudio(somFases[idx]);
      }
    }
  } else {
    iniciarEnding();
  }
}

void iniciarVideo(int idx) {
  if (videoAtual != null) videoAtual.stop();
  videoAtual = videos[idx];
  videoAtual.jump(0);
  videoAtual.loop();
}

void iniciarEnding() {
  if (isEnding) return;
  
  if (videoAtual != null) videoAtual.stop();
  videoAtual = endingScreen;
  videoAtual.jump(0);
  videoAtual.play();
  isEnding = true;
  endingStartTime = millis();
  
  tocarAudio(somEndingScreen);
}

void gerarLixo() {
  int tipo = int(random(6));
  int subTipo = int(random(3));
  PImage currentLixoImage = imgLixoPorIndice(tipo, subTipo);
  lixoAtual = new Lixo(
    width/2 - currentLixoImage.width/2,
    height/2 - currentLixoImage.height/2, // Centered vertically
    tipoPorIndice(tipo),
    currentLixoImage
  );
}

void carregaImagens() {
  arara         = loadImage("imagens/arara.png");
  papel         = loadImage("imagens/lixeiras/lixeira_papel.png");
  plastico      = loadImage("imagens/lixeiras/lixeira_plastico.png");
  organico      = loadImage("imagens/lixeiras/lixeira_organico.png");
  vidro         = loadImage("imagens/lixeiras/lixeira_vidro.png");
  naoReciclavel = loadImage("imagens/lixeiras/lixeira_nao_reciclavel.png");
  metal         = loadImage("imagens/lixeiras/lixeira_metal.png");

  lixoPapel[0] = loadImage("imagens/lixos/papel/caixa_papel.png");
  lixoPapel[1] = loadImage("imagens/lixos/papel/amassado_papel.png");
  lixoPapel[2] = loadImage("imagens/lixos/papel/ovos_papel.png");

  lixoPlastico[0] = loadImage("imagens/lixos/plastico/sacola_plastico.png");
  lixoPlastico[1] = loadImage("imagens/lixos/plastico/garrafa_plastico.png");
  lixoPlastico[2] = loadImage("imagens/lixos/plastico/copo_plastico.png");

  lixoOrganico[0] = loadImage("imagens/lixos/organico/melancia_organico.png");
  lixoOrganico[1] = loadImage("imagens/lixos/organico/banana_organico.png");
  lixoOrganico[2] = loadImage("imagens/lixos/organico/maca_organico.png");

  lixoVidro[0] = loadImage("imagens/lixos/vidro/perfume_vidro.png");
  lixoVidro[1] = loadImage("imagens/lixos/vidro/lampada_vidro.png");
  lixoVidro[2] = loadImage("imagens/lixos/vidro/taca_vidro.png");

  lixoNaoReciclavel[0] = loadImage("imagens/lixos/naorec/esponja_naorec.png");
  lixoNaoReciclavel[1] = loadImage("imagens/lixos/naorec/ceramica_naorec.png");
  lixoNaoReciclavel[2] = loadImage("imagens/lixos/naorec/fralda_naorec.png");

  lixoMetal[0] = loadImage("imagens/lixos/metal/sardinha_metal.png");
  lixoMetal[1] = loadImage("imagens/lixos/metal/lata_metal.png");
  lixoMetal[2] = loadImage("imagens/lixos/metal/latinha_metal.png");

  for (PImage im : new PImage[]{papel, plastico, organico, vidro, naoReciclavel, metal})
    im.resize(100, 0);

  for (PImage[] lixoArray : new PImage[][]{lixoPapel, lixoPlastico, lixoOrganico, lixoVidro, lixoNaoReciclavel, lixoMetal}) {
    for (PImage lixo : lixoArray) {
      lixo.resize(140, 0);
    }
  }
  arara.resize(258, 200);
}

void criaLixeiras() {
  float lixeiraWidth = 100;
  float esp = (width - 6 * lixeiraWidth) / 7.0;
  for (int i = 0; i < 6; i++) {
    float x = esp + i * (lixeiraWidth + esp);
    lixeiras[i] = new Lixeira(x, 620, tipoPorIndice(i), imgPorIndice(i));
  }
}

String tipoPorIndice(int i) {
  return new String[]{
    "papel", "plastico", "organico", "vidro", "nao_reciclavel", "metal"
  }[i];
}

PImage imgPorIndice(int i) {
  return new PImage[]{papel, plastico, organico, vidro, naoReciclavel, metal}[i];
}

PImage imgLixoPorIndice(int i, int subTipo) {
  return new PImage[][]{lixoPapel, lixoPlastico, lixoOrganico, lixoVidro, lixoNaoReciclavel, lixoMetal}[i][subTipo];
}

class Lixeira {
  float x, y;
  String tipo;
  PImage img;

  Lixeira(float x, float y, String t, PImage im) {
    this.x = x; this.y = y;
    tipo = t; img = im;
  }

  void display() {
    image(img, x, y);
  }

  boolean contains(float px, float py) {
    return px > x && px < x + img.width && py > y && py < y + img.height;
  }
}

class Lixo {
  float x, y;
  String tipo;
  PImage img;
  SoundFile somJogar;

  Lixo(float x, float y, String t, PImage im) {
    this.x = x; this.y = y;
    tipo = t; img = im;
    
    if (tipo.equals("papel")) {
      somJogar = somJogarPapel;
    } else if (tipo.equals("vidro")) {
      somJogar = somJogarVidro;
    } else {
      somJogar = somJogarLixo;
    }
  }

  void displayCenter() {
    float cx = x + img.width/2, cy = y + img.height/2;
    float dW = img.width + 20, dH = img.height + 20;
    pushStyle();
      noStroke();
      fill(255, 0, 0, 127);
      ellipse(cx, cy, dW, dH);
    popStyle();
    image(img, x, y);
  }
  
  void playSound() {
    if (somJogar != null) {
      if (somJogar.isPlaying()) {
        somJogar.stop();
      }
      somJogar.play();
    }
  }
}
