From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Thu, 12 Mar 2009 10:09:36 -0400
Message-ID: <20090312140936.GF10919__19805.6498579264$1236867451$gmane$org@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<1236853490.5090.140.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1236853490.5090.140.camel@laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Mar 12, 2009 at 11:24:50AM +0100, Peter Zijlstra wrote:
> On Wed, 2009-03-11 at 21:56 -0400, Vivek Goyal wrote:
> > +Going back to old behavior
> > +==========================
> > +In new scheme of things essentially we are creating hierarchical fair
> > +queuing logic in elevator layer and changing IO schedulers to make use of
> > +that logic so that end IO schedulers start supporting hierarchical scheduling.
> > +
> > +Elevator layer continues to support the old interfaces. So even if fair queuing
> > +is enabled at elevator layer, one can have both new hierarchical scheduler as
> > +well as old non-hierarchical scheduler operating.
> > +
> > +Also noop, deadline and AS have option of enabling hierarchical scheduling.
> > +If it is selected, fair queuing is done in hierarchical manner. If hierarchical
> > +scheduling is disabled, noop, deadline and AS should retain their existing
> > +behavior.
> > +
> > +CFQ is the only exception where one can not disable fair queuing as it is
> > +needed for providing fairness among various threads even in non-hierarchical
> > +mode.
> > +
> > +Various user visible config options
> > +===================================
> > +CONFIG_IOSCHED_NOOP_HIER
> > +       - Enables hierchical fair queuing in noop. Not selecting this option
> > +         leads to old behavior of noop.
> > +
> > +CONFIG_IOSCHED_DEADLINE_HIER
> > +       - Enables hierchical fair queuing in deadline. Not selecting this
> > +         option leads to old behavior of deadline.
> > +
> > +CONFIG_IOSCHED_AS_HIER
> > +       - Enables hierchical fair queuing in AS. Not selecting this option
> > +         leads to old behavior of AS.
> > +
> > +CONFIG_IOSCHED_CFQ_HIER
> > +       - Enables hierarchical fair queuing in CFQ. Not selecting this option
> > +         still does fair queuing among various queus but it is flat and not
> > +         hierarchical.
> 
> One worry I have is that these are compile time switches. Is there any
> way you can get the old AS/DEADLINE back when these are enabled but
> you're not actively using cgroups?

Hi Peter,

In principle, if one is not using cgroups, there is only one io queue
in the root group and most likely we should achieve the same behavior
as old schedulers. Just that some extra code gets into execution at 
runtime.

I have not got a chance yet to do some numbers but I think this path
can be optimized enough that at run time effectively we don't see any 
significant performance penalty and behavior of schedulers is almost
same as old ones.

Thanks
Vivek 
