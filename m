From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] fanotify: Add pids to events
Date: Sat, 16 Jan 2010 19:44:04 -0800
Message-ID: <20100117034403.GB3714__33324.9863157564$1263699905$gmane$org@count0.beaverton.ibm.com>
References: <20091202141452.12819.93536.stgit@paris.rdu.redhat.com>
	<201001151612.10032.agruen@suse.de>
	<20100115212146.GA3714@count0.beaverton.ibm.com>
	<201001162353.45800.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201001162353.45800.agruen-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andreas Gruenbacher <agruen-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Jan 16, 2010 at 11:53:45PM +0100, Andreas Gruenbacher wrote:
> On Friday 15 January 2010 10:21:46 pm Matt Helsley wrote:
> > On Fri, Jan 15, 2010 at 04:12:09PM +0100, Andreas Gruenbacher wrote:
> > > > 2. If the event recipient does a clone and enters a new pidns the pid
> > > > number will be incorrect without any indication.
> > >
> > > No, if a process has a pid within the listener's namespace the listener
> > > will see this pid; otherwise, the resulting pid value is 0.
> > 
> > So the pid reference is resolved at read(), correct? If so then that's
> >  fine. (Otherwise I'd think the values could still become stale).
> 
> Yes.  Note that for non-blocking events, there is no guarantee that the 
> triggering process still runs when the event is consumed though.

Holding the reference until the event is read ensures the pid
won't be reused in that namespace, so I think that's fine.

Cheers,
	-Matt Helsley
