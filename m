From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCHSET] fix CGROUP VS RCU
Date: Fri, 21 Nov 2008 17:10:21 +0800
Message-ID: <49267AFD.8050707__19267.1986333609$1227258957$gmane$org@cn.fujitsu.com>
References: <49267609.8050600@cn.fujitsu.com>
	<20081121010637.0f71ffff.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081121010637.0f71ffff.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
> On Fri, 21 Nov 2008 16:49:13 +0800 Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 
>> current some cgroup struct are protected by RCU.
>>
>> struct protected by RCU:
>> 	struct css_set, struct cgroup_subsys_state, struct cgroup
>>
>> pointer protected by RCU:
>> 	struct task_struct.cgroups, struct css_set.subsys[*],
>> 	struct cgroup_subsys_state.cgroup
>> the last two pointers are readonly pointer!
>>
>> these patches are fix these structs, and pointers. And a faker:
>> struct cgroup_subsys.root
>>
>> Not cleanup all yet.
>>
> 
> These patches aren't sequence numbered.  In what order should they be
> applied?
> 
> 
> 
> 

No order number, they are dependent(except 2 patches which have order number).

Lai.
