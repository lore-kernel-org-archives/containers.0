From: =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Wed, 21 Jan 2009 22:29:20 -0800
Message-ID: <d6200be20901212229y47353d3ft72fbfed6ffaba999__43479.159838944$1232605878$gmane$org@mail.gmail.com>
References: <200901211638.23101.knikanth@suse.de>
	<200901221043.13684.knikanth@suse.de>
	<d6200be20901212139u3683c829x4db1840a28986a6f@mail.gmail.com>
	<200901221142.00803.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200901221142.00803.knikanth-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jan 21, 2009 at 10:12 PM, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wr=
ote:
> On Thursday 22 January 2009 11:09:45 Arve Hj=F8nnev=E5g wrote:
>> On Wed, Jan 21, 2009 at 9:13 PM, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
> wrote:
>> > To use oom_adj effectively one should continuously monitor oom_score of
>> > all the processes, which is a complex moving target and keep on adjust=
ing
>> > the oom_adj of many tasks which still cannot guarantee the order. This
>> > controller is deterministic and hence easier to use.
>>
>> Why not add an option to make oom_adj ensure strict ordering instead?
>
> This could be done in 2 ways.
> 1. Make oom_adj itself strict.(based on some other parameter?)
> - Adds to confusion whether the current oom_adj is a strict value or the =
usual
> suggestion.
> - It would disable the oom_adj suggestion which could have been used till=
 now.
> - It is a public interface, and changing that might break some one's scri=
pt.
>
> 2. Add addtional parameter, say  /proc/<pid>/oom_order
> - Not easy to use.
> - Say I had assigned the oom.victim to a task and it had forked a lot. No=
w to
> change the value for all the tasks it is easier with cgroups.
> - Some optimization that Kame specified earlier would be harder to achiev=
e.
>

Both options would work for us, but option 1 require no change to our
user space code. I agree that some operations are easier with a
cgroups approach, but since we don't perform these operations it would
be nice to not require cgroups to control the oom killer.

-- =

Arve Hj=F8nnev=E5g
