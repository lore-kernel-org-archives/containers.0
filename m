From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH -mm] remove node_ prefix_from ns subsystem
Date: Thu, 22 May 2008 09:36:23 +0200
Message-ID: <48352277.4010703@fr.ibm.com>
References: <48344409.9090903@fr.ibm.com> <20080521220657.12e8e8c9.akpm@linux-foundation.org> <6599ad830805220011u77313ed7s2c0c9d4a658133cc@mail.gmail.com> <20080522003213.d677ba30.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933981AbYEVHgo@vger.kernel.org>
In-Reply-To: <20080522003213.d677ba30.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
> On Thu, 22 May 2008 00:11:56 -0700 "Paul Menage" <menage@google.com> wrote:
> 
>> On Wed, May 21, 2008 at 10:06 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>>>> --- 2.6.26-rc2-mm1.orig/kernel/cgroup.c
>>>> +++ 2.6.26-rc2-mm1/kernel/cgroup.c
>>>> @@ -2903,7 +2903,7 @@ int cgroup_clone(struct task_struct *tsk
>>>>       cg = tsk->cgroups;
>>>>       parent = task_cgroup(tsk, subsys->subsys_id);
>>>>
>>>> -     snprintf(nodename, MAX_CGROUP_TYPE_NAMELEN, "node_%d", tsk->pid);
>>>> +     snprintf(nodename, MAX_CGROUP_TYPE_NAMELEN, "%d", tsk->pid);
>>>>
>>>>       /* Pin the hierarchy */
>>>>       atomic_inc(&parent->root->sb->s_active);
>>> This is user-visible, isn't it?  Been there since October.  How can we
>>> safely change it now?
>> It is user-visible, but I'd be extremely surprised if anyone was
>> depending on it or even using it at this point.
> 
> After six months?

yes that's what we believe also.

> Oh well, I guess the number is small, and they'll know how to fix it.
> 
> What is the reason for making this change?

the 'node_' prefix really is superfluous and misleading. what's a node ?

C.
