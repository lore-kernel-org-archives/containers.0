From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 11:42:00 +0530
Message-ID: <200901221142.00803.knikanth__4365.38247527114$1232605095$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<200901221043.13684.knikanth@suse.de>
	<d6200be20901212139u3683c829x4db1840a28986a6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d6200be20901212139u3683c829x4db1840a28986a6f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 22 January 2009 11:09:45 Arve Hj=F8nnev=E5g wrote:
> On Wed, Jan 21, 2009 at 9:13 PM, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> =

wrote:
> > To use oom_adj effectively one should continuously monitor oom_score of
> > all the processes, which is a complex moving target and keep on adjusti=
ng
> > the oom_adj of many tasks which still cannot guarantee the order. This
> > controller is deterministic and hence easier to use.
>
> Why not add an option to make oom_adj ensure strict ordering instead?

This could be done in 2 ways.
1. Make oom_adj itself strict.(based on some other parameter?)
- Adds to confusion whether the current oom_adj is a strict value or the us=
ual =

suggestion. =

- It would disable the oom_adj suggestion which could have been used till n=
ow. =

- It is a public interface, and changing that might break some one's script.

2. Add addtional parameter, say  /proc/<pid>/oom_order
- Not easy to use.
- Say I had assigned the oom.victim to a task and it had forked a lot. Now =
to =

change the value for all the tasks it is easier with cgroups.
- Some optimization that Kame specified earlier would be harder to achieve.

Basically oom-controller implements option 2, using cgroups which can be =

thought of as a modern interface for proc. Also it could be used along with =

other cgroup controllers like the group scheduler. Say you have 2 groups of =

tasks, clubed as entertainment and science, you could use the group schedul=
er =

to give more CPU bandwidth to science and instruct oom-controller to kill =

entertainment tasks in case of OOM situation.

Thanks
Nikanth
