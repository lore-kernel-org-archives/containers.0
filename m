From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: 2.6.38 containers bug: Infinite loop in
	/proc/sys/net/ipv6/neigh/neigh/neigh...
Date: Wed, 30 Mar 2011 05:45:08 -0500
Message-ID: <4D9309B4.2000501__19411.2088451677$1301481961$gmane$org@parallels.com>
References: <4D92E9DC.3070405@parallels.com>	<20110330.020120.02272125.davem@davemloft.net>	<4D9302F3.6080206@parallels.com>
	<20110330.033529.71582712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110330.033529.71582712.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/30/2011 05:35 AM, David Miller wrote:
> From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Date: Wed, 30 Mar 2011 05:16:19 -0500
> 
>> Pinging the stable guys to make sure this goes in a dot release.
> 
> Please do not do this.

Too late, but presumably they got your NAK.

> I let fixes soak in Linus's tree for a week or even more before I submit
> them to -stable.

So you think letting it soak in the merge window and the churn of -rc1
(which currently doesn't boot for me due to an ide issue) will provide
more validity than a specific "There was an infinite loop in the
filesystem, there is now no longer an infinite loop in the filesystem,
here's the specific test for it" and visual inspection ofthe patch?

*shrug*  I hear what you say.  It's certainly a point of view.

Rob
