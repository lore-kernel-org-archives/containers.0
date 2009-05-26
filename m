From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Tue, 26 May 2009 08:16:44 -0500
Message-ID: <20090526131644.GA20920__36374.6225172237$1243343607$gmane$org@hallyn.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1242968132-1044-18-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Introduction
> ------------
> Checkpoint/restart (C/R from now) allows to dump group of processes to disk
> for various reasons like saving process state in case of box failure or
> restoration of group of processes on another or same machine later.
> 
> Unlike, let's say, hypervisor C/R style which only needs to freeze guest kernel
> and dump more or less raw pages, proposed C/R doesn't require hypervisor.
> For that C/R code needs to know about all little and big intimate kernel details.
> 
> The good thing is that not all details needs to be serialized and saved
> like, say, readahead state. The bad things is still quite a few things
> need to be.

Hi Alexey,

the last time you posted this, I went through and tried to discern the
meaningful differences between yours and Oren's patchsets.  Then I sent some
patches to Oren to make his set configurable to act more like yours.  And Oren
took them!  But now you resend this patchset with no real changelog, no
acknowledgment that Oren's set even exists - or is much farther along and
pretty widely reviewed and tested (which is only because he started earlier
and, when we asked for your counterpatches at an earlier stage, you would never
reply) - or, most importantly, what it is that you think your patchset does
that his does not and cannot.  *Why* are you spending your time on this instead
of helping with Oren's set?  The code really isn't all that different...  Maybe
you just think that two independently written patchsets will expose more
gotchas that we'll need to catch, so you're continuing on this effort under the
expectation that eventualy we'll merge the two sets?

Honestly, I have great respect for your coding abilities.  And if 'voices
from on high' tell us to base upon your code, I'd be fine with that, I
have no real problems with what I see on yet another cursory look.  But
given the amount of collective time that's been spent developing, reviewing,
and testing Oren's set, it wouldn't make any sense to just jump.  So
I'd still just like to know how you see this proceeding.

thanks,
-serge
