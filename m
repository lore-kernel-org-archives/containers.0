From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Date: Wed, 11 Jun 2008 13:14:37 +0900
Message-ID: <20080611131437.76961fc3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080611122500.677757c6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080611034446.4C5535A23@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080611034446.4C5535A23-Pcsii4f/SVk@public.gmane.org>
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

On Wed, 11 Jun 2008 12:44:46 +0900 (JST)
yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:

> > I'm now considering following logic. How do you think ?
> > 
> > Assume: move TASK from group:CURR to group:DEST.
> > 
> > == move_task(TASK, CURR, DEST)
> > 
> > if (DEST's limit is unlimited)
> > 	moving TASK
> > 	return success.
> > 
> > usage = check_usage_of_task(TASK).
> > 
> > /* try to reserve enough room in destionation */
> > if (try_to_reserve_enough_room(DEST, usage)) {
> > 	move TASK to DEST and move pages AMAP.
> > 	/* usage_of_task(TASK) can be changed while we do this.
> > 	   Then, we move AMAP. */
> > 	return success;
> > }
> > return failure.
> > ==
> 
> AMAP means that you might leave some random charges in CURR?
> 
yes. but we can reduce bad case by some way 
 - reserve more than necessary.
 or
 - read_lock mm->sem while move.

> i think that you can redirect new charges in TASK to DEST
> so that usage_of_task(TASK) will not grow.
> 

Hmm, to do that, we have to handle complicated cgroup's attach ops.

at this moving, memcg is pointed by
 - TASK->cgroup->memcg(CURR)
after move
 - TASK->another_cgroup->memcg(DEST)

This move happens before cgroup is replaced by another_cgroup.


Thanks,
-Kame
