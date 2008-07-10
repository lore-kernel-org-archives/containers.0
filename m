From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Devel] [RFC PATCH 0/5] Resend -v2 - Use procfs to change a
	syscall behavior
Date: Wed, 09 Jul 2008 19:14:37 -0700
Message-ID: <m1k5fu7aeq.fsf@frodo.ebiederm.org>
References: <20080708112422.164370000@bull.net>
	<20080709221028.GA4926@martell.zuzino.mipt.ru>
	<m1tzeyd0x3.fsf@frodo.ebiederm.org>
	<20080710013915.GB8327@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080710013915.GB8327-QDJVlCTZ4KWTKS93B3g+7KFoa47nwP16@public.gmane.org> (Alexey Dobriyan's
	message of "Thu, 10 Jul 2008 05:39:15 +0400")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> In case of ->did_exec the only clean interface I see is:
>
> 	tsk->did_exec = !!tsk_img->did_exec;
>
> It would be pretty silly to wrap this one line in a system call (two
> actually -- one in, one out), since you're going to restore some more
> fields of such variety anyway (like ->pdeath_signal).

There I agree the granularity seems small enough to be a major pain
for the implementation.

> Given the diversity of kernel internal data structures and all sorts of
> links between them, the only system call suitable is ioctl(2), not all
> this zoo of system calls proposed. They are all extendable and without
> rules, but ioctl(2) is also without rules.

At least for processes my gut reaction is to look at binary formats
and coredumps.  Something with at least that large of a granularity seems
to make most sense.

> This is all said in assumption that serializing kernel-internal data for
> checkpoint/restart to userspace is acceptable for mainline.
> I don't think it is.

I don't believe that serializing kernel-internal data is acceptable
for mainline.  I believe that serializing user-visible data is acceptable.
Note: user-visible data does not mean user-manipulatable data.

On a socket you may not save the skbs but you can save the pending packets
for example.  Assuming the transition cost is not too high.

Eric
