From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC 1/2] memcg: hierarchy support core (yet another one)
Date: Thu, 29 May 2008 14:23:37 +0900
Message-ID: <20080529142337.e9aa25b2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080528165620.68f4d911.kamezawa.hiroyu@jp.fujitsu.com>
	<20080529051104.2C4995A0E@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080529051104.2C4995A0E-Pcsii4f/SVk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 29 May 2008 14:11:04 +0900 (JST)
yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:

> > @@ -39,6 +39,18 @@ struct res_counter {
> >  	 */
> >  	unsigned long long failcnt;
> >  	/*
> > +	 * the amount of resource comes from parenet cgroup. Should be
> > +	 * returned to the parent at destroying/resizing this res_counter.
> > +	 */
> > +	unsigned long long borrow;
> 
> why do you need this in addition to the limit?
> ie. aren't their values always equal except the root cgroup?
> 
yes, except the root group. that's a reason....no,no

To be honest, I thought of different concept of hierarchy when I started this
and borrow != limit in first version. But it was complicated and big..
Finally, I set borrow=limit but I didn't remove "borrrow" because it seems
to help a man to undetstand the whole logic.

I'm now retrying borrow != limit version, again. (but no good progress ;)

Thanks,
-Kame
