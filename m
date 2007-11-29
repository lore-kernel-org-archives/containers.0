From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][ only for review ] memory controller bacground reclaim
 [3/5] high/low watermark support in res_counter
Date: Thu, 29 Nov 2007 12:24:02 +0900
Message-ID: <20071129122402.101c5fbc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071128175408.1ee479f3.kamezawa.hiroyu@jp.fujitsu.com>
	<20071129025609.0B7111CFE7C@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071129025609.0B7111CFE7C-Pcsii4f/SVk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 29 Nov 2007 11:56:08 +0900 (JST)
yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:

> > This patch adds high/low watermark parameter to res_counter.
> > splitted out from YAMAMOTO's background page reclaim for memory cgroup set.
> 
> thanks.
> 
> > +	 * Watermarks
> > +	 * Should be changed automatically when the limit is changed and
> > +	 * keep low < high < limit.
> > +	 */
> > +	unsigned long long high_watermark;
> > +	unsigned long long low_watermark;
> > +	/*
> 
> do you have any specific reason not to allow low == high == limit?
No.

> if you want to ensure low < high < limit, it's better to make the
> default values below meet the condition as well.
Hmm, I see.

> to me, it seems weird to prevent users from making these values back to
> the default.
> 
will fix.
LLONG_MAX-1 for high
LLONG_MAX-2 for low ...?

BTW, it should be "low + PAGE_SIZE < high + PAGE_SIZE < limit" ...?
Does anyone have good idea ?

Thanks,
-Kame
