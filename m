From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add checkpoint/restart support for epoll files.
Date: Tue, 25 Aug 2009 00:17:08 -0400
Message-ID: <4A9365C4.3010305@librato.com>
References: <6d896e12f316e5ff5f44bd13ae1482dab7f9253a.1250745409.git.matthltc@us.ibm.com>	<e820d207a3b1a3228ded29bce9b29f2179ab598b.1250745409.git.matthltc@us.ibm.com>	<20090824212725.GA25030@us.ibm.com>
	<20090825020146.GC8078@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090825020146.GC8078-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Mon, Aug 24, 2009 at 04:27:25PM -0500, Serge E. Hallyn wrote:
>> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>> Save/restore epoll items during checkpoint/restart respectively.

[...]

>>> +/* TODO confirm that get_current_user() has been restored */
>> Not sure what you mean.  At this point, the task's credentials
>> are still the ones used when it called sys_restart().  We won't
>> update them until the end of the restart operation.  However the
>> normal file restore operations should have reset the file->f_cred
>> to the checkpointed value - including hierarchical user namespaces.
> 
> I wanted to check to ensure that we're properly enforcing the epoll
> watch limits for the restarted tasks. So the patch looks good because
> it restore the "common" file pieces before the epoll items/watches.
> See below if you're curious where/how that happens. I think I can
> remove this TODO now.

Good point. Me thinks it deserves a comment in the code ?

Oren.
