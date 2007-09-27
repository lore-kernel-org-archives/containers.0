From: Badari Pulavarty <pbadari-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC}[PATCH] forced uncharge for successful rmdir.
Date: Thu, 27 Sep 2007 09:54:26 -0700
Message-ID: <1190912067.13955.72.camel@dyn9047017100.beaverton.ibm.com>
References: <20070927163035.20137bb5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070927163035.20137bb5.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2007-09-27 at 16:30 +0900, KAMEZAWA Hiroyuki wrote:
> Following patch is for successful rmdir in memory cgroup.
> 
> Currently, rmdir against memory cgroup will fail if charged page caches are in cgroup.
> (even if no tasks in cgroup.)
> 
> I don't like this. This patch implements "forced" uncharge against memory cgroup.
> Uncharged pages will be charged again when some other cgroup/task accesses it.
> 
> I wonder that all unmapped page-caches in cgroup should be uncharged if "1" is written to
> control_type.
> 
> I'm grad if I can hear memory controller's policy about "rmdir" against no-task-cgroup.

Works for me..

elm3b155:/dev/cgroup/xxx # cat tasks
elm3b155:/dev/cgroup/xxx #
elm3b155:/dev/cgroup/xxx # cat memory.usage_in_bytes
16384
elm3b155:/dev/cgroup/xxx # echo -n 0 > memory.control_type
elm3b155:/dev/cgroup/xxx # cat memory.usage_in_bytes
0

Thanks,
Badari
