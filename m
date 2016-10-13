From: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [RFC][PATCH] mount: In mark_umount_candidates and
	__propogate_umount visit each mount once
Date: Thu, 13 Oct 2016 14:46:51 -0700
Message-ID: <20161013214650.GB19836__32254.7824158848$1476399329$gmane$org@outlook.office365.com>
References: <1476141965-21429-1-git-send-email-avagin@openvz.org>
	<877f9c6ui8.fsf@x220.int.ebiederm.org>
	<87pon458l1.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87pon458l1.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Oct 13, 2016 at 02:53:46PM -0500, Eric W. Biederman wrote:
> 
> Adrei Vagin pointed out that time to executue propagate_umount can go
> non-linear (and take a ludicrious amount of time) when the mount
> propogation trees of the mounts to be unmunted by a lazy unmount
> overlap.
> 
> Solve this in the most straight forward way possible, by adding a new
> mount flag to mark parts of the mount propagation tree that have been
> visited, and use that mark to skip parts of the mount propagation tree
> that have already been visited during an unmount.  This guarantees
> that each mountpoint in the possibly overlapping mount propagation
> trees will be visited exactly once.
> 
> Add the functions propagation_visit_next and propagation_revisit_next
> to coordinate setting and clearling the visited mount mark.
> 
> Here is a script to generate such mount tree:
> $ cat run.sh
> mount -t tmpfs test-mount /mnt
> mount --make-shared /mnt
> for i in `seq $1`; do
>         mkdir /mnt/test.$i
>         mount --bind /mnt /mnt/test.$i
> done
> cat /proc/mounts | grep test-mount | wc -l
> time umount -l /mnt
> $ for i in `seq 10 16`; do echo $i; unshare -Urm bash ./run.sh $i; done
> 
> Here are the performance numbers with and without the patch:
> 
> mounts | before | after (real sec)
> -----------------------------
>   1024 |  0.071 | 0.024
>   2048 |  0.184 | 0.030
>   4096 |  0.604 | 0.040
>   8912 |  4.471 | 0.043
>  16384 | 34.826 | 0.082
>  32768 |        | 0.151
>  65536 |        | 0.289
> 131072 |        | 0.659
> 
> Andrei Vagin fixing this performance problem is part of the
> work to fix CVE-2016-6213.
> 
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Reported-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
> 
> Andrei can you take a look at this patch and see if you can see any
> problems.  My limited testing suggests this approach does a much better
> job of solving the problem you were seeing.  With the time looking
> almost linear in the number of mounts now.

I read this patch and I like the idea.

Then I run my tests and one of them doesn't work with this patch.
I haven't found a reason yet.

Here is the test:

[root@fc24 mounts]# cat run.sh
set -e
mount -t tmpfs zdtm /mnt
mkdir -p /mnt/1 /mnt/2
mount -t tmpfs zdtm /mnt/1
mount --make-shared /mnt/1
for i in `seq $1`; do
	mount --bind /mnt/1 `mktemp -d /mnt/1/test.XXXXXX`
done
mount --rbind /mnt/1 /mnt/2
cat /proc/self/mountinfo | grep zdtm | wc -l
time umount -l /mnt/1
cat /proc/self/mountinfo | grep zdtm | wc -l
umount /mnt/2


[root@fc24 mounts]# unshare -Urm ./run.sh  5
65

real	0m0.014s
user	0m0.000s
sys	0m0.004s
33
umount: /mnt/2: target is busy
        (In some cases useful info about processes that
         use the device is found by lsof(8) or fuser(1).)

> 
>  fs/pnode.c            | 125 ++++++++++++++++++++++++++++++++++++++++++++++++--
>  fs/pnode.h            |   4 ++
>  include/linux/mount.h |   2 +
>  3 files changed, 126 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/pnode.c b/fs/pnode.c
> index 234a9ac49958..3acce0c75f94 100644
> --- a/fs/pnode.c
> +++ b/fs/pnode.c
> @@ -164,6 +164,120 @@ static struct mount *propagation_next(struct mount *m,
>  	}
>  }
>  
> +/*
> + * get the next mount in the propagation tree (that has not been visited)
> + * @m: the mount seen last
> + * @origin: the original mount from where the tree walk initiated
> + *
> + * Note that peer groups form contiguous segments of slave lists.
> + * We rely on that in get_source() to be able to find out if
> + * vfsmount found while iterating with propagation_next() is
> + * a peer of one we'd found earlier.
> + */
> +static struct mount *propagation_visit_next(struct mount *m,
> +					    struct mount *origin)
> +{
> +	/* Has this part of the propgation tree already been visited? */
> +	if (IS_MNT_VISITED(m))
> +		return NULL;
> +
> +	SET_MNT_VISITED(m);
> +
> +	/* are there any slaves of this mount? */
> +	if (!list_empty(&m->mnt_slave_list)) {
> +		struct mount *slave = first_slave(m);
> +		while (1) {
> +			if (!IS_MNT_VISITED(slave))
> +				return slave;
> +			if (slave->mnt_slave.next == &m->mnt_slave_list)
> +				break;
> +			slave = next_slave(slave);
> +		}
> +	}
> +	while (1) {
> +		struct mount *master = m->mnt_master;
> +
> +		if (master == origin->mnt_master) {
> +			struct mount *next = next_peer(m);
> +			while (1) {
> +				if (next == origin)
> +					return NULL;
> +				if (!IS_MNT_VISITED(next))
> +					return next;
> +				next = next_peer(next);
> +			}
> +		} else {
> +			while (1) {
> +				if (m->mnt_slave.next == &master->mnt_slave_list)
> +					break;
> +				m = next_slave(m);
> +				if (!IS_MNT_VISITED(m))
> +					return m;
> +			}
> +		}
> +
> +		/* back at master */
> +		m = master;
> +	}
> +}
> +
> +/*
> + * get the next mount in the propagation tree (that has not been revisited)
> + * @m: the mount seen last
> + * @origin: the original mount from where the tree walk initiated
> + *
> + * Note that peer groups form contiguous segments of slave lists.
> + * We rely on that in get_source() to be able to find out if
> + * vfsmount found while iterating with propagation_next() is
> + * a peer of one we'd found earlier.
> + */
> +static struct mount *propagation_revisit_next(struct mount *m,
> +					      struct mount *origin)
> +{
> +	/* Has this part of the propgation tree already been revisited? */
> +	if (!IS_MNT_VISITED(m))
> +		return NULL;
> +
> +	CLEAR_MNT_VISITED(m);
> +
> +	/* are there any slaves of this mount? */
> +	if (!list_empty(&m->mnt_slave_list)) {
> +		struct mount *slave = first_slave(m);
> +		while (1) {
> +			if (IS_MNT_VISITED(slave))
> +				return slave;
> +			if (slave->mnt_slave.next == &m->mnt_slave_list)
> +				break;
> +			slave = next_slave(slave);
> +		}
> +	}
> +	while (1) {
> +		struct mount *master = m->mnt_master;
> +
> +		if (master == origin->mnt_master) {
> +			struct mount *next = next_peer(m);
> +			while (1) {
> +				if (next == origin)
> +					return NULL;
> +				if (IS_MNT_VISITED(next))
> +					return next;
> +				next = next_peer(next);
> +			}
> +		} else {
> +			while (1) {
> +				if (m->mnt_slave.next == &master->mnt_slave_list)
> +					break;
> +				m = next_slave(m);
> +				if (IS_MNT_VISITED(m))
> +					return m;
> +			}
> +		}
> +
> +		/* back at master */
> +		m = master;
> +	}
> +}
> +
>  static struct mount *next_group(struct mount *m, struct mount *origin)
>  {
>  	while (1) {
> @@ -399,11 +513,12 @@ static void mark_umount_candidates(struct mount *mnt)
>  
>  	BUG_ON(parent == mnt);
>  
> -	for (m = propagation_next(parent, parent); m;
> -			m = propagation_next(m, parent)) {
> +	for (m = propagation_visit_next(parent, parent); m;
> +			m = propagation_visit_next(m, parent)) {
>  		struct mount *child = __lookup_mnt_last(&m->mnt,
>  						mnt->mnt_mountpoint);
> -		if (child && (!IS_MNT_LOCKED(child) || IS_MNT_MARKED(m))) {
> +		if (child && (!IS_MNT_LOCKED(child) ||
> +			      IS_MNT_MARKED(m))) {
>  			SET_MNT_MARK(child);
>  		}
>  	}
> @@ -420,8 +535,8 @@ static void __propagate_umount(struct mount *mnt)
>  
>  	BUG_ON(parent == mnt);
>  
> -	for (m = propagation_next(parent, parent); m;
> -			m = propagation_next(m, parent)) {
> +	for (m = propagation_revisit_next(parent, parent); m;
> +			m = propagation_revisit_next(m, parent)) {
>  
>  		struct mount *child = __lookup_mnt_last(&m->mnt,
>  						mnt->mnt_mountpoint);
> diff --git a/fs/pnode.h b/fs/pnode.h
> index 550f5a8b4fcf..988ea4945764 100644
> --- a/fs/pnode.h
> +++ b/fs/pnode.h
> @@ -21,6 +21,10 @@
>  #define CLEAR_MNT_MARK(m) ((m)->mnt.mnt_flags &= ~MNT_MARKED)
>  #define IS_MNT_LOCKED(m) ((m)->mnt.mnt_flags & MNT_LOCKED)
>  
> +#define IS_MNT_VISITED(m) ((m)->mnt.mnt_flags & MNT_VISITED)
> +#define SET_MNT_VISITED(m) ((m)->mnt.mnt_flags |= MNT_VISITED)
> +#define CLEAR_MNT_VISITED(m) ((m)->mnt.mnt_flags &= ~MNT_VISITED)
> +
>  #define CL_EXPIRE    		0x01
>  #define CL_SLAVE     		0x02
>  #define CL_COPY_UNBINDABLE	0x04
> diff --git a/include/linux/mount.h b/include/linux/mount.h
> index 9227b190fdf2..6048045b96c3 100644
> --- a/include/linux/mount.h
> +++ b/include/linux/mount.h
> @@ -52,6 +52,8 @@ struct mnt_namespace;
>  
>  #define MNT_INTERNAL	0x4000
>  
> +#define MNT_VISITED		0x010000
> +
>  #define MNT_LOCK_ATIME		0x040000
>  #define MNT_LOCK_NOEXEC		0x080000
>  #define MNT_LOCK_NOSUID		0x100000
> -- 
> 2.8.3
> 
