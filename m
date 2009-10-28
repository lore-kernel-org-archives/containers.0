From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Porting checkpoint system to arm: write_file error
Date: Wed, 28 Oct 2009 00:42:14 -0700
Message-ID: <20091028074214.GN31446@count0.beaverton.ibm.com>
References: <44a110670910271824h50ff7e9dp3e87becac6380293@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <44a110670910271824h50ff7e9dp3e87becac6380293-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jerf gefera <jgefera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Oct 28, 2009 at 10:24:33AM +0900, Jerf gefera wrote:
> hi all,
> The attachment is the img file and dmesg message.
> If I comment the code of cr_write_files in both checkpoint.c & restart.c,
> then i can checkpoint and restart the process(of cause, there are no file
> operations in the checkpointed process). it is strange.
> i hope you can point it out for me.
> Thank you very much!
> best wishes,
> gefera

Hi,

	Based on the names "cr_write_files" and this snippet from your
dmesg:

		[<8c0fb15c>] cr_write_mm+0x37c/0x5e0
		[<8c0f98a8>] do_checkpoint+0x4c8/0x7a0
		[<8c027280>] printk+0x0/0x40
		[<8c039080>] pid_vnr+0x0/0x20
		[<8c0f9196>] sys_checkpoint+0x36/0x60
		[<8c0171f0>] syscall_call+0xc/0x10
		[<8c0f9160>] sys_checkpoint+0x0/0x60

It looks like you're using an old version of the patches. The last
revision with those functions names that I can find with Google comes
from April.

Alot more stuff is working now -- including some important file ops. Any
chance we could help you switch to something more recent? You can get the
latest from the ckpt-v18-dev branch of:

	git clone git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git

If that's not acceptable to you, could you at least let us know
specifically what code you're trying to port?

Are you planning on posting your patches somewhere? They might be
interesting to see even if incomplete or for an old cr tree.

Cheers,
	-Matt Helsley
