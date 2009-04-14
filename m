From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 10/30] cr: core stuff
Date: Tue, 14 Apr 2009 15:26:11 -0400
Message-ID: <49E4E353.9090508__13803.9670106538$1239737534$gmane$org@cs.columbia.edu>
References: <20090410023539.GK27788@x200.localdomain>
	<49E41D7B.8030003@cs.columbia.edu>
	<20090414160003.GD27461@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090414160003.GD27461-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org



Alexey Dobriyan wrote:
> On Tue, Apr 14, 2009 at 01:22:03AM -0400, Oren Laadan wrote:
>> Alexey Dobriyan wrote:
>>> * add struct file_operations::checkpoint
>>>
>>>   The point of hook is to serialize enough information to allow restoration
>>>   of an opened file.
>>>
>>>   The idea (good one!) is that the code which supplies struct file_operations
>>>   know better what to do with file.
>> Actually, credit is due to Dave Hansen (or Christoph Hellwig, or both?).
>>
>>>   Hook gets C/R context (a cookie more or less) on which dump code can
>>>   cr_write() and small restrictions on what to write: globally unique object id
>>>   and correct object length to allow jumping through objects.
>>>
>>>   For usual files on on-disk filesystem add generic_file_checkpoint()
>>>
>>>   Add ext3 opened regular files and directories for start.
>>>
>>>   No ->checkpoint, checkpointing is aborted -- deny by default.
>>>
>>> FIXME: unlinked, but opened files aren't supported yet.
>>>
>>> * C/R image design
>>>
>>>   The thing should be flexible -- kernel internals changes every day, so we can't
>>>   really afford a format with much enforced structure.
>>>
>>>   Image consists of header, object images and terminator.
>>>
>>>   Image header consists of immutable part and mutable part (for future).
>>>
>>>   Immutable header part is magic and image version: "LinuxC/R" + __le32
>>>
>>>   Image version determines everything including image header's mutable part.
>>>   Image version is going to be bumped at earliest opportunity following changes
>>>   in kernel internals.
>>>
>>>   So far image header mutable part consists of arch of the kernel which dumped
>>>   the image (i386, x86_64, ...) and kernel version as found in utsname.
>>>
>>>   Kernel version as string is for distributions. Distro can support C/R for
>>>   their own kernels, but can't realistically be expected to bump image version --
>>>   this will conflict with mainline kernels having used same version. We also don't
>>>   want requests for private parts of image version space.
>> So far so good, like in our patch-set.
>>
>> You also need to address differences in configuration (kernel could
>> have been recompiled) and runtime environment (boot params, etc).
>>
>> We deferred this issue to a later time.
>>
>>>   Distro expected to keep image version alone and on restart(2) check utsname
>>>   version and compare it against previously release kernel versions and based
>>>   on that turn on compatibility code.
>> Are you suggesting that conversion of a checkpoint image from an older
>> version to a newer version be done in the kernel ?
> 
> For mainline kernel it's completely unrealistic to support all backwards
> compatibility code for previous versions. Some mythical userspace
> program will convert images.
> 
> But it's completely realistic and much easier for distro kernel because
> distro kernel doesn't generally include patches with significant in-kernel
> internals changes, so they simply can support
> '2.6.26-1-amd64' => '2.6.26-2-amd64' situation.
> 
> Distros can write conversion program too, but I don't expect they will.
> 
>> It may work for a few versions, and then you'll get a spaghetti of
>> #ifdef's in the code, together with a plethora of legacy code.
> 
> Expectation is for one kernel branch like RHEL5 kernel updates during
> RHEL5 lifecycle.
> 
> For RHEL5 => RHEL6, it's up to them what to do.
> 
> Anyway distro can add compat code _anyway_, for this we help them with
> this image format tweak, so they won't bug mainline with "reserve bit 31
> for Red Hat".
> 
> Image version is kept small (__le32) for this reason too :-)
> 

So a simple kernel version won't suffice. For instance, even with the
same (distro) kernel, a user can choose vdso-compat at boot time.
Not to mention that a monotonically increasing version number can't
possible be a catch-all.

(while your favorite libc doesn't use it, in non-compat mode the
syscall gettimeofday() gets the data off the vdso page; besides
possibly breaking an application that migrates from non-compat to
compat, it is also impossible to check vdso page validity by a
simple memcmp() of old and new !).

We need (at least) some sort of kernel-hardware-capabilities-vector
that will encapsulate such dependencies. There will also be per
task vector, possibly (e.g. if never used math we don't care about
FPU capabilities, otherwise we do).

I don't expect to get that sorted out anytime soon - it will be a
long gradual process in which we gradually add what's needed to
describe the "environment" in which the tasks are running.

We do need to make the format of this vector easily extensible for
exactly this reason.

Oren.
