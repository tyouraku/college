#include <iostream>
#include <string>
using namespace std;
const int N=10;
char load[N+1][N+1];


class ChessBoard
{private:
	int x,y;
	char color;
public:
	char Board[N+1][N+1];
	void setchess(int,int,char);
	void InitChessBoard();
};

void ChessBoard::setchess(int x0,int y0,char color0){
	Board[x0][y0]=color0;
	load[x0][y0]=color0;
}

void ChessBoard::InitChessBoard(){
	for(int i=0;i<N;i++){
		for (int j=0;j<N;j++) Board[i][j]='*';
    }
}


class player
{private:
	string name;
	char color;
public:
	static int count;
	int status;
	player(string n,char c):name(n),color(c){};
	void setchessPlayer(int,int,char,ChessBoard);
	void play(ChessBoard);
	int judgeWin(ChessBoard,int,int);
};
int player::count=0;

void player::setchessPlayer(int x2,int y2,char color2,ChessBoard board){
	board.setchess(x2,y2,color2);
}

void player::play(ChessBoard board){
	status=0;
	int p_x,p_y;
	cout<<"请玩家"<<name<<"输入落子位置：";
	cin>>p_x>>p_y;
	while(p_x<0 || p_x>=N || p_y<0 || p_y>=N || load[p_x][p_y]!=' '){
		cout<<"输入不合法，请重新输入！"<<endl;
		cout<<"请玩家"<<name<<"输入落子位置：";
		cin>>p_x>>p_y;
	}
	board.setchess(p_x,p_y,color);
	count++;
	if(judgeWin(board,p_x,p_y)==1){
		cout<<"Game Over!"<<endl;
		cout<<"The winner is: "<<name<<endl;
		cout<<"The total step count is: "<<count<<endl<<endl;
		status=1;
	}
	else if(count==N*N){
		status=-1;
		cout<<"Game Over!"<<endl;
		cout<<"It's a tie!"<<endl;
		cout<<"The total step count is: "<<count<<endl<<endl;
	}
	cout<<"Now print"<<endl;
	for(int i=0;i<=N;i++) cout<<"--";
	cout<<endl;
	for(int i=0;i<N;i++){
		cout<<"|";
		for(int j=0;j<N;j++) cout<<load[i][j]<<" ";
		cout<<"|";
		cout<<endl;
	}
	for(int i=0;i<=N;i++) cout<<"--";
	cout<<endl;
}

int player::judgeWin(ChessBoard board,int x,int y){
	int temp[4]={1,1,1,1};

	for(int i=1;i<=4;i++){
		if((x-i)<0 || load[x-i][y]!=color) break;
		++temp[0];
		if(temp[0]==5) return 1;
	}
	for(int i=1;i<=4;i++){
		if((x+i)>=N || load[x+i][y]!=color) break;
		++temp[0];
		if(temp[0]==5) return 1;
	}

	for(int i=1;i<=4;i++){
		if((y-i)<0 || load[x][y-i]!=color) break;
		++temp[1];
		if(temp[1]==5) return 1;
	}
	for(int i=1;i<=4;i++){
		if((y+i)>=N || load[x][y+i]!=color) break;
		++temp[1];
		if(temp[1]==5) return 1;
	}

	for(int i=1;i<=4;i++){
		if((y-i)<0 || (x-i)<0 || load[x-i][y-i]!=color) break;
		++temp[2];
		if(temp[2]==5) return 1;
	}
	for(int i=1;i<=4;i++){
		if((y+i)>=N || (x+i)>=N || load[x+i][y+i]!=color) break;
		++temp[2];
		if(temp[2]==5) return 1;
	}

	for(int i=1;i<=4;i++){
		if((y+i)<0 || (x-i)<0 || load[x-i][y+i]!=color) break;
		++temp[3];
		if(temp[3]==5) return 1;
	}
	for(int i=1;i<=4;i++){
		if((y-i)>=N || (x+i)>=N || load[x+i][y-i]!=color) break;
		++temp[3];
		if(temp[3]==5) return 1;
	}

	return 0;
}

int main(){
	ChessBoard game;
	game.InitChessBoard();
	for(int i=0;i<N;i++) for(int j=0;j<N;j++) load[i][j]=' ';
	player first("mike",'b');
	player second("milk",'w');
	while(1){
		first.play(game);
		if(first.status!=0) break;
		second.play(game);
		if(second.status!=0) break;
		cout<<endl;
	}
	return 0;
}