%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <iostream>
	#include <string>
	#include <algorithm>
	#include <map>
	#include <vector>
	#include <iterator>

	#include "y.tab.h"

	using namespace std;

	enum state {
		leftrec = 0,
		no_rec = 1,
		visited = 2,
	};

	extern FILE *yyin;
	extern int yylex();
	extern int linenum;
	void yyerror(string s);

	map<int,string>map1;
	map<int,string>map2;
	map<int,state>map3;
	vector<int>reclines;

	string devam="";
	bool rec = false;
	int noline = 1;
	bool erroroccur = false;

%}
%union
{
	char * str;
}
%token SMALL BIG SEMICOLON ARROW ERROR1 ERROR2
%token<str> NONTERMINAL
%token<str> TERMINAL
%type<str> list
%type<str> decleration
%%
lines:
	decleration
	|
	decleration lines
	;

decleration:
	NONTERMINAL ARROW list SEMICOLON{rec = false;}
	{
		map1[noline] = string($1);
		if(string($1) == string($3)){ // left recursion exists
			int spaceindex = devam.find_first_of(" ");
			map3[noline] = leftrec;
			map2[noline] = devam.substr(spaceindex + 1);
			rec = true;
		}
		else{ // no left recursion.
			map3[noline] = no_rec;
			map2[noline] = devam;
			rec = false;
		}

		noline++;
		devam = "";
	}
	|
	ERROR1 ARROW list SEMICOLON{
		cout << "Missing < symbol in line : " << linenum;
		erroroccur = true;

	}
	|
	ERROR2 ARROW list SEMICOLON{
		cout << "Missing > symbol in line : " << linenum;
		erroroccur = true;

	}
	;

list:
	list NONTERMINAL
	{
		devam += string($2) + " " ;
		$$ = strdup($1);

	}
	|
	list ERROR1
	{
		cout << "Missing < symbol in line : " << linenum;
		erroroccur = true;
	}
	|
	list ERROR2{
		cout << "Missing > symbol in line : " << linenum;
		erroroccur = true;
	}
	|
	list TERMINAL
	{
		devam += string($2) + " " ;
		$$ = strdup($1);


	}
	|
	TERMINAL
	{
		devam += string($1) + " " ;
		$$ = strdup($1);


	}
	|
	NONTERMINAL
	{
		devam += string($1) + " " ;
		$$ = strdup($1);

	}
	|
	ERROR1{
		cout << "Missing < symbol in line : " << linenum << endl;
		erroroccur = true;
	}
	|
	ERROR2{
		cout << "Missing > symbol in line : " << linenum << endl;
		erroroccur = true;
	}
	;

	%%
	void yyerror(string s){
		cerr<<"error in line" << linenum << endl;
		erroroccur = true;

	}

	int yywrap(){
		return 1;
	}

	int main(int argc, char *argv[])
	{
	    /* Call the lexer, then quit. */
	    yyin=fopen(argv[1],"r");
	    yyparse();

			map<int,state>::iterator iter3; // for map3
			map<int,string>::iterator iter2; // for map2
			map<int,string>::iterator iter1; // for map1
			vector<string> non_terminals; // holds non terminal strings

			string output = "";
			int line = 1;

			for(iter3 = map3.begin(); iter3 != map3.end(); iter3++){
				if(iter3 -> second == leftrec) { // left recursion exists
					string sss = map1[iter3 -> first];

					string inner = sss.substr(1, sss.size() - 2);
					string nont = "<";
					nont += inner;
					nont += "2>";

					for(iter1 = map1.begin(); iter1 != map1.end(); iter1++) {
						if(sss == iter1 -> second && map3[iter1 -> first] == no_rec){
							string concat = map1[line] + " -> " + map2[iter1 -> first] + nont + "\n";
							map3[iter1 -> first] = visited;
							output += concat;
						}
					}

					if(std::find(non_terminals.begin(), non_terminals.end(), inner) == non_terminals.end()) {
						output += nont + " -> " + "epsilon\n";
						non_terminals.push_back(inner);
					}

					output += nont + " -> " + map2[line] + nont + "\n";
				}
				else if(map3[line] == no_rec) { // left rec yoksa, directly copy
					output += map1[line] + " -> " + map2[line] + "\n";
				}

				line++;
			}
			if(erroroccur == false){
				cout << output << endl;

			}
	    fclose(yyin);

	    return 0;
	}
