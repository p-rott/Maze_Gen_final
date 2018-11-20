//Maze generation
//https://en.wikipedia.org/wiki/Maze_generation_algorithm
//Paul, 17.02.17
//global variables because im a bad programmer
//possible optimizations: only draw cells when they changed, instead of drawing everything every loop

Cell[][] Cells;
IntList stack;
int scale = 30; //change for more/less cells
int cols, rows, unvisited, hueRand, steps, solvedPercent, maxStep, prevFrameCount; //stuff
int currentX, currentY, chosenX, chosenY; //Cells, could be changed to []
boolean[] neighbors;
boolean stop = false;

void setup() {
  size(810, 810);
  frameRate(120);
  cols = width/scale;
  rows = height/scale;
  Cells = new Cell[cols][rows]; 
  stack = new IntList();      //x, then y stored because arrays are hard
  colorMode(HSB, 500, 500, cols*rows); //more fluid brightness change due to high max value
  rectMode(CENTER); 
  for (int i = 0; i < cols; i++) //x
  {
    for (int j = 0; j < rows; j++) //y
    {
      Cells[i][j] = new Cell(i, j);
    }
  }
  reset(); //sets variables
}

void draw() {
  unvisited = cols * rows;
  //draw all that shit
  background(499);
  for (int i = cols - 1; i >= 0; i--) //x
  {
    for (int j = rows - 1; j >= 0; j--) //y
    {
      if (Cells[i][j].visited == true)
      {
        unvisited--;
      }
      //Adjusts brightness for each cell dependend on its distance from the origin
      Cells[i][j].colorBri = floor(map(Cells[i][j].step, 0, maxStep, cols*rows, 0));
      Cells[i][j].drawCell();
    }
  }
  //Pseudocode from wikipedia applied, changed stack method for more branches
  //While there are unvisited cells
  if (unvisited > 0)
  {
    //If the current cell has any neighbours which have not been visited
    if (checkN(currentX, currentY) > 0) //new function counts unvisited cells 
    {
      //Choose randomly one of the unvisited neighbours
      choseN(currentX, currentY);
      //Just for brightness adjust
      Cells[chosenX][chosenY].step = Cells[currentX][currentY].step + 1;
      //Cell that is most steps away from the origin is darkest
      if (Cells[chosenX][chosenY].step > maxStep) maxStep = Cells[chosenX][chosenY].step;
      //Push the current cell to the stack, if there are at least 2 unvisited neighbors
      //x1,y1,x2,y2....
      if (checkN(currentX, currentY) > 1)
      {
        stack.append(currentX);
        stack.append(currentY);
      }
      //Remove the wall between the current cell and the chosen cell
      removeWalls(currentX, currentY, chosenX, chosenY);
      //Make the chosen cell the current cell and mark it as visited
      currentX = chosenX;
      currentY = chosenY;
      Cells[currentX][currentY].visited = true;
    }
    //Else if stack is not empty
    //Changed to taking the oldest cell from the stack to make more branches
    else
    {
      if (stack.size() > 0)
      {
        //Pop a cell from the stack
        //Make it the current cell
        currentX = stack.get(0);
        stack.remove(0); 
        currentY = stack.get(0);
        stack.remove(0);
      }
    }
  }
  //percent solved log
  if (floor(float((cols * rows - unvisited))/(cols * rows) * 100) > solvedPercent)
  {
    solvedPercent = floor(float((cols * rows - unvisited))/(cols * rows) * 100);
    println(solvedPercent + "%");
  }
  //save picture when done and start again
  if (solvedPercent >= 100)
  {
    save(year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+"-"+rows+"R "+cols+"C"+"-"+floor((frameCount-prevFrameCount)/frameRate)+"sec.png");
    prevFrameCount = frameCount;
    //delay(1500);
    reset();
  }
}

void removeWalls(int curX, int curY, int chosX, int chosY) //remove the walls between two cells
{
  if (curX - chosX < 0) 
  {
    Cells[curX][curY].walls[0] = false; //right
  } else if (curX - chosX > 0) 
  {
    Cells[chosX][chosY].walls[0] = false; //right
  } else if (curY - chosY > 0) 
  {
    Cells[chosX][chosY].walls[1] = false; //bottom
  } else if (curY - chosY < 0) 
  {
    Cells[curX][curY].walls[1] = false; //bottom
  }
}

int checkN(int x, int y) //returns amount of unvisited neighbors
{
  int count = 0;
  if ((y-1) >= 0 && Cells[x][y - 1].visited == false) count ++;
  if ((x+1) <= (cols - 1) && Cells[x + 1][y].visited == false) count++;
  if ((y+1) <= (rows - 1) && Cells[x][y + 1].visited == false) count++;
  if ((x-1) >= 0 && Cells[x - 1][y].visited == false) count++;
  return count;
}

void reset() //Resets the sketch
{
  //Empty stack
  stack.clear();
  hueRand = int(random(500));
  //Reset each cell
  for (int i = cols - 1; i >= 0; i--) //x
  {
    for (int j = rows - 1; j >= 0; j--) //y
    {
      Cells[i][j].visited = false;
      Cells[i][j].walls[0] = true;
      Cells[i][j].walls[1] = true;
      Cells[i][j].colorBri = cols*rows;
      Cells[i][j].colorHue = hueRand;
      Cells[i][j].colorSat = 500;
      Cells[i][j].step = 0;
    }
  }
  //Make the initial cell the current cell and mark it as visited
  //Random staring position
  currentX = floor(random(cols));
  currentY = floor(random(rows));
  Cells[currentX][currentY].visited = true;
  maxStep = 1;
  solvedPercent = 0;
}

void choseN(int x, int y) //choses new neighbor
{
  boolean done = false;
  int rand;
  int[] rDir = {10, 10, 10, 10}; //Top, Right, Bottom, Left - can be changed individually to bias decisions
  chosenX = currentX;
  chosenY = currentY;
  //not optimal, but works
  //let me know, if there are better ways to dynamically adjust the chances
  while (!done)
  {
    done = true;
    rand = int(random(rDir[0] + rDir[1] + rDir[2] + rDir[3]));
    if ((y - 1) >= 0 && Cells[x][y - 1].visited == false && rand < rDir[0]) chosenY--;           //top
    else if ((x + 1 <= (cols - 1)) && Cells[x + 1][y].visited == false && rand < (rDir[0] + rDir[1])) chosenX++;      //right
    else if ((y + 1 <= (rows - 1)) && Cells[x][y + 1].visited == false && rand < (rDir[0] + rDir[1] + rDir[2])) chosenY++;      //bottom
    else if ((x - 1) >= 0 && Cells[x - 1][y].visited == false && rand < (rDir[0] + rDir[1] + rDir[2] + rDir[3])) chosenX--;      //left
    else
    {
      done = false;
    }
  }
}

void mousePressed()
{
  reset();
}

void keyPressed()
{
  if (key == ' ') //stop for debugging
  {
    stop = !stop;
    if (stop) noLoop();
    else loop();
  }
}