From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 01/24] pidns: Remove races by stopping the caching of
 proc_mnt
Date: Fri, 9 Jul 2010 17:13:41 -0500
Message-ID: <20100709221341.GA31259@hallyn.com>
References: <20100625192945.GA25532@redhat.com>
 <20100625212618.GA11917@us.ibm.com>
 <20100625212758.GA30474@redhat.com>
 <20100625220713.GA31123@us.ibm.com>
 <m1r5jd5l0v.fsf_-_@fess.ebiederm.org>
 <m1mxu15kv4.fsf_-_@fess.ebiederm.org>
 <20100709121425.GB18586@hawkmoon.kerlabs.com>
 <m1lj9k4xfx.fsf@fess.ebiederm.org>
 <20100709141324.GC18586@hawkmoon.kerlabs.com>
 <m1aaq04ph2.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1aaq04ph2.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, Louis Rilling <Louis.Rilling@kerlabs.com>, Linux Containers <containers@lists.osdl.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
...
> @@ -2742,13 +2743,13 @@ void proc_flush_task(struct task_struct *task)
>  
>  	for (i = 0; i <= pid->level; i++) {
>  		upid = &pid->numbers[i];
> -		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
> -					tgid->numbers[i].nr);
> -	}
> +		mnt = get_proc_mnt(upid->ns);

...

> -int pid_ns_prepare_proc(struct pid_namespace *ns)
> +struct vfsmount *get_proc_mnt(struct pid_namespace *ns)
>  {
> -	struct vfsmount *mnt;
> -
> -	mnt = kern_mount_data(&proc_fs_type, ns);
> -	if (IS_ERR(mnt))
> -		return PTR_ERR(mnt);
> -
> -	return 0;
> +	return kern_mount_data(&proc_fs_type, ns);

Uh, that looks like it's got to be a *huge* hit.  Each kern_mount_data()
will at least alloc space for a vfsmnt and proc_fs_type->name.  Once for
each pid level of each exiting task.

(Or am I misreading?)

-serge
