From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 5 Jun 2009 17:55:27 +0800
Message-ID: <20090605095527.GM11755__37693.3789033957$1244196030$gmane$org@balbir.in.ibm.com>
References: <20090604053649.GA3701@in.ibm.com>
	<6599ad830906050153i1afd104fqe70f681317349142@mail.gmail.com>
	<20090605093625.GI11755@balbir.in.ibm.com>
	<6599ad830906050248m2c569e5bx44fb3bbddf46f8b1@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830906050248m2c569e5bx44fb3bbddf46f8b1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

* menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> [2009-06-05 02:48:36]:

> On Fri, Jun 5, 2009 at 2:36 AM, Balbir Singh<balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >
> > The important scenario I have is adding and removing groups.
> >
> > Consider 10 cgroups with shares of 10 each, what if 5 new are created
> > with the same shares? We now start getting 100/15, even though we did
> > not change our shares.
> 
> Are you assuming that arbitrary users can create new cgroups whenever
> they like, with whatever shares they like? In that situation, how
> would you use hard limits to provide guarantees? Presumably if the
> user could create a cgroup with an arbitrary share, they could create
> one with an arbitrary hard limit too.
>

What about applications running as root, that can create their own
groups? How about multiple instances of the same application started?
Do applications need to know that creating a group will hurt
guarantees provided to others?
 
> Can you explain a bit more about how you're envisaging cgroups being
> created, and how their shares and hard limits would get set? I was
> working on the assumption that (for any sub-tree of the CFS hierarchy)
> there's a single managing entity that gets to decide the shares given
> to the cgroups within that tree. That managing entity would be
> responsible for ensuring that the shares given out allowed guarantees
> to be met (or alternatively, that the probability of violating those
> guarantees based on the shares given out was within some tolerance
> threshold).
>

The point is that there is no single control entity for creating
groups. if run a solution, it might create groups without telling the
user. No one is arbitrating, not even libcgroup. What if someone
changes the cpuset assignment and moves CPUS x to y in an exclusive
cpuset all of a sudden. How do we arbitrate?

 
-- 
	Balbir
