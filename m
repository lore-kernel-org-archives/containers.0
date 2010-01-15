From: Andreas Gruenbacher <agruen-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 2/4] fanotify: Add pids to events
Date: Fri, 15 Jan 2010 16:12:09 +0100
Message-ID: <201001151612.10032.agruen@suse.de>
References: <20091202141452.12819.93536.stgit@paris.rdu.redhat.com>
	<20091202141458.12819.96170.stgit@paris.rdu.redhat.com>
	<6a12d2f31001142041j7f917b07l1e1a728790175321@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6a12d2f31001142041j7f917b07l1e1a728790175321-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matthew Helsley <matt.helsley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Friday 15 January 2010 05:41:10 Matthew Helsley wrote:
> Eric, you never replied to my point about pid namespaces
> (http://lkml.org/lkml/2009/7/1/2). I'm still concerned that it's a
> problem for this patch. I've cc'd some pid namespace folks, listed the
> problems, and some alternative solutions (where I could think of any)
> below:
> 
> 1. Since fanotify doesn't hold a reference to the struct pid then the
> pid can become stale before the event is acted upon.
>     solution a: Just ignoring this problem, like other interfaces
> often do, is probably ok.
>     ... ?
>     solution z: Seems to require taking a reference to the pid and
> giving userspace a way to drop the reference after it's done using
> this value to refer to the process (yuck).

struct fsnotify_event->tgid does hold a reference to the appropriate struct 
pid.  The reference is released when that struct fsnotify_event is freed.

> 2. If the event recipient does a clone and enters a new pidns the pid
> number will be incorrect without any indication.

No, if a process has a pid within the listener's namespace the listener will 
see this pid; otherwise, the resulting pid value is 0.

> 3. If the listening process is not in the same or an ancestor pid
> namespace of the triggering process then there is no correct pid
> corresponding to the event.

Indeed, if the listener is not in the same or an ancestor pid namespace, the 
pid in the event will end up as 0.  The event still indicates that something 
has happened to a file the listener is interested in though, it's just unclear 
who triggered the event.  I don't see a problem with that though -- do you?

Thanks,
Andreas
