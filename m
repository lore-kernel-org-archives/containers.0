From: "Brian K. White" <brian-goxB3+SAe6wAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 1/2] cgroups: read-write lock CLONE_THREAD forking
	per 	threadgroup
Date: Wed, 04 Aug 2010 12:34:57 -0400
Message-ID: <4C5996B1.7060507@aljex.com>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>	<20100730235754.GB22644@ghc17.ghc.andrew.cmu.edu>
	<AANLkTikpNG2Y3S3AyxAbCkMynKu1u5yKPrw=bh+uy=9R@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTikpNG2Y3S3AyxAbCkMynKu1u5yKPrw=bh+uy=9R-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


> As far as the #ifdef mess goes, it's true that some people don't have
> CONFIG_CGROUPS defined. I'd imagine that these are likely to be
> embedded systems with a fairly small number of processes and threads
> per process. Are there really any such platforms where the cost of a
> single extra rwsem per process is going to make a difference either in
> terms of memory or lock contention? I think you should consider making
> these additions unconditional.

openSUSE's default kernel* doesn't have CONFIG_CGROUPS

Personally I think it's a silly mistake also, since the argument was 
performance, and ubuntu's desktop kernel has it and actually outperforms 
openSUSE's, and the feature is perfectly likely to be needed by 
"desktop" users, but I wasn't and still aren't consulted on this and so 
it's a fact that must be lived with at least for a while. ;) (at least 
until the majority of 11.2 and 11.3 installations are replaced due to 
age, and that's if they reverted the decision today, which so far they 
haven't)

*("kernel-desktop" the one installed by default, not "kernel-default", 
which exists but is not installed by default since openSUSE 11.2)

-- 
bkw
