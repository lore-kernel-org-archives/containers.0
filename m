From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] allow "unlimited" limit value.
Date: Tue, 25 Sep 2007 16:19:18 +0530
Message-ID: <46F8E7AE.2090309@linux.vnet.ibm.com>
References: <20070925193900.1af6d871.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070925193900.1af6d871.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> just for a RFC.
> 
> When I use memory controller, I notice that memory.limit_in_bytes shows
> just very big number, if unlimited.
> 
> A user(or tool) has to know that the big number(LLONG_MAX) means "unlimted".
> IMHO, some interface which allows users to specify "unlimited" value is helpful.
> 
> This patch tries to define value RES_COUTNER_UNLIMITED (== LLONG_MAX) and
> modifies an interface to support "unlimted" value.
> 
> Because this patch breaks limit_in_bytes to some extent,
> I'm glad if someone has a better idea to show unlimited value.
> (if some easy value means "unlimited", it's helpful. LLONG_MAX is not easy
>  to be recognized.)
> 
> ==after this patch ==
> [root@aworks kamezawa]# echo -n 400000000 > /opt/cgroup/memory.limit_in_bytes
> [root@aworks kamezawa]# cat /opt/cgroup/memory.limit_in_bytes
> 400003072
> [root@aworks kamezawa]# echo -n unlimited > /opt/cgroup/memory.limit_in_bytes
> [root@aworks kamezawa]# cat /opt/cgroup/memory.limit_in_bytes
> unlimited
> 

Hi, Kamezawa-San,

Your changes make sense, but not CLUI (Command Line Usage) sense.
1. The problem is that when we mix strings with numbers, tools that
   parse/use get confused and complicated
2. ULONGLONG_MAX is a real limit, there is no such thing as unlimited.
   If the user does ever go beyond ULONGLONG_MAX, we will limit him :-)

Having said that, I do wish to have a more intuitive interface for
users. May be a perl/python script to hide away the numbers game
from the users. What do you think?


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
