From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] cr: pts: detect use of multiple devpts mounts in
	container
Date: Thu, 29 Apr 2010 10:41:06 -0700
Message-ID: <20100429174106.GX32490@count0.beaverton.ibm.com>
References: <20100429152848.GA7090@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100429152848.GA7090-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Thu, Apr 29, 2010 at 10:28:48AM -0500, Serge E. Hallyn wrote:
> We don't support multiple devpts mounts in a container.  So
> bail on checkpoint if a container has them.  This will cause
> checkpoint to fail of a container which still has a pty from
> parent container in use.
> 
> Note one issue with this is the register_checkpoint_obj(&&ckpt_obj_ptsns_ops)
> done from module_init().  We either need to add a matching unregister,

That's a rather significant problem. We need a matching
unregister_checkpoint_obj() and we need to be sure that none of the functions
specified in the ckpt_obj_ops are executing when the module is finally removed.

Is there a way to do that without holding any locks during ckpt_obj_op
calls? I've been thinking about how to do it with RCU:

	struct ckpt_obj_ops *ops;

	rcu_read_lock();
	ops = ckpt_obj_ops[type];
	get_module(ops->owner); /* try_module_get() */
	rcu_read_unlock();
	ops->op(...);
	put_module(ops->owner);

That should also ensure that the module won't be removed until the operation
is complete. However it seems quite absurd to grab a reference to a module
just to use its grab and drop ops. We'll probably spend more time in the
module code...

Regardless, the register side requires a spinlock to protect writes to the
ckpt_obj_ops array (inside register_checkpoint_obj()).

Cheers,
	-Matt
