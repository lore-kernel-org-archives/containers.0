From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Wed, 16 Jun 2010 18:15:37 +0200
Message-ID: <20100616161537.GA16877@hawkmoon.kerlabs.com>
References: <1276703910-16936-1-git-send-email-louis.rilling@kerlabs.com> <4C18F625.9040107@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C18F625.9040107@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 16/06/10 20:04 +0400, Pavel Emelyanov wrote:
> > +void proc_new_task(struct task_struct *task)
> > +{
> > +	struct pid *pid;
> > +	int i;
> > +
> > +	if (!task->pid)
> > +		return;
> > +
> > +	pid = task_pid(task);
> > +	for (i = 0; i <= pid->level; i++)
> > +		mntget(pid->numbers[i].ns->proc_mnt);
> 
> I feel I'm missing something significant, but this patch breaks
> the mntget/mntput balance. Doesn't it?

Why?

all mntget() here have their mntput() in proc_flush_task(). At least, this is
the intent...

Thanks,

Louis

-- 
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes
