From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: ckpt-v20-dev, ckpt-v21-rc1
Date: Thu, 1 Apr 2010 14:15:26 -0700
Message-ID: <20100401211526.GU3345@count0.beaverton.ibm.com>
References: <4BB1997B.1010901@cs.columbia.edu>
	<20100331173339.GA19371@us.ibm.com>
	<4BB42FBB.8030206@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BB42FBB.8030206-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 01, 2010 at 01:31:39AM -0400, Oren Laadan wrote:
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >> I pulled all the recent patches in linux-cr (except for ipv6 fixup
> >> set), and created the following two branches:
> >>
> >> ckpt-v20-dev - patches applied onto pof v20
> >> ckpt-v21-rc1 - patches folded into a clean patchset
> >>
> >> Likewise with user-cr (but with more exceptions - working now on
> >> pulling more patches in).
> >>
> >> This is totally untested except for successful compilation...
> >>
> >> Oren.
> > 
> > v21 with the recent patches applied seems rock-solid to me, on
> > x86-64, s390x, and powerpc.
> > 
> > recent patches means:
> > 	skip down interfaces v2,
> > 	put fops->checkpoint under ifdef
> > 	get rid of ckpt_hdr_vpids,
> > 	export net checkpoint fns
> > 
> > for kernel and
> > 
> > 	Add --nonetns switch to user-cr checkpoint
> > 	fix vpids
> > 	user-c/r: get rid of ckpt_hdr_vpids
> > 
> > to user-cr#ckpt-v20-dev
> 
> 
> I pushed linux-cr:ckpt-v21-rc2 with:
> 
> > 	skip down interfaces v2,
> > 	put fops->checkpoint under ifdef
> > 	get rid of ckpt_hdr_vpids,
> > 	export net checkpoint fns
> 
> and user-cr:ckpt-v20-dev with:
> 
> > 	fix vpids
> > 	user-c/r: get rid of ckpt_hdr_vpids
> plus Suka's two recent patches.
> 
> Dan's --nonetns is pending - see my reply.
> 
> > 
> > Do we want to try and incorporate Matt's patchset to clear out
> > linux-2.6/checkpoint/ next, or ship what we have?
> 
> IIRC there is at least one more comment from fsdevel that I need
> to address, need to dig into emails again (file_pos_ ?).
> 
> I hope to start tackling the transformation to matt's-format by
> tomorrow, and will see how fast it goes.

Well, my transformation doesn't touch eclone or the cgroup-freezer-related
patches so the initial 20 patches won't need to change.

It would be great if we could reduce the number of patches. Some ideas:

Can we push Dave's Namespace menu patch independently? I suspect it's
good enough even without c/r at this point.

The cgroup freezer fix patch has gone to Rafael. It only affects frozen
cgroups if we do:
	echo FROZEN > /cgroup/foo/freezer.state
	<suspend system>
	<resume system>  <-- unfreezes cgroup too!

I've only submitted patches via one tree and then "waited" patiently
-- can/should we drop this patch? My instinct is to trust the maintainers
to merge things properly and keep it so we don't get a cgroup freezer bug
report. But I would like to shorten the number of non-c/r patches in this
series...

Could Serge's "c/r: split core function out of some set*{u,g}id functions"
or "c/r: break out new_user_ns()" be considered code cleanups or
at all useful without c/r? If so, perhaps we can push those separately
and with c/r.

I think Nick's comments and the LWN article clearly suggest that
the current c/r code organization is a barrier to review. I didn't
get the impression that any of the patches added for v21 were complicated
enough to warrant another round of limited review amongst ourselves. The
longer we wait the harder it will be to do. So I think reorganizing the code
now, before v21 is the way to go.

Cheers,
	-Matt Helsley
