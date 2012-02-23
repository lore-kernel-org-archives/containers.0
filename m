From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Thu, 23 Feb 2012 07:45:26 +0000
Message-ID: <20120223074526.GA15835__26712.2387922884$1329983519$gmane$org@mail.hallyn.com>
References: <20120221211938.GE12236@google.com>
	<20120221212106.GF12236@google.com>
	<4F44EEE4.2000809@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F44EEE4.2000809-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> >>The support for multiple process hierarchies always struck me as
> >>rather strange.  If you forget about the current cgroup controllers
> >>and their implementations, the *only* reason to support multiple
> >>hierarchies is if you want to apply resource limits based on different
> >>orthogonal categorizations.
> >>

Right, the old lwn writeup took the same approach:
http://lwn.net/Articles/236038/

> >>Documentation/cgroups.txt seems to be written with this consideration
> >>on mind.  It's giving an example of applying limits accoring to two
> >>orthogonal categorizations - user groups (profressors, students...)
> >>and applications (WWW, NFS...).  While it may sound like a valid use
> >>case, I'm very skeptical how useful or common mixing such orthogonal
> >>categorizations in a single setup would be.

My first inclination is to agree, but counterexamples do come to mind.

I could imagine a site saying "users can run (X) (say, ftpds), but the
memory consumed by all those ftpds must not be > 10% total RAM".  At
the same time, they may run several apaches but want them all locked to
two of the cpus.

It might be worth a formal description of the new limits on use cases
such changes (both dropping support for orthogonal cgroups, and limiting
cgroups hierarchies to a mirror pstrees, separately) would bring.

To me personally the hierarchy limitation is more worrying.  There have
been times when I've simply created cgroups for 'compile' and 'image
build', with particular cpu and memory limits.  If I started a second
simultaneous compile, I'd want both compiles confined together.  (That's
not to say the simplification might not be worth it, just bringing up
the other side)

-serge
