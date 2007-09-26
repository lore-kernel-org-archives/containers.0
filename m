From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Unable to remove control groups on 2.6.23-rc8-mm1
Date: Wed, 26 Sep 2007 08:55:31 +0530
Message-ID: <46F9D12B.7070402@linux.vnet.ibm.com>
References: <1190763481.13955.52.camel@dyn9047017100.beaverton.ibm.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1190763481.13955.52.camel-Tq0y/nC7FQqofirLTBlK79w6IDGaBKkJqyM6JfAXOaQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Badari Pulavarty <pbadari-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Badari Pulavarty wrote:
> Hi,
> 
> I am playing with control groups on 2.6.23-rc8-mm1.
> 
> I am able to mount cgroup and create subgroups. I was able
> to move some tasks into them. But, after killing tasks I am
> not able to remove the subgroups. Any idea on why ?
> 
> Thanks,
> Badari
> 

Badari,

We account for page cache usage as well now, I suspect you
most likely have page/swap cache pages charged to the container.

You can try several options (some documented in Documentation/
controllers/memory.txt)

1. Try executing sync; echo 1 > /proc/sys/vm/drop_caches
   and then remove the directory
2. Prior to assigning tasks, set memory.control_type to 1,
   that tracks only RSS pages. You'll find memory.usage_in_bytes
   go to zero as soon as all the tasks exit
3. Set notify_on_release and use the release_agent and releasable
   to free the container once all pages charged to it are freed.

I wonder if I should provide a force_reclaim (hard to guarantee
it will work) for each container, so that the container can
be freed.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
