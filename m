From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 6/7] [RFC] Support multiply-bindable cgroup subsystems
Date: Wed, 01 Apr 2009 14:44:17 +0800
Message-ID: <49D30D41.5080808@cn.fujitsu.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>	
	<20090312105147.24154.62638.stgit@menage.corp.google.com>	
	<49BF4744.5060309@cn.fujitsu.com>
	<49C057EB.1000307@cn.fujitsu.com>	
	<6599ad830903171916x7364ec7cw76975d71d5125d82@mail.gmail.com>	
	<49C05EDF.5010607@cn.fujitsu.com>	
	<6599ad830903171943x7884cb03w8f22fa1629d667b3@mail.gmail.com>	
	<49C065E7.8060901@cn.fujitsu.com>
	<6599ad830903310202p1c268237lff283b2676f78864@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830903310202p1c268237lff283b2676f78864-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Mar 17, 2009 at 8:09 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> I don't see what's wrong with this behavior:
>>
>> multi subsys sits in rootnode if it's unbound, and is removed from
>> rootnode if it's binded at least in one hierarchy.
> 
> You mean just for the purposes of /proc/cgroup, or in reality?
> 

Yes, to show all subsystems in /proc/cgroup.

> Singleton (traditional) subsystems generally have some meaning outside
> of the cgroups framework, e.g. the "cpu" subsystem corresponds to CFS
> scheduler nodes for tasks; "cpuset" corresponds to the permitted
> cpus/mems for a task. For every task there's a single unique state
> object for each singleton subsystem.
> 
> But multi-bindable subsystems don't really have any meaning outside
> the cgroup framework, since there's no unique mapping from a task to
> its subsystem state. So instantiating a root cgroup object for that
> subsystem in the unbound hierarchy is a bit pointless - it can't
> really do anything. So it wouldn't really make sense to keep one
> instance of a multi-bindable subsystem attached to rootnote until the
> first bind for that subsystem, and then create fresh ones on the fly
> later if the subsystem is bound to more hierarchies. In particular,
> which one would you return to the rootnode later?
> 

For that purpose I suggest, we are not going to allocate a root cgroup
object for multi-subsys, but we just set the subsys-id in dump-root's
subsystem bits.

> But I guess we could just pretend in /proc/cgroup, and add a new
> column such as "multi-bindable".
> 
> Paul
> 
> 
