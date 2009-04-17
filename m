From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: C/R without "leaks"
Date: Fri, 17 Apr 2009 05:48:09 -0400
Message-ID: <49E85059.8070400@cs.columbia.edu>
References: <49E40662.2040508@cs.columbia.edu>	 <20090414163633.GE27461@x200.localdomain>	 <49E4D89D.9060903@cs.columbia.edu>	 <20090415195629.GD26994@x200.localdomain> <1239835337.6610.6.camel@bahia>	 <20090416161215.GA8505@x200.localdomain> <49E774B1.5060505@nortel.com>	 <49E77B49.3020102@cs.columbia.edu> <1239959746.6143.66.camel@bahia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760682AbZDQJuq@vger.kernel.org>
In-Reply-To: <1239959746.6143.66.camel@bahia>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: Chris Friesen <cfriesen@nortel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org



Greg Kurz wrote:
> On Thu, 2009-04-16 at 14:39 -0400, Oren Laadan wrote:
>> Any connection in that case is, of course, lost, and it's up to the
>> application to do something about it. If the application relies on
>> the state of the connection, it will have to give up (e.g. sshd, and
>> ssh, die).
>>
> 
> And that's a good thing since that's exactly what users expect from
> sshd : to give up the connection when something goes wrong. I wouldn't
> trust a sshd with the ability to initiate connections on its own...
> 
> And anyway, I still don't see the scenario where C/R a sshd is useful...

You mean an sshd with an open connection probably; the server itself
is clearly useful to be able to c/r.

> Please someone (Alexey ?), provide a detailed use case where people
> would want to checkpoint or migrate live TCP connections... Discussion
> on containers@ is very interesting but really lacks of
> what-is-the-bigger-picture arguments... These huge patchsets are very
> tricky and intrusive... who wants them mainline ? what's the use of
> C/R ?
> 

A canonical example would a virtual-private-server: instead of doing
server consolidation with a virtual machine, your do with containers.
In a sense, containers lets you chop the OS into independent isolated
pieces. You ca use a linux box to run multiple virtual execution
environments (containers), each running services of your choice. They
could range from a sshd for users, to apache servers, to database
servers to users' vnc sessions, etc.

Now comes the that you really need to take the machine down, for
whatever reason. With c/r of live connections you can live-migrate
these containers to another machine (on the same subnet) that will
"steal" the IP as well, and voila - no service disruption.

Such scenarios are the focus of Alexey.

I'm also very interested in these scenarios, and I'm _also_ thinking
of other scenarios, where either (a) an entire container is not
necessary (example: user running long computation on laptop and wants
to save it before a reboot), or (b) the program would like to make
adjustments to its state compared to the time it was saved (example:
change the location of an output log file depending on the machine
on which your are running).

Unfortunately, if we plan for and require, as per Alexey, that c/r
would only work for whole-containers, these two cases will not be
addressed.

Oren.

>> However, there are many application that can withstand connection
>> lost without crashing. They simply retry (web browser, irc client,
>> db clients). With time, there may be more applications that are
>> 'c/r-aware'.
>>
> 
> HPC jobs are definitely good candidates.
> 
>> Moreover, in some cases you could, on restart, use a wrapper to
>> create a new connection to somewhere (*), then ask restart(2) to
>> use that socket instead of the original, such that from the user
>> point of view things continue to work well, transparently.
>>
> 
> Yes.
> 
>> (*) that somewhere, could be the original peer, or another server,
>> if it has a way to somehow continue a cut connection, or a special
>> wrapper server that you right for that purpose.
>>
>> Oren.
>>
