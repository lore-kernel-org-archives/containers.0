From: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [RFC][PATCH v2] mount: In propagate_umount handle overlapping
	mount propagation trees
Date: Mon, 31 Oct 2016 23:14:23 -0700
Message-ID: <20161101061422.GA14866@outlook.office365.com>
References: <87wphb4pjn.fsf@x220.int.ebiederm.org>
	<8737jy3htt.fsf_-_@x220.int.ebiederm.org>
	<20161018024000.GA4901@outlook.office365.com>
	<87r37e9mnj.fsf@xmission.com> <877f95ngpr.fsf_-_@xmission.com>
	<20161020213052.GA25226@outlook.office365.com>
	<87pomtec6c.fsf@xmission.com> <877f90b27o.fsf_-_@xmission.com>
	<20161025205846.GA25080@outlook.office365.com>
	<87mvhs14s7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87mvhs14s7.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 25, 2016 at 04:45:44PM -0500, Eric W. Biederman wrote:
> Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> writes:
> >
> > From 8e0f45c0272aa1f789d1657a0acc98c58919dcc3 Mon Sep 17 00:00:00 2001
> > From: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> > Date: Tue, 25 Oct 2016 13:57:31 -0700
> > Subject: [PATCH] mount: skip all mounts from a shared group if one is marked
> >
> > If we meet a marked mount, it means that all mounts from
> > its group have been already revised.
> >
> > Signed-off-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> > ---
> >  fs/pnode.c | 18 +++++++++++++++---
> >  1 file changed, 15 insertions(+), 3 deletions(-)
> >
> > diff --git a/fs/pnode.c b/fs/pnode.c
> > index 8fd1a3f..ebb7134 100644
> > --- a/fs/pnode.c
> > +++ b/fs/pnode.c
> > @@ -426,10 +426,16 @@ static struct mount *propagation_visit_child(struct mount *last_child,
> >  		if (child && !IS_MNT_MARKED(child))
> >  			return child;
> >  
> > -		if (!child)
> > +		if (!child) {
> >  			m = propagation_next(m, origin);
> > -		else
> > +		} else {
> > +			if (IS_MNT_MARKED(child)) {
> > +				if (m->mnt_group_id == origin->mnt_group_id)
> > +					return NULL;
> > +				m = m->mnt_master;
> > +			}
> >  			m = propagation_next_sib(m, origin);
> > +		}
> >  	}
> >  	return NULL;
> >  }
> > @@ -456,8 +462,14 @@ static struct mount *propagation_revisit_child(struct mount *last_child,
> >  
> >  		if (!child)
> >  			m = propagation_next(m, origin);
> > -		else
> > +		else {
> > +			if (!IS_MNT_MARKED(child)) {
> > +				if (m->mnt_group_id == origin->mnt_group_id)
> > +					return NULL;
> > +				m = m->mnt_master;
> > +			}
> >  			m = propagation_next_sib(m, origin);
> > +		}
> >  	}
> >  	return NULL;
> >  }
> 
> That is certainly interesting.  The problem is that the reason we were
> going slow is that there were in fact mounts that had not been traversed
> in the share group.
> 
> And in fact the entire idea of visiting a vfsmount mountpoint pair
> exactly once is wrong in the face of shadow mounts.  For a vfsmount
> mountpoint pair that has shadow mounts the number of shadow mounts needs
> to be descreased by one each time the propgation tree is traversed
> during unmount. Which means that as far as I can see we have to kill
> shadow mounts to correctly optimize this code.  Once shadow mounts are
> gone I don't know of a case where need your optimization.

I am not sure that now shadow mounts are worked as you described
here. start_umount_propagation() doesn't remove a mount from mnt_hash,
so in a second time we will look up the same mount again.

Look at this script:

[root@fc24 mounts]# cat ./opus02.sh
set -e
mkdir -p /mnt
mount -t tmpfs zdtm /mnt
mkdir -p /mnt/A/a
mkdir -p /mnt/B/a
mount --bind --make-shared /mnt/A /mnt/A
mount --bind /mnt/A /mnt/B
mount --bind /mnt/A/a /mnt/A/a
mount --bind /mnt/A/a /mnt/A/a

umount -l /mnt/A
cat /proc/self/mountinfo | grep zdtm

[root@fc24 mounts]# unshare --propagation private -m ./opus02.sh
159 121 0:46 / /mnt rw,relatime - tmpfs zdtm rw
162 159 0:46 /A /mnt/B rw,relatime shared:67 - tmpfs zdtm rw
167 162 0:46 /A/a /mnt/B/a rw,relatime shared:67 - tmpfs zdtm rw

We mount nothing into /mnt/B, but when we umount everything from A, we
still have something in B.

Thanks,
Andrei
> 
> I am busily verifying my patch to kill shadow mounts but the following
> patch is the minimal version.  As far as I can see propagate_one
> is the only place we create shadow mounts, and holding the
> namespace_lock over attach_recursive_mnt, propagate_mnt, and
> propgate_one is sufficient for that __lookup_mnt to be competely safe.
> 
> diff --git a/fs/pnode.c b/fs/pnode.c
> index 234a9ac49958..b14119b370d4 100644
> --- a/fs/pnode.c
> +++ b/fs/pnode.c
> @@ -217,6 +217,9 @@ static int propagate_one(struct mount *m)
>         /* skip if mountpoint isn't covered by it */
>         if (!is_subdir(mp->m_dentry, m->mnt.mnt_root))
>                 return 0;
> +       /* skip if mountpoint already has a mount on it */
> +       if (__lookup_mnt(&m->mnt, mp->m_dentry))
> +               return 0;
>         if (peers(m, last_dest)) {
>                 type = CL_MAKE_SHARED;
>         } else {
> 
> If you run with that patch you will see that there are go faster stripes.
> 
> Eric
> 
