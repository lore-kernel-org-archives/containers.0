From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] cgroup(fix critical bug): new handling for tasks file
Date: Mon, 8 Sep 2008 14:16:35 -0700
Message-ID: <20080908141635.3ce77adc.akpm__10356.348710093$1220908793$gmane$org@linux-foundation.org>
References: <48B360CE.2010501@cn.fujitsu.com>
	<6599ad830808251929p10dfc9d2ub11e4db0cd4f9f3@mail.gmail.com>
	<48B39319.7070403@cn.fujitsu.com>
	<6599ad830808261544w308a850m865ac0c0a1552c77@mail.gmail.com>
	<48B4D81D.2040200@cn.fujitsu.com>
	<6599ad830808270536i353e1807kaac4e9fb74301bb0@mail.gmail.com>
	<48B69582.4000208@cn.fujitsu.com> <48C0C4F7.2080702@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C0C4F7.2080702-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 04 Sep 2008 22:34:47 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

>  	npids = cgroup_task_count(cgrp);
> +	pidarray = kmalloc(npids * sizeof(pid_t), GFP_KERNEL);

kmalloc becomes more unreliable above 32 kbytes and 100% unreliable
above MAX_ORDER.
