From: Brad Boyer <flar@allandria.com>
Subject: Re: [RFC][PATCH] Pid namespaces vs locks interaction
Date: Sat, 8 Dec 2007 14:21:19 -0800
Message-ID: <20071208222119.GB8838@cynthia.pants.nu>
References: <200712061411.32159.vgusev@openvz.org> <200712061557.29543.vgusev@openvz.org> <20071206145340.GB7083@sergelap.austin.ibm.com> <200712061819.59841.vgusev@openvz.org> <20071206155130.GA12463@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071206155130.GA12463@sergelap.austin.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Vitaliy Gusev <vgusev@openvz.org>, "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Thu, Dec 06, 2007 at 09:51:30AM -0600, Serge E. Hallyn wrote:
> Quoting Vitaliy Gusev (vgusev@openvz.org):
> > fl_pid is used by nfs, fuse and gfs2. For instance nfs  keeps in fl_pid some 
> > unique id to identify locking process between hosts - it is not a process 
> > pid.
> 
> Ok, but so the struct user_flock->fl_pid is being set to the task's
> virtual pid, while the struct kernel_flock->fl_pid is being set to
> task->tgid for nfsd use.
> 
> Why can't nfs just generate a uniqueid from the struct pid when it
> needs it?
> 
> Fuse just seems to copy the pid to report it to userspace, so it would
> just copy pid_vnr(kernel_flock->pid) into user_flock->fl_pid.
> 
> Anyway I haven't looked at all the uses of struct fl_pid, but you
> can always get the pidnr back from the struct pid if needed so there
> should be no problem.

Perhaps we could add a sysid field like some unix systems have. Here
is the flock structure documentation from Sun:

----
The flock structure contains at least the following elements:

short   l_type;       /* lock operation type */ 
short   l_whence;     /* lock base indicator */ 
off_t   l_start;      /* starting offset from base */ 
off_t   l_len;        /* lock length; l_len == 0 means
                         until end of file */ 
int     l_sysid;      /* system ID running process holding lock */ 
pid_t   l_pid;        /* process ID of process holding lock */ 
----

Using the sysid could show that the pid field refers to a separate
namespace, and might also be useful for NFS to show that the lock
is really held by a process on a different system. This would also
be something we could export to user space in a way that some
programs are already written to expect and handle properly.

	Brad Boyer
	flar@allandria.com

