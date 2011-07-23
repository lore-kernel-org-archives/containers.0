From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 7/7] binfmt: Introduce the binfmt_img exec handler
Date: Sat, 23 Jul 2011 12:51:09 +0400
Message-ID: <4E2A8B7D.8010807@parallels.com>
References: <4E204466.8010204@parallels.com> <4E204519.3040804@parallels.com>
	<20110721065127.GS3455@htj.dyndns.org>
	<20110722224617.GA16940@count0.beaverton.ibm.com>
	<4E2A83AC.6090504@parallels.com>
	<20110723084529.GH21089@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110723084529.GH21089-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/23/2011 12:45 PM, Tejun Heo wrote:
> Hello, Pavel.
> 
> On Sat, Jul 23, 2011 at 12:17:48PM +0400, Pavel Emelyanov wrote:
>> The basic idea is very simple - you have to create a process with a defined
>> values in registers and defined set of memory mappings (with the memory
>> contents). This creation is obviously done by some (maybe another) process.
>>
>> Thus we have two ways to go - either we transform the restoring task into
>> the target one or we freeze the target one and repopulate it "remotely".
>>
>> The 1st approach seemed to be more elegant to me, and with this one we do
>> already have an API for turning one VM+regs into another - the execve.
>>
>> If you can suggest another way - I'm open for discussion.
> 
> Just restore it using the usual system calls - clone, mmap, open....

I can't clone/mmap/open registers (yet, unless we decide to have /proc/pid/regs
file, do we?). Neither can I do it for anonymous private mappings :(

> There is no reason for the kernel to do it and kernel can't even do it
> properly without going way outside of the existing exec(2) conventions
> unless you're planning to make exec(2) create multi-threaded process
> and I don't think that's a wise direction.
> 
> Thanks.
> 
