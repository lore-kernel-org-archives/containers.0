From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: A consideration on memory controller.
Date: Mon, 21 Jan 2008 19:22:59 +0900
Message-ID: <20080121192259.fe704050.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080121170759.3dc02561.kamezawa.hiroyu@jp.fujitsu.com>
	<20080121082852.GB7796@balbir.in.ibm.com>
	<20080121181920.28353c34.kamezawa.hiroyu@jp.fujitsu.com>
	<20080121095036.GB9817@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080121095036.GB9817-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 21 Jan 2008 15:20:36 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> > > This topic needs more discussion, we have some form of page-cache
> > > control built into the memory controller.
> > > 
> > Hmm. ok. I'looking forward to see.
> > 
> 
> Could you elaborate on what sort of page-cache control you need, is it
> global page-cache control?
> 
What I mentioned to in my mail was global page cache. 

But, my purpose is isolate workload between applications and guarantee
stable performance/latency and memory controller's limiting page usage
feature will do half of work.
So, per-cgroup page-cache control is (maybe) good enough for making applications
stable by keeping room for immediate use of anon and by avoiding unnecessary swapout.

but above can be archieved by
 - reserve/guarantee amount of free memory by some technique, bacground 
   kthread, throttling,
 - do good design of swappiness.
 - etc...

So, the word "limiting page cache" itself is not important. Above will
limit amount of page-cache as a result.
Ways to reach my goal is not one, maybe. I should find the best one :)

Thanks,
-Kame
