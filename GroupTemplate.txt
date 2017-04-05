#
# This command bypasses the 'Read( ... );' protection built into
# this file. By default, the protection is active to prevent the loss of
# completed computations.
#
# To override the protection once, execute the command
#'Unbind(grouptemplatereadprotection);' in your GAP session.
#
# To override the protection permanently, uncomment the command below and
# save this file.
#

#Unbind(grouptemplatereadprotection);;

#
# These lines prevent accidental overwrites of the current GAP session if
# the Read( ... ) command is issued more than once.
#
# To override this feature, see above.
#
# This should not be edited unless you know what you are doing.
#

if not IsBound(grouptemplatereadprotection) then
	grouptemplatereadprotection:=false;;
fi;;
if not grouptemplatereadprotection then
	Read("./CPGTools.txt");;
	Unbind(n);; Unbind(w);; Unbind(f);;

#
# Enter a value for n.
#
# Ex:
# 	n := 5;;
#

	n := 5;;

#
# Insert any additional parameters you need here.
# 
# DO NOT USE ANY OF THE FOLLOWING SINGLE LETTERS: a, e, f, g, n, s, w, x, M
#
# You may leave this section blank if you wish.
#
# Ex:
#	j := 1;; k := 2;; l := 2;;
#

	j := 1;; k := 2;; l := 2;;

#
# Specify the word w as a string (must be in quotes) in terms of a, x, and
# exponents utilizing the additional parameters you entered above.
#
# Ex:
#	w := "x*a^j*x*a^(k-j)*x*a^(l-k)*x*a^-l";;
#

	w := "x*a^j*x*a^(k-j)*x*a^(l-k)*x*a^-l";;

#
# Uncomment the line below if you would like GAP to automatically attempt to
# create the coset table M for the right action of e on the cosets of s via a
# and x.
#
# Warning: This can be computationally expensive, particularly for large groups.
#		   Do not use this command unless you know that e is finite.
#		   (Consider running Size(e) first.)
#

	createunifiedlist := true;;

#
# Uncomment the line below and specify a value of f if there is a retraction
# \nu^f associated with the group e and you would like GAP to create the kernel
# g and the shift automorphism shiftg.
#
# Ex:
# f:= 0;;
#

	f := 0;;

#
# Uncomment the line below if there is a retraction \nu^f associated
# with the group e and you would like GAP to create a finitely
# presented group gisom isomorphic to g automatically.
#
# GAP must use the structure of e to perform calculations on g
# but not so with gisom. This can lead to speedier calculations
# on gisom than on g, but that is not guaranteed
# (the calculations may actually be slower on gisom than on g).
#
# You must have a retraction \nu^f for this option to do anything.
#
# Warning: This can be computationally expensive, but likely will not be.
#

#	creategisom := true;;

#
# The code below generates:
# 
#	- The split extension e = < a, x : a^n, w >
#
#	- The subgroup s = < a >
#
#	- (optional) The coset table M of the right action of
# 	  a and x on the cosets of s
#
#	- (optional) The subgroup
#	  g = < xa^-f, axa^-f-1, ... , a^(n-1)xa^-f-(n-1) >
#	  as the kernel of the retraction \nu^f
#
#	- (optional) The group gisom = < gens : rels > isomorphic to g
#	  but unrelated in GAP to e.
#	  gens and rels are determined by GAP automatically.
#
# The letters a and x are assigned to refer to the generators of the group e.
#
# This should not be edited unless you know what you are doing.
#

	Unbind(e);; Unbind(a);; Unbind(x);; Unbind(s);; Unbind(g);;
	Unbind(giso);; Unbind(gisom);; Unbind(M);;
	free := FreeGroup("a","x");;
	a := free.1;; x := free.2;;
	e := free/[a^n,EvalString(w)];;
	Unbind(free);;
	a := e.1;; x := e.2;;
	s := Subgroup(e,[a]);;
	if IsBound(f) then
		ggens := [];;
		for i in [0..n-1] do
			Add(ggens, a^i*x*a^-(i+f));;
		od;;
		g := Subgroup(e,ggens);;
		Unbind(ggens);;
		shiftg := ConjugatorIsomorphism(g,a^-1);;
		Unbind(ggens);;
		Unbind(shiftggens);;
		if IsBound(creategisom) then
			giso := IsomorphismFpGroup(g);;
			gisom := Image(giso);;
		fi;;
	fi;;
	Unbind(creategisom);;
	if IsBound(createunifiedlist) then
		if IsBound(f) then
			U:=MakeUnified(CosetTable(e,s),n,f);;
		else
			U:=MakeUnified(CosetTable(e,s),n);;
		fi;
	fi;;
	Unbind(createunifiedlist);;

#
# These commands are part of the 'Read( ... );' protection of this file.
#
#
# This should not be edited unless you know what you are doing.
#

	grouptemplatereadprotection := true;;
else
	Print("\nWARNING: You have already Read( ... ) this file into GAP!\n\n",
	"You must execute the command 'Unbind(grouptemplatereadprotection);'\n",
	"before GAP will Read( ... ) this file again.\n ");;
fi;;
