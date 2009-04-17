From: Greg Kurz <gkurz@fr.ibm.com>
Subject: Re: C/R without "leaks"
Date: Fri, 17 Apr 2009 11:15:46 +0200
Message-ID: <1239959746.6143.66.camel@bahia>
References: <49E40662.2040508@cs.columbia.edu>
	 <20090414163633.GE27461@x200.localdomain>
	 <49E4D89D.9060903@cs.columbia.edu>
	 <20090415195629.GD26994@x200.localdomain> <1239835337.6610.6.camel@bahia>
	 <20090416161215.GA8505@x200.localdomain> <49E774B1.5060505@nortel.com>
	 <49E77B49.3020102@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760013AbZDQJQR@vger.kernel.org>
In-Reply-To: <49E77B49.3020102@cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Chris Friesen <cfriesen@nortel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On Thu, 2009-04-16 at 14:39 -0400, Oren Laadan wrote:
> Any connection in that case is, of course, lost, and it's up to the
> application to do something about it. If the application relies on
> the state of the connection, it will have to give up (e.g. sshd, and
> ssh, die).
> 

And that's a good thing since that's exactly what users expect from
sshd : to give up the connection when something goes wrong. I wouldn't
trust a sshd with the ability to initiate connections on its own...

And anyway, I still don't see the scenario where C/R a sshd is useful...
Please someone (Alexey ?), provide a detailed use case where people
would want to checkpoint or migrate live TCP connections... Discussion
on containers@ is very interesting but really lacks of
what-is-the-bigger-picture arguments... These huge patchsets are very
tricky and intrusive... who wants them mainline ? what's the use of
C/R ?

> However, there are many application that can withstand connection
> lost without crashing. They simply retry (web browser, irc client,
> db clients). With time, there may be more applications that are
> 'c/r-aware'.
> 

HPC jobs are definitely good candidates.

> Moreover, in some cases you could, on restart, use a wrapper to
> create a new connection to somewhere (*), then ask restart(2) to
> use that socket instead of the original, such that from the user
> point of view things continue to work well, transparently.
> 

Yes.

> (*) that somewhere, could be the original peer, or another server,
> if it has a way to somehow continue a cut connection, or a special
> wrapper server that you right for that purpose.
> 
> Oren.
> 
-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
