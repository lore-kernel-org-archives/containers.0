From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cpuset: rcu_read_lock() to protect task_cs() even we
	don't dereference to task_cs()'s return value
Date: Sat, 22 Nov 2008 11:01:01 +0800
Message-ID: <492775ED.1040803__49646.0125818432$1227323185$gmane$org@cn.fujitsu.com>
References: <49267624.70305@cn.fujitsu.com>	
	<6599ad830811211105p711aebc3v85ffffbc399bdd6e@mail.gmail.com>
	<6599ad830811211107n141e6cb5n2abf14e59110d764@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830811211107n141e6cb5n2abf14e59110d764-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Fri, Nov 21, 2008 at 11:05 AM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> Wouldn't this be fixed by your patch that adds an rcu_read_lock() to
>> task_subsys_state() ?
>>
> 
> Sorry, your other patch actually adds the rcu_read_lock() to
> task_cgroup(). But adding an rcu_read_lock() to task_subsys_state()
> would also help here.

Adding an rcu_read_lock() to task_subsys_state() also help here.
But task_subsys_state() is used in fast path.

If we add an implicit rcu_read_lock() in task_subsys_state(),
we still need rcu_read_lock()/task_lock() for using it,
so it's redundant rcu_read_lock(), and slower the fast path a little.

Lai.
