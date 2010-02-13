From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] Syslog are now containerized
Date: Sat, 13 Feb 2010 14:33:06 -0800
Message-ID: <20100213223306.GB3714@count0.beaverton.ibm.com>
References: <201002110552.o1B5qwbL024561@kernel.safe.ca>
	<20100211174843.GF6884@us.ibm.com>
	<20100213181158.GY3714@count0.beaverton.ibm.com>
	<1266088499.19130.295.camel@Mercier.safe.ca>
	<20100213203610.GA3714@count0.beaverton.ibm.com>
	<1266098176.19130.320.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1266098176.19130.320.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Feb 13, 2010 at 04:56:16PM -0500, Jean-Marc Pigeon wrote:
> Hello,
> 
> [...]
> > Tracking all of these accesses down and ensuring they are only done
> > from "its container context" is difficult or impossible. It's not as
> > easy as you seem to think. In some cases the same resource could be
> > shared between containers. Which should we access it from then?
> 
> 	How come?! ressources (a device, Iptable rules,...)

Because it's kernel code. Kernel code implements interrupt handlers,
schedules processes, and even does work inside kernel threads. We
can't guarantee that some of the work initiated by a process is
always done with current == <the process>. Hence ensuring that
these accesses are only done from "its container context" is not
reasonable. The best we can do is ensure that accesses from the
processes in the container are contained.

> 	containerized within one container could be shared by 
> 	another unrelated container?.

Yes. namespace boundaries only coincide if userspace chooses to
make them coincide. For example, the tasks in a network namespace
do not necessarily all share the same mount namespace.

> 	Does this means (simple example) someone change
> 	iptable rules for one container that could change 
> 	another unrelated container behavior ?!...no way...

Two "unrelated containers" would share the same iptables rules
so long as they share a network namespace.

<snip>

> > > 	My proposal is a clear cut, if a ressource is containerized 
> > > 	report to CONT: (containerized) syslog... no question ask.
> > 
> > That part of the proposal is simple and makes alot of sense. The
> > ramifcations of it on kernel code are not simple and often there's
> > no clean way to do it.
> 	Well, this trouble me somewhat....
> 	2.6.18-128.2.1.el5.028stab064.7 (just an example, I am using
> 	day to day), is containerising iptables an other syslogs 
> 	nice way....,

Er.. you have a 2.6.18 kernel "containerising iptables an other syslogs"?
I didn't think iptables supported network namespaces until somewhat
recently. Is this an openvz-patched kernel you're talking about?

> 	We are now 2.6.33 you are telling me what was experimented,
> 	learned, monthssss ago can't still be implemented 
> 	in current kernel main stream?.... 

Careful. "no clean way to do it" does not mean "can't be done".

Cheers,
	-Matt Helsley
