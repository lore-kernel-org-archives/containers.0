From: John Paul Walters <jpnwalters-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: multi-threaded app fails to restart
Date: Tue, 20 Jul 2010 20:03:59 -0400
Message-ID: <AANLkTinZYiWPtSegjRJWnlc6hipFAZyujr8-2ug6ettF@mail.gmail.com>
References: <AANLkTilxfsYGyYLwO__VmDLSFQ_s_Qe03G49kIEztVja@mail.gmail.com>
	<1279569285.25071.98.camel@localhost>
	<AANLkTimpXSXQr1wew1wvZKnBFsOXD7f2tblY4EGmJoFM@mail.gmail.com>
	<4C4516DD.1000809@cs.columbia.edu>
	<AANLkTimPENgm-LSh6iMv2uxegRdHEivbGMTYmEfiOEJG@mail.gmail.com>
	<Pine.LNX.4.64.1007201906370.15255@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.1007201906370.15255-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 20, 2010 at 7:12 PM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
>
> Hi John
>
> In your program, it is a thread of the root task (of the hierarchy)
> that is missed. Indeed the previous patch was incomplete - it did
> fix the non-root-threads case but spoiled the root-threads case.
> That was silly... well, can you try this little patch:
>
> Thanks for following up, was very helpful !
>
> Oren.

Hi Oren,

I'm still unable to fully restart the application with your patch, but
the result is now different.  If I attempt to restart using  --pidns
and -F, both threads are created and frozen.  However, as soon as I
thaw them I get a segfault.  If I attempt to restart them without the
--pidns option, I get a message from restart indicating that it's
about to call sys_restart and restart hangs.  I also have the
following in my syslog:


[ 1482.348060] [3753:3753:c/r:walk_task_subtree:633] total 2 ret 1
[ 1482.348060] [3753:3753:c/r:prepare_descendants:1148] nr 2/2
[ 1482.348060] [3753:3753:c/r:do_restore_coord:1320] restore prepare: 2
[ 1541.864073] [err -512][pos 419][E @ do_ghost_task:973]ghost restart fail=
ed
[ 1541.864343] [err -512][pos 419][E @ do_restore_task:1084]task restart fa=
iled
[ 1541.864346] [3755:3755:c/r:clear_task_ctx:852] task 3755 clear checkpoin=
t_ctx
[ 1541.864349] [3755:3755:c/r:do_restart:1444] restart err -4, exiting
[ 1541.864352] [3755:3755:c/r:do_restart:1451] sys_restart returns -4
[ 1541.864366] [3757:3757:c/r:wait_checkpoint_ctx:938]
wait_checkpoint_ctx: failed (-512)
[ 1541.864368] [3757:3757:c/r:do_restart:1444] restart err -4, exiting
[ 1541.864371] [3757:3757:c/r:do_restart:1451] sys_restart returns -4
[ 1541.864689] [3753:3753:c/r:wait_all_tasks_finish:1173] final sync
kflags 0x1a (ret 0)
[ 1541.864692] [3753:3753:c/r:do_restore_coord:1325] restore finish: 0
[ 1541.864694] [3753:3753:c/r:do_restore_coord:1331] restore deferqueue: 0
[ 1541.864698] [err -512][pos 419][E @
ckpt_read_obj_type:426]Expecting to read type 9001
[ 1541.864700] [3753:3753:c/r:do_restore_coord:1336] restore tail: -512
[ 1541.864703] [err -512][pos 419][E @ do_restore_coord:1350]restart
failed (coordinator)
[ 1541.864706] [3753:3753:c/r:walk_task_subtree:633] total 0 ret 0
[ 1541.864709] [3753:3753:c/r:clear_task_ctx:852] task 3753 clear checkpoin=
t_ctx
[ 1541.864715] [3753:3753:c/r:do_restart:1451] sys_restart returns -4
[ 1541.864718] [3753:3753:c/r:restore_debug_free:144] 3 tasks
registered, nr_tasks was 0 nr_total 1
[ 1541.864721] [3753:3753:c/r:restore_debug_free:147] active pid was
0, ctx->errno -512
[ 1541.864723] [3753:3753:c/r:restore_debug_free:149] kflags 26 uflags
0 oflags 1
[ 1541.864726] [3753:3753:c/r:restore_debug_free:151] task[0] to run 3755
[ 1541.864728] [3753:3753:c/r:restore_debug_free:151] task[1] to run 3757
[ 1541.864731] [3753:3753:c/r:restore_debug_free:176] pid 3753 type
Coord state Failed
[ 1541.864735] [3753:3753:c/r:restore_debug_free:176] pid 3755 type
Root state Failed
[ 1541.864737] [3753:3753:c/r:restore_debug_free:176] pid 3756 type
Ghost state Failed

thanks,
JP

>
> ---
> diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
> index 171c867..3288af0 100644
> --- a/kernel/checkpoint/sys.c
> +++ b/kernel/checkpoint/sys.c
> @@ -605,13 +605,13 @@ int walk_task_subtree(struct task_struct *root,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* if not last thread - proceed with thread=
 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task =3D next_thread(task);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!thread_group_leader(task))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* by definition, skip siblings of root */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (task !=3D root) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* if not last thread - pro=
ceed with thread */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task =3D next_thread(task);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!thread_group_leader(ta=
sk))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* if has sibling - procee=
d with sibling */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!list_is_last(&task->s=
ibling, &parent->children)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task =3D l=
ist_entry(task->sibling.next,
> ---
