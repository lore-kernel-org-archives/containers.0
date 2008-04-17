From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix a race condition in manipulating tsk->cg_list
Date: Thu, 17 Apr 2008 13:27:07 +0800
Message-ID: <4806DFAB.8050307__15771.9157090925$1208410535$gmane$org@cn.fujitsu.com>
References: <4806C5EB.3040102@cn.fujitsu.com>	
	<6599ad830804162118g6b24d8ebq26b0d72133b0e19e@mail.gmail.com>	
	<4806DA6F.3000405@cn.fujitsu.com>	
	<20080416221655.c73d219f.akpm@linux-foundation.org>
	<6599ad830804162224s42ba221vea981fe34b30636a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830804162224s42ba221vea981fe34b30636a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Wed, Apr 16, 2008 at 10:16 PM, Andrew Morton
> <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>>  > > Maybe it would be better to not do a cgroup_exit() until we're
>>  > > unhashed, so that cgroup_enable_task_cg_list() can't find the exiting
>>  > > task?
>>
>>  So we won't be doing what Paul suggested?
>>
> 
> It's not as high a priority as Li's bug fix (which may be a good
> candidate for 2.6.25.1) but for the future I think I'll implement this
> distinguished css_set pointer for tasks that have finished
> cgroup_exit(), since I think it will make the similar synchronization
> in attach_task() cleaner, as well as cgroup_enable_task_cg_list().
> 

Yes, this approach sounds good to me. :)

> Paul
> 
