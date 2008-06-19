From: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Subject: Re: Re: Question : memrlimit cgroup's task_move (2.6.26-rc5-mm3)
Date: Thu, 19 Jun 2008 22:38:29 +0900 (JST)
Message-ID: <7438228.1213882709934.kamezawa.hiroyu@jp.fujitsu.com>
References: <485A5160.5070901@linux.vnet.ibm.com>
	<20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com>
	<4859CEE7.9030505@linux.vnet.ibm.com>
	<20080619122429.138a1d32.kamezawa.hiroyu@jp.fujitsu.com>
	<20080619192227.972ded64.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <485A5160.5070901-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

----- Original Message -----
>Date: 	Thu, 19 Jun 2008 18:00:24 +0530
>From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

>> [root@iridium kamezawa]# ulimit -s unlimited
>> [root@iridium kamezawa]# cat /opt/cgroup/test/memrlimit.usage_in_bytes
>> 72368128
>> [root@iridium kamezawa]#
>
>Aaah.. I see.. I had it in place earlier, but moved them to may_expand_vm() o
n
>review suggestions. I can move it out or try to unroll when things fail. I'll
>experiment a bit more. Is there any particular method you prefer?
>
Anywhere... but...IMHO, where the rlimit does charge will be a candidate.
But doing that may make the code ugly, I'm not sure now.

Thanks,
-Kame 
