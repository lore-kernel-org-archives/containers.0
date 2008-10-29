From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: About bio-cgroup
Date: Wed, 29 Oct 2008 17:29:18 +0900
Message-ID: <20081029172918.71995f7a.kamezawa.hiroyu@jp.fujitsu.com>
References: <4907C6F6.8040907@cn.fujitsu.com>
	<20081029.170718.124486817.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081029.170718.124486817.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 29 Oct 2008 17:07:18 +0900 (JST)
Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:

> Hi,
> 
> > Hi Ryo,
> > 
> > The page_cgroup seems to be stable in the latest kernel.
> > I'd like to know whether you have a plan or schedule to release
> > a new version of bio-cgroup against latest kernel.
> 
> I have a plan on doing this.
> 
> I thought I would start to implement it once the implementation of
> memory cgroup got almost done. If you say the code of page_cgroup is
> fixed, I'll start it from now on. I guess it'll be done in two weeks.
> 

code to page_cgroup itself will not be changed. (I hope)
possible change will be
  - new flags
  - support to SwapCache
  - swap_cgroup support (will be done independenly from page_cgroup.)

API of
   lookup_page_cgroup()
   lock_page_cgroup()
   PCG_USED bit

will not change, I think.

Thanks,
-Kame
