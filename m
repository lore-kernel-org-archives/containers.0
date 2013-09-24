From: James Hogan <james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] sysfs: Allow mounting without CONFIG_NET
Date: Tue, 24 Sep 2013 12:25:49 +0100
Message-ID: <524176BD.9060403@imgtec.com>
References: <878uzmhkqg.fsf@xmission.com> <874naahkng.fsf@xmission.com>
	<524018EA.9070202@imgtec.com>
	<87ioxrrzb6.fsf_-_@tw-ebiederman.twitter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ioxrrzb6.fsf_-_-HxuHnoDHeQZYhcs0q7wBk77fW72O3V7zAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 23/09/13 22:41, Eric W. Biederman wrote:
> 
> In kobj_ns_current_may_mount the default should be to allow the
> mount.  The test is only for a single kobj_ns_type at a time, and unless
> there is a reason to prevent it the mounting sysfs should be allowed.
> Subsystems that are not registered can't have are not involved so can't
> have a reason to prevent mounting sysfs.
> 
> This is a bug-fix to:
>     commit 7dc5dbc879bd0779924b5132a48b731a0bc04a1e
>     Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>     Date:   Mon Mar 25 20:07:01 2013 -0700
>     
>         sysfs: Restrict mounting sysfs
>         
>         Don't allow mounting sysfs unless the caller has CAP_SYS_ADMIN rights
>         over the net namespace.  The principle here is if you create or have
>         capabilities over it you can mount it, otherwise you get to live with
>         what other people have mounted.
>         
>         Instead of testing this with a straight forward ns_capable call,
>         perform this check the long and torturous way with kobject helpers,
>         this keeps direct knowledge of namespaces out of sysfs, and preserves
>         the existing sysfs abstractions.
>         
>         Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
>         Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> That came in via the userns tree during the 3.12 merge window.
>     
> Reported-by: James Hogan <james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Tested-by: James Hogan <james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>

Thanks
James
