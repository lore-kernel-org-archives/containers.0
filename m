From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Sun, 21 Mar 2010 20:37:24 -0700
Message-ID: <20100322033724.GA20796__33534.6897169531$1269229103$gmane$org@count0.beaverton.ibm.com>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
	<F18D161D-850B-4C82-83D5-1F19D573E84F@sun.com>
	<20100320044310.GC2887@count0.beaverton.ibm.com>
	<20100321172703.GC4174@shareable.org>
	<20100322010606.GG2887@count0.beaverton.ibm.com>
	<20100322022003.GA16462@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100322022003.GA16462-yetKDKU6eevNLxjTenLetw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Mar 22, 2010 at 02:20:03AM +0000, Jamie Lokier wrote:
> Matt Helsley wrote:
> > On Sun, Mar 21, 2010 at 05:27:03PM +0000, Jamie Lokier wrote:
> > > Matt Helsley wrote:
> > > > > That said, if the intent is to allow the restore to be done on
> > > > > another node with a "similar" filesystem (e.g. created by rsync/node
> > > > > image), instead of having a coherent distributed filesystem on all
> > > > > of the nodes then the filename makes sense.
> > > > 
> > > > Yes, this is the intent.
> > > 
> > > I would worry about programs which are using files which have been
> > > deleted, renamed, or (very common) renamed-over by another process
> > > after being opened, as there's a good chance they will successfully
> > > open the wrong file after c/r, and corrupt state from then on.
> > 
> > The code in the patches does check for unlinked files and refuses
> > to checkpoint if an unlinked file is open. Yes, this limits the usefulness
> > of the code somewhat but it's a problem we can solve and c/r is still quite
> > useful without the solution.
> > 
> > We've done our best to try and reach that ideal. You're welcome to have a
> > look at the code to see if you can find any ways in which we haven't.
> > Here's the code that refuses to checkpoint unsupported files. I think
> > it's pretty easy to read:
> 
> From a very quick read, 
> 
> >         if (d_unlinked(file->f_dentry)) {
> >                 ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
> >                          file);
> 
> Hmm.
> 
> I wonder if d_unlinked() is always true for a file which is opened,
> unlinked or renamed over, but has a hard link to it from elsewhere so
> the on-disk file hasn't gone away.

Well, if the on-disk file hasn't gone away due to a hardlink then we
won't need to save the file in the checkpoint image -- the filesystem
content backup done during checkpoint should also get the file contents.

> 
> I guess it probably is.  That's kinda neat!  I'd hoped there would be a
> good reason for f_dentry eventually ;-)
> 
> What about files opened through /proc/self/fd/N before or after the
> original file was unlinked/renamed-over.  Where does the dentry point?

Before the unlink it will result in the same file being opened. If it's
opened by a task being checkpointed then we'll be in the same situation
as the "self" task. If it's opened by a task not being checkpointed then
the "leak detection" code will notice that there's an unaccounted reference
to the file and checkpoint will fail.

That code is in checkpoint/objhash.c. It works by doing two passes:
	1. Collect references
	2. Checkpoint referenced objects

We only do the second pass if the ref count matches the number of times
we've "collected" the file (I added comments to the .ref_foo = ops so you
don't need to see them to get the idea):

static struct ckpt_obj_ops ckpt_obj_ops[] = {
	...
        /* file object */
        {
                .obj_name = "FILE",
                .obj_type = CKPT_OBJ_FILE,
                .ref_drop = obj_file_drop, /* aka fput */
                .ref_grab = obj_file_grab, /* aka get_file */
                .ref_users = obj_file_users, /* does atomic read of f_count */
                .checkpoint = checkpoint_file,
                .restore = restore_file,
        },
	...
};
...
/**
 * ckpt_obj_contained - test if shared objects are contained in checkpoint
 * @ctx: checkpoint context
 *
 * Loops through all objects in the table and compares the number of
 * references accumulated during checkpoint, with the reference count
 * reported by the kernel.
 *
 * Return 1 if respective counts match for all objects, 0 otherwise.
 */
int ckpt_obj_contained(struct ckpt_ctx *ctx)
{
        struct ckpt_obj *obj;
        struct hlist_node *node;

        /* account for ctx->{file,logfile} (if in the table already) */
        ckpt_obj_users_inc(ctx, ctx->file, 1);
        if (ctx->logfile)
                ckpt_obj_users_inc(ctx, ctx->logfile, 1);
        /* account for ctx->root_nsproxy (if in the table already) */
        ckpt_obj_users_inc(ctx, ctx->root_nsproxy, 1);

        hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
                if (!obj->ops->ref_users)
                        continue;

                if (obj->ops->obj_type == CKPT_OBJ_SOCK)
                        obj_sock_adjust_users(obj);

                if (obj->ops->ref_users(obj->ptr) != obj->users) {
                        ckpt_err(ctx, -EBUSY,
                                 "%(O)%(P)%(S)Usage leak (%d != %d)\n",
                                 obj->objref, obj->ptr, obj->ops->obj_name,
                                 obj->ops->ref_users(obj->ptr), obj->users);
                        return 0;
                }
        }

        return 1;
}
...

So that hopefully addresses your questions regarding the use of the symlinks
before the unlink.

After the unlink those symlinks are broken since they have "(deleted)"
appended. Making sure they are broken after restart is one detail I've
thought about. To make it perfect I think we could:

	1. Move any existing file at the original symlinked path to a
		temporary location.
	2. Restore the "unlinked" file to that location.
		(in quotes since it's not unlinked yet)
	3. Open the "unlinked" file.
	4. Unlink the file again.
	5. Move the existing file back from the temporary location.

As with relinking, we need a good way to do the "temporary location".
That is complicated because we need to choose a location that we have
permission to write to, always exists during restart, and is guaranteed
not to have files in it. Relinking the file shifts these problems from
restart to checkpoint.

In case you're bored, before Oren posted these patches I wrote:
	https://ckpt.wiki.kernel.org/index.php/Checklist/UnlinkedFiles

and there's lots of info related to what we do and don't support,
many related to files in one way or another, in the table at:
	https://ckpt.wiki.kernel.org/index.php/Checklist

I'll update that page with some of my responses above. Getting your
thoughts on my ideas outlined above would be excellent. If you've
got some counter proposals I'd be happy to hear them too. I'll add
a reference to this thread and an edited collection of my rambling
responses to that page if you like.

Cheers,
	-Matt Helsley
