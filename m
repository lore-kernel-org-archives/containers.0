From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: ckpt-v20-dev, ckpt-v21-rc1
Date: Thu, 1 Apr 2010 09:17:40 -0500
Message-ID: <20100401141740.GB22648@us.ibm.com>
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

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
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

Alas after I sent this Nathan reported trouble on x86.  I haven't
gotten a x86-32 partition running yet so can't reproduce.  Does
anyone else have x86-32 with f12 they can test on?

-serge
