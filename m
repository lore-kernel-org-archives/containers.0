From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: c/r support on FUSE filesystems.
Date: Mon, 04 Apr 2011 00:38:28 -0400
Message-ID: <4D994B44.2090205@cs.columbia.edu>
References: <AANLkTikPaUYrX8cKQMehNCL6bCjPBVkNa4G1Fs_Fu4XV@mail.gmail.com>	<20110401220021.GO22601@count0.beaverton.ibm.com>	<AANLkTi=Z4HACdfGNcfz2J2FXUC7GsODMcGuzzCTLddYc@mail.gmail.com>
	<AANLkTi=pFfJOaNdaxZFZMe8vhQFO0XA_p0aq6jXuVzY6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTi=pFfJOaNdaxZFZMe8vhQFO0XA_p0aq6jXuVzY6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vishnumurthy Prabhu <prabhuvishnumurthy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

Thanks for submitting the patch -- adding c/r support for fuse is
definitely something we need !

For convenience of reviewing, please make sure to inline the patches
in the email rather than use an attachment - so that reviewers can
comment directly on the code.

Also, it's useful to add some documentation that explains your
approach and why it is a suitable one, as well as how it was tested,
and what are the limitations (if any).

In particular, can you please explain the work-flow of checkpoint
and restart with FUSE ?

My impression is that the patch adds placeholders for checkpoint() 
and restart() to be delegated to FUSE, but I'm unsure what exactly 
should happen in those hooks.

For many FUSE file systems, I'd expect that just like with most
non-FUSE file systems, there will be nothing special needed to be
done, beyond the standard generic_file_chekcpoint().

For those that do require additional handling, these methods will
likely need to save state related to the specific FUSE filesystem,
and that state will be written to the checkpoint image and then
used during restart. Therefore, the hooks should arrange for passing
this state between the FUSE module and the checkpoint image.

For instance, the checkpoint() interface will need to receive the
(optional) data from the FUSE model and then write it to the image
file. The restart() interface will need to pass that data back to
the FUSE module.

Even if there does not exist any exmaple of a FUSE filesystem that 
requires this at the moment, it's useful to add those interfaces
so that a FUSE filesystem could indicate, by implemnting (even a
"do-nothing" instance of them) the methods, that it supports c/r.
Thus, a FUSE filesystem that does not explicitly indicate this, 
will be considered unsupported, which is in line with our current
handling of all other filesystems.

Finally, in adding these interfaces, we need be careful not to break
userspace code - for example, does the current implementation 
require changes to existing FUSE filesystem so that they compile
and run ?

Looking forward to more work on this !

Thanks,

Oren.


On 04/03/2011 01:50 AM, Vishnumurthy Prabhu wrote:
> Patch resubmitted!!
> New file(fuse-kcr.c) should go to fs/fuse/ directory.
> I will look into unliked files and update you soon!
> 
> regards,
> Vishnumurthy Prabhu
> 
> On Sat, Apr 2, 2011 at 7:29 AM, Vishnumurthy Prabhu <
> prabhuvishnumurthy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
>> Thank you very much for your kind and immediate reply!
>> first thing, I do agree that this is not a submittable patch and as you
>> said, I just 'diff' ed two linux sources(having with FUSE-cr support that is
>> what I modified and non FUSE-cr support).
>> what I wanted was to inform to community about FUSE-cr implementation and
>> comments on issues involved with that implementation.
>>
>> .
>> .
>>
>> .
>>
>>> Can you tell us about the testing you've done with this? What kind of
>>> additions/changes does this make to the FUSE userspace API? Can you
>>> please describe how it's supposed to work with FUSE userspace code?
>>
>> I have tested with two simple usecases(I know, it might not be sufficient).
>> they are, fuse-zip(fuse based filesystem for accessing zip files) and
>> simple-fuse(filesystem implementation in memory buffer). At user-space code,
>> I didn't do much modifications, I just added call back handles for
>> checkpointing in fuse library similar to that of other handles(open, close,
>> read, write etc) thinking that I might need those. but I never made use of
>> those. Thats why, if you have seen the code(fuse_kcr.c ie, a C file that I
>> have attached), though I wrote a code piece for user-space communication, I
>> have commented its use in actual checkpoint function and it just uses the
>> same approach as that of generic file checkpoint. According to present
>> implementation, user-space(fuse library or filesystem program) is unaware of
>> what is going on during checkpointing and restart. It just considers every
>> call as like others(ie open, read, write, close).
>>
>> MY CLAIM is that all required accounting information of an open file is
>> managed at kernel space(file object) and At user space, it just get a
>> request and replies to that. All information related to state of open file
>> is supplied from kernel space.
>>
>> ASSUMPTION:  during checkpoint and restart mount remains same. in fact, I
>> hope there is no unmount and remount of userspace program. because, here the
>> support is for checkpointing file descriptors that involve fuse related
>> files so I dont think we need to bother about user implemented filesystem.
>>
>> I wanted to know any issues related to above comments?
>>
>> .
>> .
>>
>> .
>>>>       .compat_ioctl   = fuse_file_compat_ioctl,
>>>>      .poll           = fuse_file_poll,
>>>> + //#ifdef CONFIG_CHECKPOINT
>>>> +     .checkpoint     = fuse_file_checkpoint,
>>>> + //#endif
>>
>>> Why are these cpp lines commented out?
>>
>> I know  I need to refine the patch file one thing and I commented out these
>> line because I was compiling fuse kernel module as loadable one so compiler
>> never used to take this checkpoint ops(I dont know why?) when #ifdef was
>> present. but in actual source compilation with kernel, I have removed the
>> comments.
>> .
>> .
>>
>> .
>>> Is the content below the missing pair of files?
>>
>>>> /*
>>>> fuse_cr: Checkpoint-Restart implementation for FUSE filesystem kernel
>> module.
>>>>
>>>> Authors: Manoj Kumar and Vishnumurthy Prabhu
>>>>         NITK Surathkal
>>>>
>>>> */
>> .
>> .
>> .
>>
>> they are the two new additions to fuse kernel module.
>>
>>
>>>> /*
>>>>       FUSE filesystem .It needs special handling
>>>>       {
>>>>               .file_name = "FUSE",
>>>>               .file_type = CKPT_FILE_FUSE,
>>>>               .restore = fuse_file_restore,
>>>>       },
>>>> */
>>
>>> Huh? What's this comment supposed to tell us?
>>
>> It is just to tell I have added this code piece some where, need
>> implementation and it is just a comment.
>>
>>
>>>>
>>>> struct ckpt_hdr_file_fuse {
>>>>      struct ckpt_hdr_file common;
>>>>
>>>> } __attribute__((aligned(8)));
>>
>>> This should be in include/linux/checkpoint_hdr.h *except* since it
>>> doesn't need anything besides the ckpt_hdr_file I don't see why you
>>> don't just use that struct instead.
>>
>> I kept seperate structure because there might have need to add few more
>> variable in this structure later on. I didnt move it to checkpoint_hdr.h
>> just because to avoid messing with large number of files. but once
>> everything is settled, I hope we can do that.
>> .
>> .
>> .
>>>> int fuse_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>>>> {
>>>>   int ret;
>>>>    struct ckpt_hdr_file_fuse *h;
>>>>
>>>>       if (d_unlinked(file->f_dentry)) {
>>>>               ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files
>> unsupported\n",
>>>>                        file);
>>>>               return -EBADF;
>>
>>> Unlinked files are important too. Have you had a chance to review my
>>> recent patches for unlinked files?
>>
>> No. I worked with one single kernel source so that frequent changes wont
>> affect to this(fuse-cr).
>>
>>>>       }
>>>>
>>>>       h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
>>>>       if (!h)
>>>>               return -ENOMEM;
>>>>
>>>>       h->common.f_type = CKPT_FILE_FUSE;
>>>>
>>>>       ret = checkpoint_file_common(ctx, file, &h->common);
>>>>       if (ret < 0)
>>>>               goto out;
>>>>       ret = ckpt_write_obj(ctx, &h->common.h);
>>>>       if (ret < 0)
>>>>               goto out;
>>>>       ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
>>>>
>>>> //   ret = fuse_file_ckpt_send(file);
>>
>>> This looks like the only real difference from generic_file_checkpoint()
>> yet
>>> it's commented out. What's going on? Have you compiled this code?
>>> Tested it?
>>
>>
>> I compiled , tested with above mentioned test cases(fuse-zip and simple
>> fuse). It worked fine. I thought not to mess with userspace and I wanted to
>> know, whether it works fine or not. But it worked. yes, It is almost
>> completely similar to generic file checkpoint.  I am looking for SUFFICIENT
>> USECASEs for that where it also require user space support. Even I tried
>> with non-commented code(fuse_file_ckpt_send()). then also it worked fine and
>> even at userspace(I have checkpoint handles in user space fuse library
>> similar to other handles). but I found there is nothing much to do with
>> UserSpace. so I just commented out. It worked.
>>
>> It works fine with uncommented code also.
>>
>> so, I will update with refine code.
>>
>> thanks,
>>
>> regards,
>> vishnumurthy prabhu
>>
>>
>>
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
