From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] CGroups: cgroup member list enhancement/fix
Date: Tue, 14 Jul 2009 10:43:56 -0700
Message-ID: <6599ad830907141043s1c16d5c9saad9118c210ecef4__5028.69437118552$1247593484$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090705063850.GX11273@balbir.in.ibm.com>
	<6599ad830907101658i13e4046br70377a487dd6b49b@mail.gmail.com>
	<20090713121138.GC5051@balbir.in.ibm.com>
	<6599ad830907130926v7788af12hdcd76e4ccb3ab6de@mail.gmail.com>
	<20090714055638.GI5051@balbir.in.ibm.com>
	<6599ad830907132349u6cf52060t4fafb6637cbe4ed1@mail.gmail.com>
	<20090714071617.GK5051@balbir.in.ibm.com>
	<2f86c2480907141034r5a985cfue9e8fdf64ad28465@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480907141034r5a985cfue9e8fdf64ad28465-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 14, 2009 at 10:34 AM, Benjamin Blum<bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> procs file). While that's preferable to a global lock, if we can add a
> field to task_struct, a (lockless) flag-based approach might be
> possible.
>

I've been trying to think of a way to do that. AFAICS the only way to
do that reliably would be to move the call to cgroup_fork() that hooks
into the parent's cgroup inside the lock on the group leader's thread
list, and move the fork callbacks into cgroup_fork(). (Which would
mean that they'd not be able to sleep/fail, etc).

Paul
