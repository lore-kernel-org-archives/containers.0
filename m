From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Re: NFS Kernel server inside a container
Date: Tue, 18 May 2010 23:46:32 +0400
Message-ID: <4BF2EE98.9000904@msgid.tls.msk.ru>
References: <259227.79616.qm@web36101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <259227.79616.qm-UkVgyPgTERivuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Martin Fick <mogulguy-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

18.05.2010 22:51, Martin Fick wrote:
> Hello,
>
> I was wondering if it is possible to run an NFS kernel server inside a linux container?
>
> I tried setting one up on a debian (vserver enabled) kernel, and it seems to start the portmap, rpc.statd, rpc.idmapd rpc.mountd daemons inside the container, but I cannot seem to mount the filesystem from a client.  I do get the following error message on server startup:
>
>    FATAL: Could not load /lib/modules/2.6.32-trunk-vserver-686/modules.dep: No such file or directory

Obviously you have to have necessary modules in the
container in order to _load_ them.  But it is simpler
to pre-load all required modules from the host system
instead.

> When trying to mount on the client, after blocking on the mount for a while, I get:
>
>    mount.nfs: mount system call failed

Sure: because nfs services aren't started.

> Any thoughts?  Has anyone else done this?  Should this be possible in the first place?  Thanks,

Actually it does not work even after solving
module issue.  I asked about this very issue
at the end of last year (I think), but no one
answered.  It looks like knfsd threads are
working in "global" (i.e host) namespace, not
in the container namespace, or the said
namespace isn't being set up correctly in
the kernel.  In any way, nfs service needs
to be "containerized" properly before being
useful inside a container, which is not done
currently, it seems.

/mjt
