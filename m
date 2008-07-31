From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/2] CR: save/restore a single, simple task
Date: Wed, 30 Jul 2008 20:37:28 -0400
Message-ID: <48910948.1000201@cs.columbia.edu>
References: <Pine.LNX.4.64.0807292306570.9868@takamine.ncl.cs.columbia.edu>	
	<20080730213541.GA24192@us.ibm.com>
	<1217454042.26001.6.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1217454042.26001.6.camel@nimitz>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Wed, 2008-07-30 at 16:35 -0500, Serge E. Hallyn wrote:
>> So task 5 created its mm_struct, task 6 is
>> supposed to use the same mm_struct, so it finds that out from the
>> context?  I wonder whether that would start to become complicated
>> when checkpointing nested containers.
> 
> It also doesn't fit well with the nsproxy idea.  It would be very hard
> to tell which nsproxies should be shared until the entire restart has
> been completed and we've been able to figure out which ones are the
> same.

I'm not sure I fully understand the problem that you describe, however,
I reckon that nsproxies are, basically, yet-another shared object between
tasks in the kernel. As such, the CR logic will treat them like other
shared objects: the first time one is found, its state will be saved;
the next time the same one is found, only an identifier will be saved.

That definitely means that, yes, the state within nsproxies as kernel
resources will have to be saved as part of the checkpoint.

Oren.

> 
> This is just a coding/implementation issue, but I think it does reveal a
> difference in ideology between these patches and the way that the kernel
> works up until now. :)
> 
> -- Dave
> 
