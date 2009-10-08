From: Mathieu Lacage <mathieu.lacage-0GlwE4rufLnvuXihggDW+w@public.gmane.org>
Subject: time virtualization
Date: Thu, 08 Oct 2009 14:16:05 +0200
Message-ID: <1255004165.13367.153.camel@diese.inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

hi,

I recently went through my email backlog for the containers ML and
noticed this email from Serge:
https://lists.linux-foundation.org/pipermail/containers/2009-October/021226.html

which mentions "time virtualization". I suspect that this refers to
semantics similar to the semantics present in:
http://lkml.indiana.edu/hypermail/linux/kernel/0604.1/1223.html
https://lists.linux-foundation.org/pipermail/containers/2009-July/019602.html

Although I have no resources to offer for implementation for now, I
thought that it might be interesting to discuss other possible uses for
"time virtualization" which require different semantics. So, here is a
small dump of what I would be interested in doing:

A not-too-old paper outlines a nice approach to emulation of networks:
http://ds.informatik.rwth-aachen.de/members/weingaertner/publications/pdfs/hotmetrics08_shortened.pdf
They modify XEN to allow different VMs to have a different view on time:
each VM synchronizes with an external time source which can dynamically
and arbitrarily slow down, speed up, or simply keep pace with the
physical host clock, depending on what the user wants to achieve.

I have been using network namespaces for a while to build some simple
network emulation testbeds and I would be really interested in extending
this to include virtualization of time on a container basis in a way
similar to the one outlined above to be able to synchronize a number of
netns containers running on the same host but also potentially on
separate physical hosts, and, potentially, with a network simulator.
This would allow me to control more precisely how 'accurate' the
emulation is.

The above requires at least the applications but also the kernel network
stack to use the same time counters so, it's not clear to me how this
could play with the patch posted in 2006 which merely changes the
semantics of gettimeofday. i.e., a number of potential issues come to
mind:
  - what happens if an application specifies a timeout to a syscall ? It
should still work if the difference between the host clock and the
virtualized clock is a simple offset but, if the rate of the guest clock
changes, it will break.
  - what happens if a guest network stack starts a timer and the rate of
the guest clock changes ? 

In both of these cases, the above-mentioned paper deals with this by
changing the clock as seen by the OS (by changing the hardware clock
exported by the XEN hypervisor to a guest), as opposed to the clock as
seen by the application within the container (which is done in the
patches posted). I suspect that similar results could be obtained by
using a special clocksource which is namespace-aware and changes its
behavior based on the current active namespace. I guess that the concept
of an "active namespace" is not very clear though. i.e., while it's easy
to associate a namespace to each application, I don't see how kernel
code executing outside process context could know this.

Clearly, I don't really know much about this: it could well be that this
is not implementable at the namespace layer and that the real solution
is to use a full VM (or UML, or whatever) but, it sure would be really
cool to be able to specify arbitrary clock sources on a per-container
basis.

Please, shoot me down into flames :)

Mathieu
