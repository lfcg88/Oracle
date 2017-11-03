var TREE_FORMAT =
[
//0. left position
	0,
//1. top position
	0,
//2. show +/- buttons
	true,
//3. couple of button images (collapsed/expanded/blank)
	["/admin/images/r_arrow.gif", "/admin/images/d_arrow.gif", "/admin/images/stretch.gif"],
//4. size of images (width, height,ident for nodes w/o children)
	[10,10,10],
//5. show folder image
	false,
//6. folder images (closed/opened/document)
	["/admin/images/r_arrow.gif", "/admin/images/d_arrow.gif", "/admin/images/stretch.gif"],
//7. size of images (width, height)
	[16,16],
//8. identation for each level [0/*first level*/, 16/*second*/, 32/*third*/,...]
	//[0,5,10,15],
	[0,16,32,48,64,80,96,112,124],
//9. tree background color ("" - transparent)
	"",
//10. default style for all nodes
	"navlink",
//11. styles for each level of menu (default style will be used for undefined levels)
	["navhead","navlink"],//["clsNodeL0","clsNodeL1","clsNodeL2","clsNodeL3","clsNodeL4"],
//12. true if only one branch can be opened at same time
	false,
//13. item padding and spacing
	[1,0],
/************** PRO EXTENSIONS ********************/
//14. draw explorer like tree ( identation will be ignored )
	false,
//15. Set of explorer images (folder, openfolder, page, minus, minusbottom, plus, plusbottom, line, join, joinbottom)
["images/folder.gif","images/folderopen.gif","images/page.gif","images/minus.gif","images/minusbottom.gif","images/plus.gif","images/plusbottom.gif","images/line.gif","images/join.gif","images/joinbottom.gif"],
//16. Explorer images width/height
	[19,16],
//17. if true state will be saved in cookies
	false,
//18. if true - relative position will be used. (tree will be opened in place where init() was called)
	true,
//19. width and height of initial rectangle for relative positioning
    [180,400],
//20. resize background //works only under IE4+, NS6+ for relatiive positioning
    true,
//21. support bgcolor changing for selected node
	false,
//22. background color for non-selected and selected node
	["#DDDDDD","#DDDDDD"]
];
