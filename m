From: Liu Aleaxander <aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [c/r]A problem met when using linux c/r
Date: Tue, 27 Oct 2009 10:21:59 +0800
Message-ID: <b741c2440910261921q77e0b5bbqbc0ee1f74974ee5e@mail.gmail.com>
References: <b741c2440910260416r5d045024wdb5a68b2311561db@mail.gmail.com>
	<4AE642D7.1070801@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AE642D7.1070801-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 27, 2009 at 8:46 AM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:

> Hi,
>
> Thanks for your report !
>
> Liu Aleaxander wrote:
> > Hi orenl:
> >
> > I met a problem when trying to use these samples given in
> > Documentation/checkpoint. I just followed the instructions in usage.txt
> > to do a self-checkpoint, but with no luck, it failed. Here is a dump of
> > /tmp/cr-test.out and self.image:
> >
> >     $ cat /tmp/cr-test.out
> >     hello, world (80.86)!
> >     count 0 (80.86)!
> >     count 1 (80.96)!
> >     count 2 (81.16)!
> >     ckpt: Invalid argument(-22)
> >
> >     $cat self.image
> >     '[err -22]: not container init
> >
> >
> > Then I searched the Internet and read the readme.txt again, found I may
> > should compiled the 'container' in Kernel, then following the
> > instructions in the lxc main page [http://lxc.sourceforge.net/lxc.html],
> > I recompiled the kernel, to make the 'container' contained in the
> > Kernel, but with no luck, it's still the same; can't work, and with the
> > same error. I am still thinking it's a problem of the container. But I
> > don't know why and how to fix it. So, can you please tell me where is
> > wrong? And how can I use the checkpoint/restart correctly. Thanks!
>
> The problem is in the sample code :(  In particular, it should use
> the CHECKPOINT_SUBTREE flag as an argument to the syscall, rather
> than pass a '0'.
>
> (See also the example in contrib/ directory in user-cr).
>

I checked it again(BTW, I found some new typos, too; I'll patch it later),
but it didn't work either. while, at least, it succeed in checkpointing, but
failed in restarting. A error statement followed just by the restart
command:
$ ./self_restart < self.image
Killed

And here is a small dump of dmesg:
[4959:4959:c/r:ckpt_read_obj:367] type 1 len 72(72,72)
[4959:4959:c/r:_ckpt_read_obj:259] type 4 len 73(73,73)
[4959:4959:c/r:_ckpt_read_obj:259] type 4 len 73(73,73)
[4959:4959:c/r:_ckpt_read_obj:259] type 4 len 73(73,73)
[4959:4959:c/r:ckpt_read_obj:367] type 2 len 16(16,16)
[4959:4959:c/r:do_restore_coord:1176] restore header: 0
[4959:4959:c/r:ckpt_read_obj:367] type 3 len 8(8,8)
[4959:4959:c/r:do_restore_coord:1180] restore container: 0
[4959:4959:c/r:ckpt_read_obj:367] type 101 len 16(16,16)
[4959:4959:c/r:_ckpt_read_obj:259] type 4 len 32(32,32)
[4959:4959:c/r:do_restore_coord:1184] restore tree: 24
[4959:4959:c/r:do_restore_coord:1218] pre restore task: 0
[4959:4959:c/r:ckpt_read_obj:367] type 102 len 64(64,64)
[4959:4959:c/r:_ckpt_read_obj:259] type 5 len 24(24,24)
[4959:4959:c/r:restore_task:879] task 0
[4959:4959:c/r:do_restore_coord:1222] restore task: -22
[4959:4959:c/r:walk_task_subtree:338] total 0 ret 0
[4959:4959:c/r:clear_task_ctx:763] task 4959 clear checkpoint_ctx
[4959:4959:c/r:do_restart:1347] restart err -22, exiting
[4959:4959:c/r:do_restart:1354] sys_restart returns -22
[4959:4959:c/r:restore_debug_free:141] 1 tasks registered, nr_tasks was 0
nr_total 0
[4959:4959:c/r:restore_debug_free:144] active pid was -1, ctx->errno -22
[4959:4959:c/r:restore_debug_free:146] kflags 10 uflags 1 oflags 1
[4959:4959:c/r:restore_debug_free:173] pid 4959 type Coord state Failed


> >
> >
> > BTW,  I'm not sure the output of /tmp/cr-test.out in usage.txt is right.
> > Here is the output(from usage.txt):
> >     $ cat /tmp/cr-rest.out
> >     hello, world (85.46)!
> >     count 0 (85.46)!
> >     count 1 (85.56)!
> >     count 2 (85.76)!
> >     count 3 (86.46)!
> >
> > I think between count2 and count3, there is a statement more: like
> > "checkpoint ret: 1" or others, since at the 2nd loop, it will call
> > checkpoint, and will print the ret in that file.
>
> Good catch...
>
> I pushed fixes to both issues to the git repository.
>
> Thanks,
>
> Oren.
>
> (p.s. please CC the containers mailing list in the future).
>
>


-- 
regards
Liu Aleaxander
