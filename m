From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 30432] New: rmdir on cgroup can cause hang
 tasks
Date: Fri, 4 Mar 2011 18:01:57 +0900
Message-ID: <20110304180157.133fdfd1.kamezawa.hiroyu@jp.fujitsu.com>
References: <bug-30432-10286@https.bugzilla.kernel.org/>
	<20110304000355.4f68bab1.akpm@linux-foundation.org>
	<20110304172815.9d9e3672.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110304172815.9d9e3672.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Poelzleithner <poelzi@poelzi.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, containers@lists.osdl.org, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

On Fri, 4 Mar 2011 17:28:15 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
This seems....
> ==
> static void mem_cgroup_start_move(struct mem_cgroup *mem)
> {
> .....
> 	put_online_cpus();
> 
>         synchronize_rcu();   <---------(*)
> }
> ==
> 

But this may scan LRU of memcg forever and SysRq+T just shows
above stack.

I'll check a tree before THP and force_empty again
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
