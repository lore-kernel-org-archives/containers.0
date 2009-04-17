From: Greg Kurz <gkurz@fr.ibm.com>
Subject: Re: C/R without "leaks"
Date: Fri, 17 Apr 2009 14:25:21 +0200
Message-ID: <1239971121.6143.217.camel@bahia>
References: <49E40662.2040508@cs.columbia.edu>
	 <20090414163633.GE27461@x200.localdomain>
	 <49E4D89D.9060903@cs.columbia.edu>
	 <20090415195629.GD26994@x200.localdomain> <1239835337.6610.6.camel@bahia>
	 <20090416161215.GA8505@x200.localdomain> <49E774B1.5060505@nortel.com>
	 <49E77B49.3020102@cs.columbia.edu> <1239959746.6143.66.camel@bahia>
	 <49E85059.8070400@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760635AbZDQMfj@vger.kernel.org>
In-Reply-To: <49E85059.8070400@cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Chris Friesen <cfriesen@nortel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On Fri, 2009-04-17 at 05:48 -0400, Oren Laadan wrote:
> You mean an sshd with an open connection probably; the server itself
> is clearly useful to be able to c/r.
> 

Yes I mean C/R of sshd with active connections.

> 
> A canonical example would a virtual-private-server: instead of doing
> server consolidation with a virtual machine, your do with containers.
> In a sense, containers lets you chop the OS into independent isolated
> pieces. You ca use a linux box to run multiple virtual execution
> environments (containers), each running services of your choice. They
> could range from a sshd for users, to apache servers, to database
> servers to users' vnc sessions, etc.
> 

Indeed, containers allow to implement VPS just like virtual machines: we
call them system containers. Not much to say about that since they don't
introduce new concepts to users.

> Now comes the that you really need to take the machine down, for
> whatever reason. With c/r of live connections you can live-migrate
> these containers to another machine (on the same subnet) that will
> "steal" the IP as well, and voila - no service disruption.
> 

Theorically, yes. Practicaly, you need a lot more than *simply* capturing
and restoring socket states for such a migration to be usable in the real
world.

> 
> Such scenarios are the focus of Alexey.
> 

So Alexey should provide some realistic examples, with several hosts,
routers, switches and overall network infrastructure.

> I'm also very interested in these scenarios, and I'm _also_ thinking
> of other scenarios, where either (a) an entire container is not
> necessary (example: user running long computation on laptop and wants
> to save it before a reboot), or (b) the program would like to make
> adjustments to its state compared to the time it was saved (example:
> change the location of an output log file depending on the machine
> on which your are running).
> 

I'm _only_ interested in these other scenarios for the moment.

> Unfortunately, if we plan for and require, as per Alexey, that c/r
> would only work for whole-containers, these two cases will not be
> addressed.
> 

Discussion must go on then. There's no hurry in getting C/R
mainlined. :)

-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
