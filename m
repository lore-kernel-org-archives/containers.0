From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 5 Jun 2009 17:36:25 +0800
Message-ID: <20090605093625.GI11755__39012.4578182169$1244194934$gmane$org@balbir.in.ibm.com>
References: <20090604053649.GA3701@in.ibm.com>
	<6599ad830906050153i1afd104fqe70f681317349142@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830906050153i1afd104fqe70f681317349142-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

* menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> [2009-06-05 01:53:15]:

> On Wed, Jun 3, 2009 at 10:36 PM, Bharata B
> Rao<bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > - Hard limits can be used to provide guarantees.
> >
> 
> This claim (and the subsequent long thread it generated on how limits
> can provide guarantees) confused me a bit.
> 
> Why do we need limits to provide guarantees when we can already
> provide guarantees via shares?
> 
> Suppose 10 cgroups each want 10% of the machine's CPU. We can just
> give each cgroup an equal share, and they're guaranteed 10% if they
> try to use it; if they don't use it, other cgroups can get access to
> the idle cycles.
> 
> Suppose cgroup A wants a guarantee of 50% and two others, B and C,
> want guarantees of 15% each; give A 50 shares and B and C 15 shares
> each. In this case, if they all run flat out they'll get 62%/19%/19%,
> which is within their SLA.
> 
> That's not to say that hard limits can't be useful in their own right
> - e.g. for providing reproducible loadtesting conditions by
> controlling how much CPU a service can use during the load test. But I
> don't see why using them to implement guarantees is either necessary
> or desirable.
> 
> (Unless I'm missing some crucial point ...)

The important scenario I have is adding and removing groups.

Consider 10 cgroups with shares of 10 each, what if 5 new are created
with the same shares? We now start getting 100/15, even though we did
not change our shares.

-- 
	Balbir
