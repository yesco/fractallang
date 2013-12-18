functor
import
   Browser
   Comp at '../lib/component.ozf'
export
   new: CompNew
   newArgs: CompNewArgs
define
   proc {FunPort1 IP Out NVar State Options}
      {Browser.browse Options.pre#IP#Options.post}
   end
   fun {CompNewArgs Args} Options in
      Options = {Record.adjoinList options(pre:'' post:'') {Record.toListInd Args}}
      {Comp.new comp(
		   inPorts(
		      port(name:input
			   procedure: FunPort1)
		      )
		   Options
		   )
      }
   end
   fun {CompNew}
      {CompNewArgs r()}
   end
end
      
   