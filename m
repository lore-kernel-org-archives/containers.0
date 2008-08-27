From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup(fix critical bug): new handling for tasks file
Date: Wed, 27 Aug 2008 12:29:17 +0800
Message-ID: <48B4D81D.2040200__19835.4897242554$1219811665$gmane$org@cn.fujitsu.com>
References: <48B360CE.2010501@cn.fujitsu.com>	
	<6599ad830808251929p10dfc9d2ub11e4db0cd4f9f3@mail.gmail.com>	
	<48B39319.7070403@cn.fujitsu.com>
	<6599ad830808261544w308a850m865ac0c0a1552c77@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830808261544w308a850m865ac0c0a1552c77-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On Mon, Aug 25, 2008 at 10:22 PM, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> It's complicated than necessary and change too much code IMO.
> 
> What about the problem that maintaining a single pid array can still
> fail for a really large cgroup? I guess we could just say "don't
> create such large cgroups" but someone's bound to want to do that.
> Perhaps use an array of pages rather than a single large kmalloc?
> 

Actually, I had a plan to write such a patch:
[RFC PATCH] cgroup,cpuset: use alternative malloc instead of kmalloc

The main idea is: when allocate size >= PAGE_SIZE, vmalloc will be used
instead. This will reduce the stress when continuous pages are few.
Alternative malloc is used for cgroup_tasks_open() and update_tasks_nodemask().


And vmalloc can malloc larger memory than kmalloc, is vmalloc() enough?
If not, I think using an array of pages is the best choice.

[There are several subsystem who use alternative malloc. kernel/relay.c
for example. relay.c is also using an array of pages for relay buffer. ]


   Lai
