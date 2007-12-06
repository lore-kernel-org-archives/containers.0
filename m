From: Vitaliy Gusev <vgusev@openvz.org>
Subject: Re: [RFC][PATCH] Pid namespaces vs locks interaction
Date: Thu, 6 Dec 2007 18:19:59 +0300
Message-ID: <200712061819.59841.vgusev@openvz.org>
References: <200712061411.32159.vgusev@openvz.org> <200712061557.29543.vgusev@openvz.org> <20071206145340.GB7083@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20071206145340.GB7083@sergelap.austin.ibm.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On 6 December 2007 17:53:40 Serge E. Hallyn wrote:
> Quoting Vitaliy Gusev (vgusev@openvz.org):
> > Hello!
> >
> > I am working on pid namespaces vs locks interaction and want to evaluate
> > the idea.
> > fcntl(F_GETLK,..) can return pid of process for not current pid namespace
> > (if process is belonged to the several namespaces). It is true also for
> > pids in /proc/locks. So correct behavior is saving pointer to the struct
> > pid of the process lock owner.
> > --
> > Thank,
> > Vitaliy Gusev
> >
> > diff --git a/fs/locks.c b/fs/locks.c
> > index 8b8388e..d2d3d75 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -125,6 +125,7 @@
> >  #include <linux/syscalls.h>
> >  #include <linux/time.h>
> >  #include <linux/rcupdate.h>
> > +#include <linux/pid_namespace.h>
> >
> >  #include <asm/semaphore.h>
> >  #include <asm/uaccess.h>
> > @@ -185,6 +186,7 @@ void locks_init_lock(struct file_lock *fl)
> >  	fl->fl_fasync = NULL;
> >  	fl->fl_owner = NULL;
> >  	fl->fl_pid = 0;
> > +	fl->fl_nspid = NULL;
>
> The idea seems right, but why are you keeping fl->fl_pid around?
>
> Seems like the safer thing to do would be to have a separate
> struct user_flock, with an integer pid, for communicating to userspace,
> and a struct flock, with struct pid, for kernel use?  Then fcntl_getlk()
> and fcntl_setlk() do the appropriate conversions.

fl_pid is used by nfs, fuse and gfs2. For instance nfs  keeps in fl_pid some 
unique id to identify locking process between hosts - it is not a process 
pid.

>
> thanks,
> -serge
> -
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thank,
Vitaliy Gusev
