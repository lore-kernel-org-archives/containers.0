From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Date: Wed, 11 Jun 2008 13:08:16 +0900
Message-ID: <20080611130816.6dd36a31.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611110216.504faf15.kamezawa.hiroyu@jp.fujitsu.com>
	<20080611034514.D482F5A11@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080611034514.D482F5A11-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 11 Jun 2008 12:45:14 +0900 (JST)
yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:

> > > having said that, if you decide to put too large tasks into
> > > a cgroup with too small limit, i don't think that there are
> > > many choices besides OOM-kill and allowing "exceed".
> > > 
> > IMHO, allowing exceed is harmfull without changing the definition of "limit".
> > "limit" is hard-limit, now, not soft-limit. Changing the defintion just for
> > this is not acceptable for me. 
> 
> even with the current code, the "exceed" condition can be created
> by simply lowering the limit.
> (well, i know that some of your patches floating around change it.)
> 
Yes, I write it now ;) Handling exceed contains some troubles

  - when resizing limit, to what extent exceed is allowed ?
  - Once exceed, no new page allocation can success and
    _some random process_ will die because of OOM.


> > Maybe "move" under limit itself is crazy ops....Hmm...
> > 
> > Should we allow task move when the destination cgroup is unlimited ?
> > Isn't it useful ?
> 
> i think it makes some sense.
> 
> > > actually, i think that #3 and #5 are somewhat similar.
> > > a big difference is that, while #5 shrinks the cgroup immediately,
> > > #3 does it later.  in case we need to do OOM-kill, i prefer to do it
> > > sooner than later.
> > > 
> > #3 will not cause OOM-killer, I hope...A user can notice memory shortage.
> 
> we are talking about the case where a cgroup's working set is getting
> hopelessly larger than its limit.  i don't see why #3 will not
> cause OOM-kill.  can you explain?
> 
just because #3 doesn't move resource, just drop. 

Thanks,
-Kame
