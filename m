From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: ioctl CAP_LINUX_IMMUTABLE is checked in the wrong namespace
Date: Tue, 29 Apr 2014 18:52:51 +0000
Message-ID: <20140429185251.GA27969@ubuntumail>
References: <535FADDA.2070803@1h.com>
 <20140429183534.GB19325@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140429183534.GB19325-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Marian Marinov <mm-108MBtLGafw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Theodore Ts'o (tytso-3s7WtUTddSA@public.gmane.org):
> On Tue, Apr 29, 2014 at 04:49:14PM +0300, Marian Marinov wrote:
> > 
> > I'm proposing a fix to this, by replacing the capable(CAP_LINUX_IMMUTABLE)
> > check with ns_capable(current_cred()->user_ns, CAP_LINUX_IMMUTABLE).
> 
> Um, wouldn't it be better to simply fix the capable() function?
> 
> /**
>  * capable - Determine if the current task has a superior capability in effect
>  * @cap: The capability to be tested for
>  *
>  * Return true if the current task has the given superior capability currently
>  * available for use, false if not.
>  *
>  * This sets PF_SUPERPRIV on the task if the capability is available on the
>  * assumption that it's about to be used.
>  */
> bool capable(int cap)
> {
> 	return ns_capable(&init_user_ns, cap);
> }
> EXPORT_SYMBOL(capable);
> 
> The documentation states that it is for "the current task", and I
> can't imagine any use case, where user namespaces are in effect, where
> using init_user_ns would ever make sense.

the init_user_ns represents the user_ns owning the object, not the
subject.

The patch by Marian is wrong.  Anyone can do 'clone(CLONE_NEWUSER)',
setuid(0), execve, and end up satisfying 'ns_capable(current_cred()->userns,
CAP_SYS_IMMUTABLE)' by definition.

So NACK to that particular patch.  I'm not sure, but IIUC it should be
safe to check against the userns owning the inode?

> No?  Otherwise, pretty much every single use of capable() would be
> broken, not just this once instances in ext4/ioctl.c.
> 
> 					- Ted
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
