From: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Fri, 17 Apr 2009 08:38:05 -0400
Message-ID: <20090417123805.GC7117__49653.2515543096$1239977352$gmane$org@mit.edu>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-10-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239740480-28125-10-git-send-email-righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 14, 2009 at 10:21:20PM +0200, Andrea Righi wrote:
> Delaying journal IO can unnecessarily delay other independent IO
> operations from different cgroups.
> 
> Add BIO_RW_META flag to the ext3 journal IO that informs the io-throttle
> subsystem to account but not delay journal IO and avoid potential
> priority inversion problems.

So this worries me for two reasons.  First of all, the meaning of
BIO_RW_META is not well defined, but I'm concerned that you are using
the flag in a manner that in a way that wasn't its original intent.
I've included Jens on the cc list so he can comment on that score.

Secondly, there are many more locations than these which can end up
causing I/O which will ending up causing the journal commit to block
until they are completed.  I've done a lot of work in the past few
weeks to make sure those writes get marked using BIO_RW_SYNC.  In
data=ordered mode, the journal commit will block waiting for data
blocks to be written out, and that implies you really need to treat as
high priority all of the block writes that are marked with the
BIO_RW_SYNC flag.

The flip side of this is it may end up making your I/O controller to
leaky; that is, someone might be able to evade your I/O controller's
attempt to impose limits by using fsync() all the time.  This is a
hard problem, though, because filesystem I/O is almost always
intertwined.

What sort of scenarios and workloads are you envisioning might use
this I/O controller?  And can you say more about the specifics about
the priority inversion problem you are concerned about?

Regards,

						- Ted
