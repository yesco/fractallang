functor
import
   GraphModule at './graph.ozf'
export
   new: NewSubComponent
define
   /*
   A subcomponent is represented with a record like :.
   subcomponent(
      graph:(graph(inLinks:[name#destComp#destPortName name2#destComp2#destPortName2]
		   destComp:node(comp:<P/1> inPortBinded:[...])
		   destComp2:node(comp:<P/1> inPortBinded:[...])
		   outLinks:[name#destComp#destPortName ...]
		  ))
      inPorts:inPorts(
		 a:[<P/1>#a <P/1>#b]
		 b:[ ... ]
		 )
      outPorts:outPorts(
		  o:[<P/1>#out ...]))
   */
   fun {NewSubComponent Name Type FileName}
      Graph = {GraphModule.loadGraph FileName}
      Stream Point = {NewPort Stream}
      thread
	 {FoldL Stream
	  fun {$ State Msg}
	     case Msg
	     of getState(?Resp) then
		Resp = State
		State
	     [] send(InPort#N Msg Ack) then
		for X in State.inPorts.InPort do
		   {X.1 send(X.2#N Msg Ack)}
		end
		State
	     [] send(InPort Msg Ack) then
		for X in State.inPorts.InPort do A=_ in
		   {X.1 send(X.2 Msg A)}
		   {Wait A}
		end
		Ack = ack
		State
	     [] bind(OutPort#N Comp Name) then
		for X in State.outPorts.OutPort do
		   {X.1 bind(X.2#N Comp Name)}
		end
		State
	     [] bind(OutPort Comp Name) then
		for X in State.outPorts.OutPort do
		   {X.1 bind(X.2 Comp Name)}
		end
		State
	     [] unbound(OutPort N) then
		for X in State.outPorts.OutPort do
		   {X.1 unbound(X.2 N)}
		end
		State
	     [] addinArrayPort(Port Index) then
		for X in State.inPorts.Port do
		   {X.1 addinArrayPort(X.2 Index)}
		end
		State
	     [] start then
		{GraphModule.start State.graph}
		State
	     [] startUI then
		{GraphModule.startUI State.graph}
		State
	     [] stop then
		{GraphModule.stop State.graph}
		State
	     %% Help methods
	     [] renameInPort(OName NName) then 
		{Record.adjoinAt State inPorts {Rename State.inPorts OName NName}}
	     [] renameOutPort(OName NName) then
		{Record.adjoinAt State outPorts {Rename State.outPorts OName NName}}
	     end
	  end
	  {Init Name Type Graph}
	  _
	 }
      end
   in
      proc {$ Msg} {Send Point Msg} end
   end
   fun {Init Name Type G}
      InPorts = {FoldL G.inLinks
		 fun {$ Acc Name#CompName#PortName}
		    if {List.member Name {Arity Acc}} then
		       {Record.adjoinAt Acc Name G.nodes.CompName.comp#PortName|Acc.Name}
		    else
		       {Record.adjoinAt Acc Name G.nodes.CompName.comp#PortName|nil}
		    end
		 end
		 inPorts
		}
      OutPorts = {FoldL G.outLinks
		  fun {$ Acc Name#CompName#PortName}
		     if {List.member Name {Arity Acc}} then
			{Record.adjoinAt Acc Name G.nodes.CompName.com#PortName|Acc.Name}
		     else
			{Record.adjoinAt Acc Name G.nodes.CompName.comp#PortName|nil}
		     end
		  end
		  outPorts
		  }
   in
      subcomponent(name:Name type:Type inPorts:InPorts outPorts:OutPorts graph:G)
   end
   fun {Rename Rec OName NName} Temp in
      Temp = {Record.adjoinAt Rec NName Rec.OName}
      {Record.subtract Temp OName}
   end
end
      