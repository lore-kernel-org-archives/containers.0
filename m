From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] CGroups: cgroup member list enhancement/fix
Date: Tue, 14 Jul 2009 13:34:10 -0400
Message-ID: <2f86c2480907141034r5a985cfue9e8fdf64ad28465__24713.9642517597$1247593146$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090705063850.GX11273@balbir.in.ibm.com>
	<6599ad830907101658i13e4046br70377a487dd6b49b@mail.gmail.com>
	<20090713121138.GC5051@balbir.in.ibm.com>
	<6599ad830907130926v7788af12hdcd76e4ccb3ab6de@mail.gmail.com>
	<20090714055638.GI5051@balbir.in.ibm.com>
	<6599ad830907132349u6cf52060t4fafb6637cbe4ed1@mail.gmail.com>
	<20090714071617.GK5051@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090714071617.GK5051-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jul 14, 2009 at 3:16 AM, Balbir Singh<balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> * menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> [2009-07-13 23:49:16]:
>> As a first cut, we were planning to add an rwsem that gets taken for
>> read in cgroup_fork(), released in cgroup_post_fork(), and taken for
>> write when moving an entire process to a new cgroup; not ideal
>> performance-wise, but safe.
>>
>> If adding a field to task_struct is an option, then the rwsem could be
>> per thread-group leader, which would reduce contention.

That would indeed help, but would only improve system-wide performance
in the case with write-contention (no improvement at all if, say, the
threadgroup is the only one forking, or when nobody is writing to the
procs file). While that's preferable to a global lock, if we can add a
field to task_struct, a (lockless) flag-based approach might be
possible.

> We should also document that moving large processes with several
> threads can be expensive.

Indeed. Or more specifically, that moving fast-growing threadgroups
can be expensive.
