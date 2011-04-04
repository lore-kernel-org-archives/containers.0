From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 04 Apr 2011 13:32:33 -0400
Message-ID: <4D9A00B1.2080002@cs.columbia.edu>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com>
	<1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com>
	<1301931608.31531.49.camel@tp-t61>
	<20110404162753.GA3456@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110404162753.GA3456-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



On 04/04/2011 12:27 PM, Serge E. Hallyn wrote:
> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>> On Mon, 2011-04-04 at 10:10 -0500, Serge E. Hallyn wrote:
>>> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>>>> On Sun, 2011-04-03 at 14:03 -0500, Serge E. Hallyn wrote:
>>>>> Quoting ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>>>>>> Only a pid namespace init task - the child process produced by a call
>>>>>> to clone(2) with CLONE_NEWPID - is allowed to call these.  The state
>>>>>
>>>>> So you make this useful for your cases by only using this with
>>>>> application containers - created using lxc-execute, or, more precisely,
>>>>> using lxc-init as the container's init.  So a container running a stock
>>>>> distro can't be checkpointed.
>>>>
>>>> Correct, a conventional distro init won't work, and application
>>>> containers are my focus for now, at least.
>>>>
>>>>
>>>>> Is this just to keep the patch simple for now, or is there some reason
>>>>> to keep this limitation in place?
>>>>
>>>> I guess you're asking whether non-pid-init processes could be allowed to
>>>> use the syscalls?
>>>
>>> No.  I'm asking whether you are intending to later on change the checkpoint
>>> API to allow an external task to checkpoint a pid-init process, rather than
>>> the pid-init process having to initiate it itself.
>>
>> No, that is not the intention.  I can see how that would be problematic
>> for those wanting to run minimally-modified distro containers, but I
>> think running a patched pid-init is a reasonable tradeoff to ask users
>> to make in order to get c/r.  And there's nothing to keep the standard
>> distro inits from growing c/r capability.
> 
> It's not necessarily a dealbreaker, since presumably I can hack the
> needed support into upstart, triggered by a boot option so it isn't
> activated on a host.  But especially given the lack of interest in
> this thread so far, I don't see a point in pushing this, an API-incompatible
> less-capable version of the linux-cr tree.  If it can gain traction
> better than linux-cr, that'd be one thing.  But given the amount of
> review and testing the other tree has gotten - and I realize you're
> able to piggy-back on much of that - and, again, the lack of responses
> so far, I just don't see this as worth pushing for.

First, thanks to Nathan for cleaning up and re-producing a "minimal"
patchest for review.

From the technical point of view it *is* a big problem:  there are
very good reasons why we chose a certain design. 

If Natahan is suggesting in-kernel tree creation as a temporary thing
to simplify the code for review - then, given that this patch handles
a single process, doing so add lots of unnecessary code, all of which
in the kernel.

If this is the beginning of a permanent approach, then it is totally
incompatible with what we have done so far, and severely restricts 
the kind of use--cases of the project, potentially making it too
unattractive for many natural adaptors, like HPC users. Sorry, nack.

Thanks,

Oren.
