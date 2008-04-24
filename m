From: Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: Checkpoint/restart (was Re: [PATCH 0/4] - v2 -  Object	creation
	with a specified id)
Date: Thu, 24 Apr 2008 11:00:18 +0400
Message-ID: <48103002.5090806__38456.4532236711$1209022055$gmane$org@parallels.com>
References: <20080418054459.891481000@bull.net>	
	<20080422193612.GA15835@martell.zuzino.mipt.ru>	
	<1208890580.17117.14.camel@nimitz.home.sr71.net>	
	<20080422210130.GA15937@martell.zuzino.mipt.ru>	
	<1208904967.17117.51.camel@nimitz.home.sr71.net>	
	<480ED9D5.1010906@parallels.com>
	<1208964798.17117.72.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1208964798.17117.72.camel-FpcvD5N4B9G9xGwK5P7XA+TW4wlIGRCZ@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, nick-dnCCA748QAperShJXdIFYw@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Yeah... we talked with Andrew yesterday. He mostly agrees with a black box.
He also said an interesting idea, that if you need compatibility
between the kernels (like we for example, support for migration from 2.6.9 to 2.6.18 in OpenVZ)
you can do image conversion in user-space... Though I think we will prefer simply to have
a compatibility patch for specific kernel versions in our kernel tree (not in mainstream).

Definitely, other ideas/opinions are welcome.

Kirill


Dave Hansen wrote:
> On Wed, 2008-04-23 at 10:40 +0400, Kirill Korotaev wrote:
>> Having all this functionality in a signle syscall we specifically CLAIM a black box,
>> and that no one can use this interfaces for something different from checkpoint/restore.
>>
>> So I think we have to know what other maintainers think before we can go.
> 
> I completely agree.
> 
> Have you asked any particular maintainers what they think?
> 
> -- Dave
> 
> 
