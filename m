From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [5/8] throttling simultaneous callers of try_to_free_mem_cgroup_pages
Date: Tue, 4 Dec 2007 10:33:32 +0900
Message-ID: <20071204103332.ad4cf9b5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
	<20071203183921.72005b21.kamezawa.hiroyu@jp.fujitsu.com>
	<20071203092418.58631593@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071203092418.58631593-Fuq27k0DHcCSkoNiqTzCLQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 3 Dec 2007 09:24:18 -0500
Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On Mon, 3 Dec 2007 18:39:21 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> 
> > Add throttling direct reclaim.
> > 
> > Trying heavy workload under memory controller, you'll see too much
> > iowait and system seems heavy. (This is not good.... memory controller
> > is usually used for isolating system workload)
> > And too much memory are reclaimed.
> > 
> > This patch adds throttling function for direct reclaim.
> > Currently, num_online_cpus/(4) + 1 threads can do direct memory reclaim
> > under memory controller.
> 
> The same problems are true of global reclaim.
> 
> Now that we're discussing this RFC anyway, I wonder if we
> should think about moving this restriction to the global
> reclaim level...
> 
Hmm, I agree to some extent.
I'd like to add the same level of parameters to memory controller AMAP.

But, IMHO, there are differences basically.

Memory controller's reclaim is much heavier than global LRU because of
increasing footprint , the number of atomic ops....
And memory controller's reclaim policy is simpler than global because
it is not  kicked by memory shortage and almost all gfk_mask is GFP_HIGHUSER_MOVABLE
and order is always 0.
 
I think starting from throttling memory controller is not so bad because 
it's heavy and it's simple. The benefit of this throttoling is clearer than
globals.

Adding this kind of controls to global memory allocator/LRU may cause
unexpected slow down in application's response time. High-response application
users may dislike this. We may need another gfp_flag or sysctl to allow
throttling in global.
For memory controller, the user sets its memory limitation by himself. He can
adjust parameters and the workload. So, I think this throttoling is not so
problematic in memory controller as global.

Of course, we can export "do throttoling or not" control in cgroup interface.


Thanks,
-Kame 
