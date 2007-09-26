From: Badari Pulavarty <pbadari-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Unable to remove control groups on 2.6.23-rc8-mm1
Date: Wed, 26 Sep 2007 08:29:54 -0700
Message-ID: <1190820594.13955.57.camel@dyn9047017100.beaverton.ibm.com>
References: <1190763481.13955.52.camel@dyn9047017100.beaverton.ibm.com>
	<46F9D12B.7070402@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46F9D12B.7070402-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2007-09-26 at 08:55 +0530, Balbir Singh wrote:
> Badari Pulavarty wrote:
> > Hi,
> > 
> > I am playing with control groups on 2.6.23-rc8-mm1.
> > 
> > I am able to mount cgroup and create subgroups. I was able
> > to move some tasks into them. But, after killing tasks I am
> > not able to remove the subgroups. Any idea on why ?
> > 
> > Thanks,
> > Badari
> > 
> 
> Badari,
> 
> We account for page cache usage as well now, I suspect you
> most likely have page/swap cache pages charged to the container.

Yep. Even after killing all the tasks and "echo 1 > drop_caches"
some memory still accounted for on this group.

elm3b155:/dev/cgroup # cat zzz/memory.usage_in_bytes
131072


> You can try several options (some documented in Documentation/
> controllers/memory.txt)
> 
> 1. Try executing sync; echo 1 > /proc/sys/vm/drop_caches
>    and then remove the directory
> 2. Prior to assigning tasks, set memory.control_type to 1,
>    that tracks only RSS pages. You'll find memory.usage_in_bytes
>    go to zero as soon as all the tasks exit

This helped. 

> 3. Set notify_on_release and use the release_agent and releasable
>    to free the container once all pages charged to it are freed.
> 
> I wonder if I should provide a force_reclaim (hard to guarantee
> it will work) for each container, so that the container can
> be freed.
> 

BTW, how do I detach a "pid" from the cgroup ?

Thanks,
Badari
