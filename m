From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R v20][PATCH 00/96] Linux Checkpoint-Restart - v20
Date: Thu, 1 Apr 2010 18:37:10 -0500
Message-ID: <20100401233710.GA23711__15038.103881716$1270165115$gmane$org@us.ibm.com>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1268842164-5590-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Hi Andrew,
> 
> Following up on the thread on the checkpoint-restart patch set
> (http://lkml.org/lkml/2010/3/1/422), the following series is the
> latest checkpoint/restart, based on 2.6.33.
> 
> The first 20 patches are cleanups and prepartion for c/r; they
> are followed by the actual c/r code.
> 
> Please apply to -mm, and let us know if there is any way we can
> help.

Hi Andrew,

Oren sent v20 of the checkpoint/restart patchset out two weeks ago.
We've addressed some feedback from linux-fsdevel and added network and
pid namespace support.  So we could resend again now.  However we also
have a bigger patchset in the works which is feature-neutral, but moves
all the code out of linux-2.6/checkpoint/ and next to the code it
affects.  I ancitipate #ifdef clashes though, so we'll
need to do quite a bit of various-config-and-arch testing of the new
code layout.  If you're at a good point to pull it, we can resend the
code as is now so as to get some wider testing exposure. Or, if you prefer,
we can wait until after the code move in case that would be seen as more
amenable to meaningful review.

We don't want to patch-bomb needlessly so thought we'd ask first :)

thanks,
-serge
