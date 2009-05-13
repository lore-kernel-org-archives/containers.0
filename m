From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH ckpt-v15] allocate checkpoint headers with kzalloc
Date: Wed, 13 May 2009 12:25:24 -0500
Message-ID: <m3my9gx6d7.fsf@pobox.com>
References: <m3zldhxai8.fsf@pobox.com> <20090513170257.GA18675@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090513170257.GA18675-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message
	of "Wed\, 13 May 2009 12\:02\:57 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
>> In a checkpoint image I noticed a lot of 0x6b (POISON_FREE) bytes
>> corresponding to checkpoint_restart_block -- this indicates that we
>> would write uninitialized kernel memory to the image in cases where
>> slab allocator debugging is not enabled[1].
>> 
>> Use kzalloc in ckpt_hdr_get.
>
> Yikes, yes, that's on par with a recent ecryptfs bug that did the
> same thing.
>
> Have you audited for other such potential privileged data leaks?
> (besides "all sysvipc" which we know about :)

No, haven't audited other things; the strings of 0x6b just caught my eye
and this looked like the obvious fix.  As general rule, I'd say the
checkpoint code should be zeroing any intermediate buffers that could be
written to the image.
