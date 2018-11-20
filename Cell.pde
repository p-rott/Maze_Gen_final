class Cell
{
  boolean visited;
  boolean[] walls = {true, true}; //{right, bottom} - 2 walls are enough, since it goes from bottom right up
  int posX, posY;
  int colorSat;
  int colorHue;
  int colorBri;
  int step;

  //constructor
  Cell(int x, int y)
  {
    posX = x;
    posY = y;
  }

  void drawCell()
  {
    if (visited) //Color the cell if its visited
    {
      noStroke();
      fill(colorHue, colorSat, colorBri);
      //Not optimal for small scale values, should be changed back to normal rectMode()...
      rect(posX*scale + scale / 2, posY*scale + scale / 2, scale, scale);
    }
    strokeWeight(3);
    stroke(495);
    //right
    if (walls[0]) line(posX*scale+scale, posY*scale, posX*scale+scale, posY*scale+scale);
    //bottom
    if (walls[1]) line(posX*scale, posY*scale+scale, posX*scale+scale, posY*scale+scale);
  }
}