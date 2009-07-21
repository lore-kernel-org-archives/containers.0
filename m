From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix reverse unlock sequence in cgroup_get_sb
Date: Tue, 21 Jul 2009 17:31:06 +0530
Message-ID: <20090721120106.GW24157@balbir.in.ibm.com>
References: <1248171926-20232-1-git-send-email-dfeng@redhat.com>
	<20090721111019.GV24157@balbir.in.ibm.com>
	<8522a3d30907210438u6fce081fi835bf964d0c01e8a@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8522a3d30907210438u6fce081fi835bf964d0c01e8a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zefan Li <lizf.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

* Zefan Li <lizf.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2009-07-21 19:38:03]:

> 2009/7/21, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>:
> >
> > * Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-07-21 18:25:26]:
> >
> > > In cgroup_get_sb, the lock sequence is:
> > >       mutex_lock(&inode->i_mutex);
> > >       mutex_lock(&cgroup->mutex);
> > > so the last unlock sequence should be:
> > >       mutex_unlock(&cgroup->mutex);
> > >       mutex_unlock(&inode->i_mutex);
> > >
> > > Signed-off-by: Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > ---
> > >  kernel/cgroup.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > >
> > > diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> > > index 3737a68..11ef162 100644
> > > --- a/kernel/cgroup.c
> > > +++ b/kernel/cgroup.c
> > > @@ -1140,8 +1140,8 @@ static int cgroup_get_sb(struct file_system_type
> > *fs_type,
> > >               BUG_ON(root->number_of_cgroups != 1);
> > >
> > >               cgroup_populate_dir(root_cgrp);
> > > -             mutex_unlock(&inode->i_mutex);
> > >               mutex_unlock(&cgroup_mutex);
> > > +             mutex_unlock(&inode->i_mutex);
> > >       }
> > >
> >
> > Seems reasonable to me. You might also want to mention that elsewhere
> > the sequence is unlock cgroup_mutex followed by inode->i_mutex.
> >
> > Acked-by: Balbir Singh balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
> 
> 
> No, the unlock order is irrelevant. It's the lock order that matters. So
> this patch
> fixes nothing.
> 
> Xiaotian, you didn't run into deadlock, did you?
>


Li, Consider the following


lock(A)
lock(B)
unlock(A) 
unlock(B)

Tomorrow if a unsuspecting programmer does this

lock(A)
lock(B)
unlock(A) 

code block 

unlock(B)


What protects code block? lock B? Is that the intention?

-- 
	Balbir
