From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] memory.min_usage (seqlock for res_counter)
Date: Wed, 5 Dec 2007 18:29:27 +0900
Message-ID: <20071205182927.41d140a7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071204164615.fc871e44.kamezawa.hiroyu@jp.fujitsu.com>
	<20071204075854.5850B1D0BFA@siro.lan>
	<20071204195436.77fc911b.kamezawa.hiroyu@jp.fujitsu.com>
	<475535B2.1020801@openvz.org>
	<20071205093455.0f46b456.kamezawa.hiroyu@jp.fujitsu.com>
	<47566B76.6020102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47566B76.6020102-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 05 Dec 2007 12:12:22 +0300
Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:

> Sorry, let me explain it in other words.
> 
> I think, that protection in reader, that guarantees that it
> will see the valid result, is not very important - even if
> we compare usage and limit not atomically nothing serious
> will happen (in this particular case)
> 
Maybe there is no serious situation (now).
But programmers don't assume that the function may not return trustable result.
And I think it shouldn be trustable AMAP.

I'd like to use seq_lock or res_counter_state, here.

BTW, I'm wondering I should hold off my patches until 2.6.25-rc series if they
make things complex.

Thanks,
-Kame
