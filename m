From: Tomasz Buchert <Tomasz.Buchert-MZpvjPyXg2s@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: Freezing and task move race fix
Date: Wed, 11 Aug 2010 00:18:44 +0200
Message-ID: <4C61D044.2060703__30390.1166575544$1281478845$gmane$org@inria.fr>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
	<20100810215741.GC2927@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100810215741.GC2927-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Matt Helsley a =E9crit :
> On Tue, Aug 10, 2010 at 09:53:21PM +0200, Tomasz Buchert wrote:
>> Writing 'FROZEN' to freezer.state file does not
>> forbid the task to be moved away from its cgroup
>> (for a very short time). Nevertheless the moved task
>> can become frozen OUTSIDE its cgroup which puts
>> discussed task in a permanent 'D' state.
>>
>> This patch forbids migration of either FROZEN
>> or FREEZING tasks.
>>
>> This behavior was observed and easily reproduced on
>> a single core laptop. Program and instructions how
>> to reproduce the bug can be fetched from:
>> http://pentium.hopto.org/~thinred/repos/linux-misc/freezer_bug.c
> =

> Thanks for the report and the test code.
> =

> I'm will try to reproduce this race in the next few hours and analyze
> it since I'm not sure the patch really fixes the race -- it may only
> make the race trigger less frequently.
> =

> At the very least the patch won't break the current code since it's
> essentially a more-strict version of is_task_frozen_enough() -- it lets
> fewer tasks attach/detach to/from frozen cgroups.
> =

> Cheers,
> 	-Matt Helsley

Hi Matt!
I am a novice if it comes to the kernel and I find the cgroup_freezer
code especially complicated, so definetely this may be not enough to fix th=
at.
Notice also that if you uncomment the line 55 in my testcase this will also
trigger the race! This, however, makes sense since process may not be in th=
e cgroup anymore
and consequently won't be thawed.
I think that this patch fixes these problems because it does the flag check=
ing in a right order:
first freezing() is used and then frozen() which assures (see frozen_proces=
s()) that
the race will not happen. Right? :)

Tomasz
