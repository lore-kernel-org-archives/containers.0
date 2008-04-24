From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: Checkpoint/restart (was Re: [PATCH 0/4] - v2 -  Object	creation
	with a specified id)
Date: Thu, 24 Apr 2008 19:13:01 -0400
Message-ID: <481113FD.3010905@cs.columbia.edu>
References: <20080418054459.891481000@bull.net>	<20080422193612.GA15835@martell.zuzino.mipt.ru>	<1208890580.17117.14.camel@nimitz.home.sr71.net>	<20080422210130.GA15937@martell.zuzino.mipt.ru>	<1208904967.17117.51.camel@nimitz.home.sr71.net>	<480ED9D5.1010906@parallels.com>	<1208964798.17117.72.camel@nimitz.home.sr71.net>	<48103002.5090806@parallels.com>
	<1209061809.12718.36.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1209061809.12718.36.camel-FpcvD5N4B9G9xGwK5P7XA+TW4wlIGRCZ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, nick-dnCCA748QAperShJXdIFYw@public.gmane.org, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Thu, 2008-04-24 at 11:00 +0400, Kirill Korotaev wrote:
>> Yeah... we talked with Andrew yesterday. He mostly agrees with a black
>> box.
>> He also said an interesting idea, that if you need compatibility
>> between the kernels (like we for example, support for migration from
>> 2.6.9 to 2.6.18 in OpenVZ)
>> you can do image conversion in user-space...
> 
> That sounds compelling to me.  I'm definitely willing to explore it.

Filtering/converting in user-space has long been part of zap: used to
be able to migrate between both minor and major versions of the kernel
(always upwards, of course).

In fact, I already proposed it as part of the original thread that led
eventually to the patch in question:
https://lists.linux-foundation.org/pipermail/containers/2008-February/009849.html

The need to be able to specify a desired ID (from user-space and/or from
in-kernel) remains.

Oren.

> Any thoughts on what we should start with?  What can we get merged, most
> easily?
> 
> -- Dave
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
