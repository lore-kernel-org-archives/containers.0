From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Sat, 20 Nov 2010 13:08:13 -0500 (EST)
Message-ID: <4CE69B93.3050904@cs.columbia.edu>
References: <20101104164401.GC10656@sundance.ccs.neu.edu>
	<4CD3CE29.2010105@kernel.org>
	<20101106053204.GB12449@count0.beaverton.ibm.com>
	<20101106204008.GA31077@sundance.ccs.neu.edu>
	<4CD5D99A.8000402@cs.columbia.edu>
	<20101107184927.GF31077@sundance.ccs.neu.edu>
	<4CD72150.9070705@cs.columbia.edu> <4CE3C334.9080401@kernel.org>
	<20101117153902.GA1155@hallyn.com> <4CE3F8D1.10003@kernel.org>
	<20101119041045.GC24031@hallyn.com> <4CE683E1.6010500@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CE683E1.6010500-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Kapil Arya <kapil-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-3ImXcnM4P+0@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


login as: orenl
Using keyboard-interactive authentication.
Password:
Access denied
Using keyboard-interactive authentication.
Password:
Last login: Fri Nov 19 10:17:21 2010 from 192.117.42.81.static.012.net.il
499:takamine[~]$ pine
  PINE 4.64   COMPOSE MESSAGE                                                                     
Folder: Drafts  8 Messages  +

To      : Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc      : Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
          Kapil Arya <kapil-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>,
          Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>,
          linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
          xemul-3ImXcnM4P+0@public.gmane.org,
          "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
          Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Attchmnt:
Subject : Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
----- Message Text -----
Hi,

[continuation of posting regarding kernel vs userspace approach]

part I: perpsectice about the types of scopes of c/r in discussion
part II: linux-cr design adn objectives
part III: comparison kernel/userspace approaches


PART II:  ==PHILOSOPHY==

Linux-cr is a _generic_ c/r-engine with multiple capabilities. It can
checkpoint a full container, a process hierarchy, or a single process,
For containers, it provides guarantees like restart-ability; For the
others, it provides the flexibility so that c/r-aware applications,
libraries, helpers, and wrappers can glue what they wish to glue.

1) Transparent - completely transparent for container-c/r, and largely
  so for standalone-cr ("largely" - as in except for the glue which is
  needed due to loss of eco-system, not due to restarting).
2) Reliable - if checkpoint succeeds that it is guaranteed for
  to succeed too (for container-c/r).
3) Preemtptive - works without requiring that checkpointed processes
  be scheduled to run (and thus "collaborate")
4) Complete - covers all visible and hidden state in the kernel
  about processes (even if not directly visible to userspace)
5) Efficient - can be optimized along multiple axes: _zero_ impact on
  runtime, low downtime during checkpoint, partial and incremental
  checkpoint, live-migration, etc.
6) Flexible - can integrate nicely with different userspace "glueing"
  methods.
7) Maintainable - small part of the code is to refactor kernel code
  so that it can be reused in restart; the rest is new code that in
  our experience rarely changes. Same hods for the image format.

What linux-cr _does not_ do in the kernel, nor plans to support is:

1) Hardware devices: their state is per-device/vendor. Instead one
   should use virtual devices (VNC for dislpay, pulseaudio for sound,
   screen for ttys), or have a userspace glue to restore the state of
   the device. That said, in the future vendors may opt to provide
   logic for c/r in drivers, e.g. ->checkpoint, ->restart methods.
2) Userspace glue: (as defined for standalone-c/r above) the kernel
   knows about processes and their state, not about their intentions.
   We leave that for userspace.
3) External dependencies: (outside of the local host) the kernel does
   not control what's outside the host. That is the responsibility of
   userspace. (Even with live-migration, the linux-cr only restores
   the local state of the TCP connections).

Oren.
