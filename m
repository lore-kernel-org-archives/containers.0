From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Tue, 28 Feb 2012 17:09:32 -0500
Message-ID: <20120228220932.GK9920@redhat.com>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com>
	<20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins>
	<20120223213847.GK19691@redhat.com>
	<20120223223457.GJ22536@google.com>
	<20120228211627.GH9920@redhat.com>
	<1330464100.11248.94.camel@twins>
	<20120228213526.GI9920@redhat.com>
	<1330466039.11248.103.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1330466039.11248.103.camel@twins>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 28, 2012 at 10:53:59PM +0100, Peter Zijlstra wrote:
> On Tue, 2012-02-28 at 16:35 -0500, Vivek Goyal wrote:
> > Yes this is how scheduler does to handle hierarchy. Treat task and group
> > at same level. 
> 
> ...
> 
> > Whether it is a good thing or bad thing, I don't know. 
> 
> That's IMO what the cgroupfs interface provides for, if you do anything
> different there's this shadow group that contains the tasks for which
> you then have to provide extra parameter control.
> 
> Furthermore, by treating tasks and groups at the same level you can
> create the extra group, but you can't do the reverse. So its the more
> versatile solution as well.

Agreed that it is more versatile. And one can move all the tasks to a
new group to achieve what a shadow group will do.

The only thing is what is a good default. If we are thinking of dividing
resources in terms of % and writing a user space tool, then in default
model we just don't know what's the %. May be it is dynamically varying
% and should be shown accordingly.

Or if idea of minimum % proportional bandwidth is more natural, then 
we shall have to change userspace and things like systemd to not run
any task in /. Then a user space tool can go through cgroup hierarchy
and calculate minimum % share of a group and display it.

> 
> > I think previous
> > design was allocating a group for every user. I guess, in that case we
> > will have fixed % share of each user (until and unless users are created/
> > removed). 
> 
> Not even, it depended on if the user had anything runnable or not. It
> was very much like the current cgroup stuff if you create a cgroup for
> each user and stick the tasks in.
> 
> The cpu-cgroup stuff is purely runnable based, so every wakeup/sleep
> changes the entire weight distribution, yay! :-)

:-). That's fine. If a group is not using its bandwidth because there is
no runnable task, then other groups get more cpu. I thought that's the 
proportional definition.

Thanks
Vivek
