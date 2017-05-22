#
#	U, position (of coset) [, row (number)]	(default: row = 1)
#

MakeOrbit:=function(arg)
	local M, pos, row, orbit;
	M:=arg[1][1];
	pos:=arg[2];
	if IsBound(arg[3]) then
		row:=arg[3];
	else
		row:=1;
	fi;
	orbit:=[pos];
	while M[row][orbit[Length(orbit)]]<>orbit[1] do
		Add(orbit,M[row][orbit[Length(orbit)]]);
	od;
	return Immutable(orbit);
end;



#
# 	U [, row (number)]	(default: row = 1)
#

OrbitSizes:=function(arg)
	local M, row, r, orbitsizelist, checked, i, orbit, j;
	M:=arg[1][1];
	if IsBound(arg[2]) then
		row:=arg[2];
	else
		row:=1;
	fi;
	r:=DimensionsMat(M)[2];
	orbitsizelist:=[[],[]];
	checked:=EmptyPlist(r);
	for i in [1..r] do
		if not IsBound(checked[i]) then
			orbit:=MakeOrbit(arg[1],i,row);
			if \in(Length(orbit),orbitsizelist[1]) then
				j:=Position(orbitsizelist[1],Length(orbit));
				orbitsizelist[2][j]:=orbitsizelist[2][j]+1;
			else
				Add(orbitsizelist[1],Length(orbit));
				Add(orbitsizelist[2],1);
			fi;
			for j in [1..Length(orbit)] do
				checked[orbit[j]]:=1;
			od;
		fi;
	od;
	SortParallel(orbitsizelist[1],orbitsizelist[2]);
	return Immutable(orbitsizelist);
end;



#
#	M
#

ShiftOrder:=function(M)
	return Lcm(OrbitSizes([M])[1]);	
end;



#
#	M
#

MakeTree:=function(M)
	local tree, treelist, treemark, initpoint, i, orbit;
	tree:=[[,]];
	treelist:=[1];
	treemark:=0;
	while treemark<Length(treelist) do
		treemark:=treemark+1;
		initpoint:=treelist[treemark];
		if not IsBound(tree[M[3][initpoint]]) then
			orbit:=MakeOrbit([M],M[3][initpoint]);
			for i in [1..Length(orbit)] do
				if i=1 then
					tree[orbit[i]]:=[initpoint,0];
				else
					tree[orbit[i]]:=[orbit[i-1],1];
				fi;
				Add(treelist,orbit[i]);
			od;
		fi;
		Unbind(treelist[treemark]);
	od;
	return Immutable(tree);
end;



#
#	M, n [, f]
#
#	(Default: f unbound)
#

MakeUnified:=function(arg)
	local M, U;
	M:=arg[1];
	U:=[M,MakeTree(M),ShiftOrder(M),arg[2]];
	if IsBound(arg[3]) then
		Add(U,arg[3]);
	fi;
	return Immutable(U);
end;



#
#	U [,f]
#

ModifyRetraction:=function(arg)
	local U;
	U:=ShallowCopy(arg[1]);
	Unbind(U[5]);
	if IsBound(arg[2]) then
		U[5]:=arg[2];
	fi;
	return Immutable(U);
end;



#
#	U [, power (of shift), primitives (only)]
#
#	(default: power = 1, not only primitives)
#
#	Note: You must specify a power to allow returning only primitives.
#

FixedPoints:=function(arg)
	local M, pow, prim, div, r, checked, fixedpointlist, i, orbit, j;
	M:=arg[1][1];
	if IsBound(arg[2]) then
		pow:=arg[2];
		prim:=false;
		if IsBound(arg[3]) then
			prim:=true;
		fi;
	else
		pow:=1;
		prim:=false;
	fi;
	if prim then
		div:=[pow];
	else
		div:=DivisorsInt(pow);
	fi;
	r:=DimensionsMat(M)[2];
	checked:=EmptyPlist(r);
	fixedpointlist:=[];
	for i in [1..r] do
		if not IsBound(checked[i]) then
			orbit:=MakeOrbit([M],i);
			if \in(Length(orbit),div) then
				for j in [1..Length(orbit)] do
					Add(fixedpointlist,orbit[j]);
				od;
			fi;
			for j in [1..Length(orbit)] do
				checked[orbit[j]]:=1;
			od;
		fi;
	od;
	Sort(fixedpointlist);
	return Immutable(fixedpointlist);
end;



#
#	U, Position (of coset) [, f]
#
#	(Default: f = U[5], otherwise f undefined)
#

MakeWordlist:=function(arg)
	local tree, step, wordlist, f, n, adjust;
	tree:=arg[1][2];
	step:=arg[2];
	wordlist:=[];
	while step<>1 do
		Add(wordlist,tree[step][2],1);
		step:=tree[step][1];
	od;
	if IsBound(arg[3]) then
		f:=arg[3];
	elif IsBound(arg[1][5]) then
		f:=arg[1][5];
	fi;
	if IsBound(f) then
		n:=arg[1][4];
		adjust:=(f*(Sum(wordlist)-Length(wordlist))-Sum(wordlist)) mod n;
		while adjust<>0 do
			adjust:=adjust-1;
			Add(wordlist,1,1);
		od;
	fi;
	return Immutable(wordlist);
end;



#
#	U, Wordlist [, Position (starting)]
#
#	(Default: Position = 1)
#

TraceWordlist:=function(arg)
	local M, wordlist, pos, step;
	M:=arg[1][1];
	wordlist:=arg[2];
	if IsBound(arg[3]) then
		pos:=arg[3];
	else
		pos:=1;
	fi;
	step:=0;
	while step<Length(wordlist) do
		step:=step+1;
		if wordlist[step]=0 then
			pos:=M[3][pos];
		else
			pos:=M[1][pos];
		fi;
	od;
	return pos;
end;



#
#	Two possible inputs:
#
#		1) U, Position (starting) [, f]
#
#		2) U, Wordlist
#
#		(Default: f = U[5])
#

MakePowers:=function(arg)
	local U, f, wordlist, powerset;
	U:=arg[1];
	if IsList(arg[2]) then
		wordlist:=arg[2];
	else
		if IsBound(arg[3]) then
			f:=arg[3];
		else
			f:=U[5];
		fi;
		wordlist:=MakeWordlist(U,arg[2],f);
	fi;
	powerset:=[TraceWordlist(U,wordlist)];
	while not \in(1,powerset) do
		Add(powerset,TraceWordlist(U,wordlist,powerset[Length(powerset)]));
	od;
	return Immutable(powerset);
end;



#
#	U [, f]
#
#	(Default: f = U[5])
#

Orderlist:=function(arg)
	local U, f, r, orders, i, wordlist, powerlist, plsize, j;
	U:=arg[1];
	if IsBound(arg[2]) then
		f:=arg[2];
	else
		f:=U[5];
	fi;
	r:=Size(U[2]);
	orders:=EmptyPlist(r);
	orders[1]:=1;
	if r>1 then
		for i in [2..r] do
			if not IsBound(orders[i]) then
				wordlist:=MakeWordlist(U,i,f);
				powerlist:=MakePowers(U,wordlist);
				plsize:=Length(powerlist);
				for j in [1..plsize] do
					if not IsBound(orders[powerlist[j]]) then
						orders[powerlist[j]]:=plsize/Gcd(plsize,j);
					fi;
				od;
			fi;
		od;
	fi;
	return Immutable(orders);
end;



#
#	U [, f]
#
#	(Default: f = U[5])
#

MakeCenter:=function(arg)
	local U, f, r, xset, checked, center, i, w, centercheck, j, x, prodp, prodq, wlist, orbit, k;
	U:=arg[1];
	if IsBound(arg[2]) then
		f:=arg[2];
	else
		f:=U[5];
	fi;
	r:=Size(U[2]);
	xset:=MakeOrbit(U,U[1][1][3]);
	checked:=EmptyPlist(r);
	checked[1]:=0;
	center:=[1];
	if r>1 then
		for i in [2..r] do
			if not IsBound(checked[i]) then
				w:=MakeWordlist(U,i,f);
				centercheck:=true;
				j:=0;
				while j<Length(xset) and centercheck do
					j:=j+1;
					x:=MakeWordlist(U,xset[j],f);
					prodp:=TraceWordlist(U,w,xset[j]);
					prodq:=TraceWordlist(U,x,i);
					if prodp<>prodq then
						centercheck:=false;
					fi;
				od;
				if centercheck then
					wlist:=MakePowers(U,w);
					for j in [1..Length(wlist)] do
						orbit:=MakeOrbit(U,wlist[j]);
						Append(center,ShallowCopy(orbit));
						for k in [1..Length(orbit)] do
							checked[orbit[k]]:=0;
						od;
					od;
				else
					orbit:=MakeOrbit(U,i);
					for k in [1..Length(orbit)] do
						checked[orbit[k]]:=0;
					od;
				fi;
			fi;
		od;
	fi;
	Sort(center);
	return AsDuplicateFreeList(center);
end;



#
#	U, Subgroup (as a list of cosets that form a subgroup) [, f]
#
#	(Default: f = U[5])
#

MakeGroupFromList:=function(arg)
	local U, gens, f, genwordlist, i, free, ggens, grels, groupcheck, j, w, p;
	U:=arg[1];
	gens:=arg[2];
	if IsBound(arg[3]) then
		f:=arg[3];
	else
		f:=U[5];
	fi;
	genwordlist:=[];
	for i in [1..Size(gens)] do
		Add(genwordlist,MakeWordlist(U,gens[i],f));
	od;
	free:=FreeGroup(Size(gens));
	ggens:=GeneratorsOfGroup(free);
	grels:=[];
	groupcheck:=true;
	i:=0;
	while groupcheck and i<Size(gens) do
		i:=i+1;
		j:=0;
		while groupcheck and j<Size(gens) do
			j:=j+1;
			p:=Position(gens,TraceWordlist(U,genwordlist[j],gens[i]));
			if p=fail then
				groupcheck:=false;
			else
				Add(grels,ggens[i]*ggens[j]*(ggens[p])^(-1));
			fi;
		od;
	od;
	if groupcheck then
		return free/grels;
	else
		return fail;
	fi;
end;



#
#	U, List (of coset elements of normal subgroup) [, f]
#
#	(Default: f = U[5])
#

MakeQuotientlist:=function(arg)
	local U, sub, f, r, quosort, numsorted, i, g, j, p;
	U:=arg[1];
	sub:=arg[2];
	if IsBound(arg[3]) then
		f:=arg[3];
	else
		f:=U[5];
	fi;
	r:=Size(U[2]);
	quosort:=EmptyPlist(r);
	numsorted:=0;
	i:=0;
	while numsorted<r do
		i:=i+1;
		if not IsBound(quosort[i]) then
			numsorted:=numsorted+Size(sub);
			g:=MakeWordlist(U,i,f);
			for j in [1..Size(sub)] do
				p:=TraceWordlist(U,g,sub[j]);
				quosort[p]:=i;
			od;
		fi;
	od;
	return Immutable(quosort);
end;



#
#	List (of integers)
#

DuplicateFree:=function(list)
	local r, m, M, newlist, i;
	r:=Size(list);
	m:=-Minimum(list)+1;
	M:=Maximum(list);
	newlist:=EmptyPlist(M+m);
	if r>0 then
		for i in [1..r] do
			newlist[list[i]+m]:=list[i];
		od;
	fi;
	return Immutable(Compacted(newlist));
end;



#
#	List (a Quotientlist(...))
#

SortByCoset:=function(quolist)
	local cosets, i;
	cosets:=EmptyPlist(Size(quolist));
	for i in [1..Size(quolist)] do
		if IsBound(cosets[quolist[i]]) then
			Add(cosets[quolist[i]],i);
		else
			cosets[quolist[i]]:=[i];
		fi;
	od;
	return Immutable(Compacted(cosets));
end;

#
#	wordlist, string, string
#	
#	each string of one character, used as letters to generate words
#

MakeWord:=function(wordlist, str1, str0)
	local word, count, i;
	word:="";
	if Length(wordlist)<>0 then
		for i in [1..Length(wordlist)] do
			if i<>1 and wordlist[i-1]=wordlist[i] then
				count:=count+1;
			else
				if i<>1 and wordlist[i-1]<>wordlist[i] then
					word:=Concatenation(word,"*");
				fi;
				count:=1;
				if wordlist[i]=0 then
					word:=Concatenation(word,str0);
				else
					word:=Concatenation(word,str1);
				fi;
			fi;
			if count<>1 and (i=Length(wordlist) or wordlist[i]<>wordlist[i+1]) then
				word:=Concatenation(word,"^",String(count));
			fi;
		od;
	fi;
	return word;
end;

############	Below this line for new functions to replace old ones	########

#
#	To replace FixedPoints
#	U, word (not a string, but a word)
#

CentralizingIndices := function(U, word)
	local cent, wordindex, i, iwordlist, index1, iindex, index2;
	cent := [1];
	wordindex := TracedCosetFpGroup(U[1],word,1);
	for i in [2..Size(U[1][1])] do
		iwordlist := MakeWordlist(U,i);
		index1 := TraceWordlist(U, iwordlist, wordindex);
		iindex := TraceWordlist(U, iwordlist);
		index2 := TracedCosetFpGroup(U[1],word,iindex);
		if index1 = index2 then
			Add(cent, iindex);
		fi;
	od;
	return cent;
end;


############	Below this line requires modification or testing	############



#
# Concatenation("q",String(i-1))
#
#



#
#	U, Quotientlist [, f]
#
#	(Default: f = U[5])
#

MakeGroupFromQuotientlist:=function(arg)
	local U, quolist, f;
	U:=arg[1];
	quolist:=arg[2];
	if IsBound(arg[3]) then
		f:=arg[3];
	else
		f:=U[5];
	fi;
	
end;




#
#	Orderlist
#
#
#

OrderSummary:=function(orderlist)
	local ordersummary, i;
	ordersummary:=[DuplicateFree(orderlist)];
	ordersummary[2]:=EmptyPlist(Maximum(ordersummary[1]));
	for i in [1..Size(orderlist)] do
		if IsBound(ordersummary[2][orderlist[i]]) then
			ordersummary[2][orderlist[i]]:=ordersummary[2][orderlist[i]]+1;
		else
			ordersummary[2][orderlist[i]]:=1;
		fi;
	od;
	ordersummary[2]:=Compacted(ordersummary[2]);
	return Immutable(ordersummary);
end;
