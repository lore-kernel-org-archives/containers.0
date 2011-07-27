From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Wed, 27 Jul 2011 15:26:39 -0700
Message-ID: <20110727222639.GD15501@count0.beaverton.ibm.com>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
	<CAOS58YPqLSYi2xECUk4O5GG3s6aokT=VykmkL6UnAOzyHXNAgQ@mail.gmail.com>
	<20110726225911.GF14808@count0.beaverton.ibm.com>
	<20110726234657.GD28497@mtj.dyndns.org>
	<20110727005341.GB15501@count0.beaverton.ibm.com>
	<20110727101228.GY2622@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110727101228.GY2622-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jul 27, 2011 at 12:12:28PM +0200, Tejun Heo wrote:
> Hello, Matt.
> 
> On Tue, Jul 26, 2011 at 05:53:41PM -0700, Matt Helsley wrote:
> > Good point. Hmm, is it possible nlink could change to/from 0 in some obscure
> > VFS code though? The cgroup freezer won't cover filesystem activity so
> > checkpoint would also have to freeze the filesystem using the fs
> > freezer..
> 
> nlink won't change by itself.  I think it more comes down to policy
> and framework decisions - the scope of CR'ing, how filesystems are
> snapshotted along and so on.  If those boundaries are well-defined,
> setting up mechanisms accordingly shouldn't be too difficult.

Yes, policy is a large part of how checkpoint deals with filesystems
and mount namespaces. For instance, with flink where do you link to?
Userspace could conceivably want to link to many places, or even
tradeoff between performance (flink) and simplicity (copying it all to the
same location). That's one reason I might prefer file handles -- they
could be more policy agnostic :).

> 
> > > You can determine whether search for another hardlink is necessary by
> > > looking at nlink.  Hmm... I wonder whether open_by_handle_at() can be
> > > used for this instead of scanning filesystem for matching inode
> > > number.  Screening by nlink should eliminate most cases but if
> > > open_by_handle_at() can deal with actual cases, it would be much
> > > better.
> > 
> > I briefly considered that and it might still be a good idea.
> > One reason I still went with relink is I was uncertain about what happens
> > to handles if the kernel reboots. If they become invalid then they don't
> > seem like a good candidate for checkpointing unlinked files.
> 
> Hmmm... I _think_ they're persistent but if not I think a better
> approach would be investigating why they aren't and update them so
> that they're useful for CR too.

Assuming that's possible and acceptable to others, sure.

> 
> > > Yeah, something like flink (like fstat for stat) should do it.  FS
> > > methods operate on dentries anyway so it can be added in the vfs layer
> > > proper if necessary.
> > 
> > Exactly. I worked on that for a little bit but the security questions
> > worried me and I haven't picked it back up since. If you or Pavel do pick
> > up the flink() solution I'd be happy to help review it since it'll probably
> > be something we can use too.
> 
> Yes, maybe, but the thing is that these are pretty much fringe case
> optimizations.  I'm not saying they aren't worth adding but that
> missing flink() or open_by_handle_at() support wouldn't hurt coverage
> all that much.

Fair enough for now.

> 
> I keep raising these similar points for two reasons.  First, CR
> doesn't have to be complete (however the 'completeness' is defined) to

I agree it doesn't have to be complete to be useful, but...

> be useful.  If CR works for most use cases with existing mechanisms,
> going forward with it would be already quite useful.  For HPC
> applications, the bar is quite low, actually.

the less complete CR is the more critical a (presumably userspace) method
for detecting and identifying what the source(s) of an incomplete CR is
(are). Otherwise we could try to checkpoint a hypothetical "cure for
cancer/save the world" HPC task only to discover the checkpoint is utterly
useless when we attempt to do a restart. Or, worse, it just quietly corrupts
the results! So even if we don't support checkpointing something we still
want to detect if it's being used.

Cheers,
	-Matt
