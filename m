From: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC 06/12] userns: Convert gfs2 to use kuid/kgid where
	appropriate
Date: Thu, 22 Nov 2012 09:47:44 +0000
Message-ID: <1353577664.2757.11.camel@menhir>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
	<1353415420-5457-6-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353415420-5457-6-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: adas-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

On Tue, 2012-11-20 at 04:43 -0800, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> - Use struct kqid to hold the identifier of in core quota objects
> - Use qid.type uniformly for all in core quota type computation.
> - kill QDF_USER
> - kill QUOTA_USER and QUOTA_GROUP
> 

There are some GFS2 changes in linux-next for merging shortly which are
likely to conflict with your changes in inode.c, but otherwise this
looks ok to me. I don't think that it will be very tricky to fix up the
conflicts.

I've not actually tested this, but it looks ok having read through it.
I'm also copying in Abhi since he looks after quotas in GFS2,

Steve.


> Cc: Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/gfs2/acl.c    |    2 +-
>  fs/gfs2/bmap.c   |    2 +-
>  fs/gfs2/dir.c    |    2 +-
>  fs/gfs2/glops.c  |    4 +-
>  fs/gfs2/incore.h |    3 +-
>  fs/gfs2/inode.c  |   36 ++++++++-------
>  fs/gfs2/quota.c  |  128 +++++++++++++++++++++++------------------------------
>  fs/gfs2/quota.h  |   15 +++---
>  fs/gfs2/super.c  |    6 +-
>  fs/gfs2/sys.c    |   14 +++++-
>  fs/gfs2/xattr.c  |    4 +-
>  init/Kconfig     |    1 -
>  12 files changed, 106 insertions(+), 111 deletions(-)
> 
> diff --git a/fs/gfs2/acl.c b/fs/gfs2/acl.c
> index f850020..f69ac0a 100644
> --- a/fs/gfs2/acl.c
> +++ b/fs/gfs2/acl.c
> @@ -237,7 +237,7 @@ static int gfs2_xattr_system_set(struct dentry *dentry, const char *name,
>  		return -EINVAL;
>  	if (type == ACL_TYPE_DEFAULT && !S_ISDIR(inode->i_mode))
>  		return value ? -EACCES : 0;
> -	if ((current_fsuid() != inode->i_uid) && !capable(CAP_FOWNER))
> +	if (!uid_eq(current_fsuid(), inode->i_uid) && !capable(CAP_FOWNER))
>  		return -EPERM;
>  	if (S_ISLNK(inode->i_mode))
>  		return -EOPNOTSUPP;
> diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
> index 1fd3ae2..ce2316b 100644
> --- a/fs/gfs2/bmap.c
> +++ b/fs/gfs2/bmap.c
> @@ -1052,7 +1052,7 @@ static int trunc_dealloc(struct gfs2_inode *ip, u64 size)
>  	if (error)
>  		return error;
>  
> -	error = gfs2_quota_hold(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
> +	error = gfs2_quota_hold(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
>  	if (error)
>  		return error;
>  
> diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
> index 259b088..5a9f574 100644
> --- a/fs/gfs2/dir.c
> +++ b/fs/gfs2/dir.c
> @@ -1854,7 +1854,7 @@ static int leaf_dealloc(struct gfs2_inode *dip, u32 index, u32 len,
>  	if (!ht)
>  		return -ENOMEM;
>  
> -	error = gfs2_quota_hold(dip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
> +	error = gfs2_quota_hold(dip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
>  	if (error)
>  		goto out;
>  
> diff --git a/fs/gfs2/glops.c b/fs/gfs2/glops.c
> index 32cc4fd..f3033f6 100644
> --- a/fs/gfs2/glops.c
> +++ b/fs/gfs2/glops.c
> @@ -322,8 +322,8 @@ static int gfs2_dinode_in(struct gfs2_inode *ip, const void *buf)
>  		break;
>  	};
>  
> -	ip->i_inode.i_uid = be32_to_cpu(str->di_uid);
> -	ip->i_inode.i_gid = be32_to_cpu(str->di_gid);
> +	i_uid_write(&ip->i_inode, be32_to_cpu(str->di_uid));
> +	i_gid_write(&ip->i_inode, be32_to_cpu(str->di_gid));
>  	gfs2_set_nlink(&ip->i_inode, be32_to_cpu(str->di_nlink));
>  	i_size_write(&ip->i_inode, be64_to_cpu(str->di_size));
>  	gfs2_set_inode_blocks(&ip->i_inode, be64_to_cpu(str->di_blocks));
> diff --git a/fs/gfs2/incore.h b/fs/gfs2/incore.h
> index 3d469d3..4fccb6c 100644
> --- a/fs/gfs2/incore.h
> +++ b/fs/gfs2/incore.h
> @@ -391,7 +391,6 @@ struct gfs2_revoke_replay {
>  };
>  
>  enum {
> -	QDF_USER		= 0,
>  	QDF_CHANGE		= 1,
>  	QDF_LOCKED		= 2,
>  	QDF_REFRESH		= 3,
> @@ -403,7 +402,7 @@ struct gfs2_quota_data {
>  
>  	atomic_t qd_count;
>  
> -	u32 qd_id;
> +	struct kqid qd_id;
>  	unsigned long qd_flags;		/* QDF_... */
>  
>  	s64 qd_change;
> diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
> index 381893c..bf60354 100644
> --- a/fs/gfs2/inode.c
> +++ b/fs/gfs2/inode.c
> @@ -365,13 +365,13 @@ static int create_ok(struct gfs2_inode *dip, const struct qstr *name,
>  }
>  
>  static void munge_mode_uid_gid(struct gfs2_inode *dip, umode_t *mode,
> -			       unsigned int *uid, unsigned int *gid)
> +			       kuid_t *uid, kgid_t *gid)
>  {
>  	if (GFS2_SB(&dip->i_inode)->sd_args.ar_suiddir &&
> -	    (dip->i_inode.i_mode & S_ISUID) && dip->i_inode.i_uid) {
> +	    (dip->i_inode.i_mode & S_ISUID) && i_uid_read(&dip->i_inode)) {
>  		if (S_ISDIR(*mode))
>  			*mode |= S_ISUID;
> -		else if (dip->i_inode.i_uid != current_fsuid())
> +		else if (!uid_eq(dip->i_inode.i_uid, current_fsuid()))
>  			*mode &= ~07111;
>  		*uid = dip->i_inode.i_uid;
>  	} else
> @@ -444,7 +444,7 @@ static void gfs2_init_dir(struct buffer_head *dibh,
>  
>  static void init_dinode(struct gfs2_inode *dip, struct gfs2_glock *gl,
>  			const struct gfs2_inum_host *inum, umode_t mode,
> -			unsigned int uid, unsigned int gid,
> +			kuid_t uid, kgid_t gid,
>  			const u64 *generation, dev_t dev, const char *symname,
>  			unsigned size, struct buffer_head **bhp)
>  {
> @@ -462,8 +462,8 @@ static void init_dinode(struct gfs2_inode *dip, struct gfs2_glock *gl,
>  	di->di_num.no_formal_ino = cpu_to_be64(inum->no_formal_ino);
>  	di->di_num.no_addr = cpu_to_be64(inum->no_addr);
>  	di->di_mode = cpu_to_be32(mode);
> -	di->di_uid = cpu_to_be32(uid);
> -	di->di_gid = cpu_to_be32(gid);
> +	di->di_uid = cpu_to_be32(from_kuid(&init_user_ns, uid));
> +	di->di_gid = cpu_to_be32(from_kgid(&init_user_ns, gid));
>  	di->di_nlink = 0;
>  	di->di_size = cpu_to_be64(size);
>  	di->di_blocks = cpu_to_be64(1);
> @@ -517,7 +517,8 @@ static int make_dinode(struct gfs2_inode *dip, struct gfs2_glock *gl,
>  		       unsigned int size, struct buffer_head **bhp)
>  {
>  	struct gfs2_sbd *sdp = GFS2_SB(&dip->i_inode);
> -	unsigned int uid, gid;
> +	kuid_t uid;
> +	kgid_t gid;
>  	int error;
>  
>  	munge_mode_uid_gid(dip, &mode, &uid, &gid);
> @@ -558,7 +559,7 @@ static int link_dinode(struct gfs2_inode *dip, const struct qstr *name,
>  	if (error)
>  		return error;
>  
> -	error = gfs2_quota_lock(dip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
> +	error = gfs2_quota_lock(dip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
>  	if (error)
>  		goto fail;
>  
> @@ -955,8 +956,8 @@ static int gfs2_unlink_ok(struct gfs2_inode *dip, const struct qstr *name,
>  		return -EPERM;
>  
>  	if ((dip->i_inode.i_mode & S_ISVTX) &&
> -	    dip->i_inode.i_uid != current_fsuid() &&
> -	    ip->i_inode.i_uid != current_fsuid() && !capable(CAP_FOWNER))
> +	    !uid_eq(dip->i_inode.i_uid, current_fsuid()) &&
> +	    !uid_eq(ip->i_inode.i_uid, current_fsuid()) && !capable(CAP_FOWNER))
>  		return -EPERM;
>  
>  	if (IS_APPEND(&dip->i_inode))
> @@ -1571,7 +1572,8 @@ static int setattr_chown(struct inode *inode, struct iattr *attr)
>  {
>  	struct gfs2_inode *ip = GFS2_I(inode);
>  	struct gfs2_sbd *sdp = GFS2_SB(inode);
> -	u32 ouid, ogid, nuid, ngid;
> +	kuid_t ouid, nuid;
> +	kgid_t ogid, ngid;
>  	int error;
>  
>  	ouid = inode->i_uid;
> @@ -1579,16 +1581,16 @@ static int setattr_chown(struct inode *inode, struct iattr *attr)
>  	nuid = attr->ia_uid;
>  	ngid = attr->ia_gid;
>  
> -	if (!(attr->ia_valid & ATTR_UID) || ouid == nuid)
> -		ouid = nuid = NO_QUOTA_CHANGE;
> -	if (!(attr->ia_valid & ATTR_GID) || ogid == ngid)
> -		ogid = ngid = NO_QUOTA_CHANGE;
> +	if (!(attr->ia_valid & ATTR_UID) || uid_eq(ouid, nuid))
> +		ouid = nuid = NO_UID_QUOTA_CHANGE;
> +	if (!(attr->ia_valid & ATTR_GID) || gid_eq(ogid, ngid))
> +		ogid = ngid = NO_GID_QUOTA_CHANGE;
>  
>  	error = gfs2_quota_lock(ip, nuid, ngid);
>  	if (error)
>  		return error;
>  
> -	if (ouid != NO_QUOTA_CHANGE || ogid != NO_QUOTA_CHANGE) {
> +	if (uid_valid(ouid) || gid_valid(ogid)) {
>  		error = gfs2_quota_check(ip, nuid, ngid);
>  		if (error)
>  			goto out_gunlock_q;
> @@ -1602,7 +1604,7 @@ static int setattr_chown(struct inode *inode, struct iattr *attr)
>  	if (error)
>  		goto out_end_trans;
>  
> -	if (ouid != NO_QUOTA_CHANGE || ogid != NO_QUOTA_CHANGE) {
> +	if (uid_valid(ouid) || gid_valid(ogid)) {
>  		u64 blocks = gfs2_get_inode_blocks(&ip->i_inode);
>  		gfs2_quota_change(ip, -blocks, ouid, ogid);
>  		gfs2_quota_change(ip, blocks, nuid, ngid);
> diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
> index 40c4b0d..f2353b5 100644
> --- a/fs/gfs2/quota.c
> +++ b/fs/gfs2/quota.c
> @@ -65,19 +65,22 @@
>  #include "inode.h"
>  #include "util.h"
>  
> -#define QUOTA_USER 1
> -#define QUOTA_GROUP 0
> -
>  struct gfs2_quota_change_host {
>  	u64 qc_change;
>  	u32 qc_flags; /* GFS2_QCF_... */
> -	u32 qc_id;
> +	struct kqid qc_id;
>  };
>  
>  static LIST_HEAD(qd_lru_list);
>  static atomic_t qd_lru_count = ATOMIC_INIT(0);
>  static DEFINE_SPINLOCK(qd_lru_lock);
>  
> +static u64 gfs2_qid_number(struct kqid qid)
> +{
> +	return (2 * (u64)from_kqid(&init_user_ns, qid)) +
> +		(qid.type == USRQUOTA) ? 0 : 1;
> +}
> +
>  int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	struct gfs2_quota_data *qd;
> @@ -124,13 +127,13 @@ static u64 qd2offset(struct gfs2_quota_data *qd)
>  {
>  	u64 offset;
>  
> -	offset = 2 * (u64)qd->qd_id + !test_bit(QDF_USER, &qd->qd_flags);
> +	offset = gfs2_qid_number(qd->qd_id);
>  	offset *= sizeof(struct gfs2_quota);
>  
>  	return offset;
>  }
>  
> -static int qd_alloc(struct gfs2_sbd *sdp, int user, u32 id,
> +static int qd_alloc(struct gfs2_sbd *sdp, struct kqid qid,
>  		    struct gfs2_quota_data **qdp)
>  {
>  	struct gfs2_quota_data *qd;
> @@ -141,13 +144,11 @@ static int qd_alloc(struct gfs2_sbd *sdp, int user, u32 id,
>  		return -ENOMEM;
>  
>  	atomic_set(&qd->qd_count, 1);
> -	qd->qd_id = id;
> -	if (user)
> -		set_bit(QDF_USER, &qd->qd_flags);
> +	qd->qd_id = qid;
>  	qd->qd_slot = -1;
>  	INIT_LIST_HEAD(&qd->qd_reclaim);
>  
> -	error = gfs2_glock_get(sdp, 2 * (u64)id + !user,
> +	error = gfs2_glock_get(sdp, gfs2_qid_number(qid),
>  			      &gfs2_quota_glops, CREATE, &qd->qd_gl);
>  	if (error)
>  		goto fail;
> @@ -161,8 +162,8 @@ fail:
>  	return error;
>  }
>  
> -static int qd_get(struct gfs2_sbd *sdp, int user, u32 id,
> -		  struct gfs2_quota_data **qdp)
> +static int qd_get(struct gfs2_sbd *sdp,
> +		  struct kqid qid, struct gfs2_quota_data **qdp)
>  {
>  	struct gfs2_quota_data *qd = NULL, *new_qd = NULL;
>  	int error, found;
> @@ -173,8 +174,7 @@ static int qd_get(struct gfs2_sbd *sdp, int user, u32 id,
>  		found = 0;
>  		spin_lock(&qd_lru_lock);
>  		list_for_each_entry(qd, &sdp->sd_quota_list, qd_list) {
> -			if (qd->qd_id == id &&
> -			    !test_bit(QDF_USER, &qd->qd_flags) == !user) {
> +			if (qid_eq(qd->qd_id, qid)) {
>  				if (!atomic_read(&qd->qd_count) &&
>  				    !list_empty(&qd->qd_reclaim)) {
>  					/* Remove it from reclaim list */
> @@ -208,7 +208,7 @@ static int qd_get(struct gfs2_sbd *sdp, int user, u32 id,
>  			return 0;
>  		}
>  
> -		error = qd_alloc(sdp, user, id, &new_qd);
> +		error = qd_alloc(sdp, qid, &new_qd);
>  		if (error)
>  			return error;
>  	}
> @@ -458,12 +458,12 @@ static void qd_unlock(struct gfs2_quota_data *qd)
>  	qd_put(qd);
>  }
>  
> -static int qdsb_get(struct gfs2_sbd *sdp, int user, u32 id,
> +static int qdsb_get(struct gfs2_sbd *sdp, struct kqid qid,
>  		    struct gfs2_quota_data **qdp)
>  {
>  	int error;
>  
> -	error = qd_get(sdp, user, id, qdp);
> +	error = qd_get(sdp, qid, qdp);
>  	if (error)
>  		return error;
>  
> @@ -491,7 +491,7 @@ static void qdsb_put(struct gfs2_quota_data *qd)
>  	qd_put(qd);
>  }
>  
> -int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid)
> +int gfs2_quota_hold(struct gfs2_inode *ip, kuid_t uid, kgid_t gid)
>  {
>  	struct gfs2_sbd *sdp = GFS2_SB(&ip->i_inode);
>  	struct gfs2_quota_data **qd;
> @@ -509,28 +509,28 @@ int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid)
>  	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
>  		return 0;
>  
> -	error = qdsb_get(sdp, QUOTA_USER, ip->i_inode.i_uid, qd);
> +	error = qdsb_get(sdp, make_kqid_uid(ip->i_inode.i_uid), qd);
>  	if (error)
>  		goto out;
>  	ip->i_res->rs_qa_qd_num++;
>  	qd++;
>  
> -	error = qdsb_get(sdp, QUOTA_GROUP, ip->i_inode.i_gid, qd);
> +	error = qdsb_get(sdp, make_kqid_gid(ip->i_inode.i_gid), qd);
>  	if (error)
>  		goto out;
>  	ip->i_res->rs_qa_qd_num++;
>  	qd++;
>  
> -	if (uid != NO_QUOTA_CHANGE && uid != ip->i_inode.i_uid) {
> -		error = qdsb_get(sdp, QUOTA_USER, uid, qd);
> +	if (uid_valid(uid) && !uid_eq(uid, ip->i_inode.i_uid)) {
> +		error = qdsb_get(sdp, make_kqid_uid(uid), qd);
>  		if (error)
>  			goto out;
>  		ip->i_res->rs_qa_qd_num++;
>  		qd++;
>  	}
>  
> -	if (gid != NO_QUOTA_CHANGE && gid != ip->i_inode.i_gid) {
> -		error = qdsb_get(sdp, QUOTA_GROUP, gid, qd);
> +	if (gid_valid(gid) && !gid_eq(gid, ip->i_inode.i_gid)) {
> +		error = qdsb_get(sdp, make_kqid_gid(gid), qd);
>  		if (error)
>  			goto out;
>  		ip->i_res->rs_qa_qd_num++;
> @@ -564,18 +564,10 @@ static int sort_qd(const void *a, const void *b)
>  	const struct gfs2_quota_data *qd_a = *(const struct gfs2_quota_data **)a;
>  	const struct gfs2_quota_data *qd_b = *(const struct gfs2_quota_data **)b;
>  
> -	if (!test_bit(QDF_USER, &qd_a->qd_flags) !=
> -	    !test_bit(QDF_USER, &qd_b->qd_flags)) {
> -		if (test_bit(QDF_USER, &qd_a->qd_flags))
> -			return -1;
> -		else
> -			return 1;
> -	}
> -	if (qd_a->qd_id < qd_b->qd_id)
> +	if (qid_lt(qd_a->qd_id, qd_b->qd_id))
>  		return -1;
> -	if (qd_a->qd_id > qd_b->qd_id)
> +	if (qid_lt(qd_b->qd_id, qd_a->qd_id))
>  		return 1;
> -
>  	return 0;
>  }
>  
> @@ -592,9 +584,9 @@ static void do_qc(struct gfs2_quota_data *qd, s64 change)
>  	if (!test_bit(QDF_CHANGE, &qd->qd_flags)) {
>  		qc->qc_change = 0;
>  		qc->qc_flags = 0;
> -		if (test_bit(QDF_USER, &qd->qd_flags))
> +		if (qd->qd_id.type == USRQUOTA)
>  			qc->qc_flags = cpu_to_be32(GFS2_QCF_USER);
> -		qc->qc_id = cpu_to_be32(qd->qd_id);
> +		qc->qc_id = cpu_to_be32(from_kqid(&init_user_ns, qd->qd_id));
>  	}
>  
>  	x = be64_to_cpu(qc->qc_change) + change;
> @@ -922,7 +914,7 @@ fail:
>  	return error;
>  }
>  
> -int gfs2_quota_lock(struct gfs2_inode *ip, u32 uid, u32 gid)
> +int gfs2_quota_lock(struct gfs2_inode *ip, kuid_t uid, kgid_t gid)
>  {
>  	struct gfs2_sbd *sdp = GFS2_SB(&ip->i_inode);
>  	struct gfs2_quota_data *qd;
> @@ -1037,19 +1029,20 @@ static int print_message(struct gfs2_quota_data *qd, char *type)
>  
>  	printk(KERN_INFO "GFS2: fsid=%s: quota %s for %s %u\n",
>  	       sdp->sd_fsname, type,
> -	       (test_bit(QDF_USER, &qd->qd_flags)) ? "user" : "group",
> -	       qd->qd_id);
> +	       (qd->qd_id.type == USRQUOTA) ? "user" : "group",
> +	       from_kqid(&init_user_ns, qd->qd_id));
>  
>  	return 0;
>  }
>  
> -int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
> +int gfs2_quota_check(struct gfs2_inode *ip, kuid_t uid, kgid_t gid)
>  {
>  	struct gfs2_sbd *sdp = GFS2_SB(&ip->i_inode);
>  	struct gfs2_quota_data *qd;
>  	s64 value;
>  	unsigned int x;
>  	int error = 0;
> +	int user;
>  
>  	if (!test_bit(GIF_QD_LOCKED, &ip->i_flags))
>  		return 0;
> @@ -1060,8 +1053,9 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
>  	for (x = 0; x < ip->i_res->rs_qa_qd_num; x++) {
>  		qd = ip->i_res->rs_qa_qd[x];
>  
> -		if (!((qd->qd_id == uid && test_bit(QDF_USER, &qd->qd_flags)) ||
> -		      (qd->qd_id == gid && !test_bit(QDF_USER, &qd->qd_flags))))
> +		user = (qd->qd_id.type == USRQUOTA);
> +		if (!((user && uid_eq(qd->qd_id.uid, uid)) ||
> +		      (!user && gid_eq(qd->qd_id.gid, gid))))
>  			continue;
>  
>  		value = (s64)be64_to_cpu(qd->qd_qb.qb_value);
> @@ -1071,10 +1065,7 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
>  
>  		if (be64_to_cpu(qd->qd_qb.qb_limit) && (s64)be64_to_cpu(qd->qd_qb.qb_limit) < value) {
>  			print_message(qd, "exceeded");
> -			quota_send_warning(make_kqid(&init_user_ns,
> -						     test_bit(QDF_USER, &qd->qd_flags) ?
> -						     USRQUOTA : GRPQUOTA,
> -						     qd->qd_id),
> +			quota_send_warning(qd->qd_id,
>  					   sdp->sd_vfs->s_dev, QUOTA_NL_BHARDWARN);
>  
>  			error = -EDQUOT;
> @@ -1084,10 +1075,7 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
>  			   time_after_eq(jiffies, qd->qd_last_warn +
>  					 gfs2_tune_get(sdp,
>  						gt_quota_warn_period) * HZ)) {
> -			quota_send_warning(make_kqid(&init_user_ns,
> -						     test_bit(QDF_USER, &qd->qd_flags) ?
> -						     USRQUOTA : GRPQUOTA,
> -						     qd->qd_id),
> +			quota_send_warning(qd->qd_id,
>  					   sdp->sd_vfs->s_dev, QUOTA_NL_BSOFTWARN);
>  			error = print_message(qd, "warning");
>  			qd->qd_last_warn = jiffies;
> @@ -1098,10 +1086,11 @@ int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid)
>  }
>  
>  void gfs2_quota_change(struct gfs2_inode *ip, s64 change,
> -		       u32 uid, u32 gid)
> +		       kuid_t uid, kgid_t gid)
>  {
>  	struct gfs2_quota_data *qd;
>  	unsigned int x;
> +	int user;
>  
>  	if (gfs2_assert_warn(GFS2_SB(&ip->i_inode), change))
>  		return;
> @@ -1111,8 +1100,9 @@ void gfs2_quota_change(struct gfs2_inode *ip, s64 change,
>  	for (x = 0; x < ip->i_res->rs_qa_qd_num; x++) {
>  		qd = ip->i_res->rs_qa_qd[x];
>  
> -		if ((qd->qd_id == uid && test_bit(QDF_USER, &qd->qd_flags)) ||
> -		    (qd->qd_id == gid && !test_bit(QDF_USER, &qd->qd_flags))) {
> +		user = (qd->qd_id.type == USRQUOTA);
> +		if ((user && uid_eq(qd->qd_id.uid, uid)) ||
> +		    (!user && gid_eq(qd->qd_id.gid, gid))) {
>  			do_qc(qd, change);
>  		}
>  	}
> @@ -1167,13 +1157,13 @@ static int gfs2_quota_sync_timeo(struct super_block *sb, int type)
>  	return gfs2_quota_sync(sb, type);
>  }
>  
> -int gfs2_quota_refresh(struct gfs2_sbd *sdp, int user, u32 id)
> +int gfs2_quota_refresh(struct gfs2_sbd *sdp, struct kqid qid)
>  {
>  	struct gfs2_quota_data *qd;
>  	struct gfs2_holder q_gh;
>  	int error;
>  
> -	error = qd_get(sdp, user, id, &qd);
> +	error = qd_get(sdp, qid, &qd);
>  	if (error)
>  		return error;
>  
> @@ -1191,7 +1181,9 @@ static void gfs2_quota_change_in(struct gfs2_quota_change_host *qc, const void *
>  
>  	qc->qc_change = be64_to_cpu(str->qc_change);
>  	qc->qc_flags = be32_to_cpu(str->qc_flags);
> -	qc->qc_id = be32_to_cpu(str->qc_id);
> +	qc->qc_id = make_kqid(&init_user_ns,
> +			      (qc->qc_flags & GFS2_QCF_USER)?USRQUOTA:GRPQUOTA,
> +			      be32_to_cpu(str->qc_id));
>  }
>  
>  int gfs2_quota_init(struct gfs2_sbd *sdp)
> @@ -1254,8 +1246,7 @@ int gfs2_quota_init(struct gfs2_sbd *sdp)
>  			if (!qc.qc_change)
>  				continue;
>  
> -			error = qd_alloc(sdp, (qc.qc_flags & GFS2_QCF_USER),
> -					 qc.qc_id, &qd);
> +			error = qd_alloc(sdp, qc.qc_id, &qd);
>  			if (error) {
>  				brelse(bh);
>  				goto fail;
> @@ -1482,21 +1473,17 @@ static int gfs2_get_dqblk(struct super_block *sb, struct kqid qid,
>  	struct gfs2_quota_data *qd;
>  	struct gfs2_holder q_gh;
>  	int error;
> -	int type;
>  
>  	memset(fdq, 0, sizeof(struct fs_disk_quota));
>  
>  	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
>  		return -ESRCH; /* Crazy XFS error code */
>  
> -	if (qid.type == USRQUOTA)
> -		type = QUOTA_USER;
> -	else if (qid.type == GRPQUOTA)
> -		type = QUOTA_GROUP;
> -	else
> +	if ((qid.type != USRQUOTA) &&
> +	    (qid.type != GRPQUOTA))
>  		return -EINVAL;
>  
> -	error = qd_get(sdp, type, from_kqid(&init_user_ns, qid), &qd);
> +	error = qd_get(sdp, qid, &qd);
>  	if (error)
>  		return error;
>  	error = do_glock(qd, FORCE, &q_gh);
> @@ -1505,8 +1492,8 @@ static int gfs2_get_dqblk(struct super_block *sb, struct kqid qid,
>  
>  	qlvb = (struct gfs2_quota_lvb *)qd->qd_gl->gl_lvb;
>  	fdq->d_version = FS_DQUOT_VERSION;
> -	fdq->d_flags = (type == QUOTA_USER) ? FS_USER_QUOTA : FS_GROUP_QUOTA;
> -	fdq->d_id = from_kqid(&init_user_ns, qid);
> +	fdq->d_flags = (qid.type == USRQUOTA) ? FS_USER_QUOTA : FS_GROUP_QUOTA;
> +	fdq->d_id = from_kqid_munged(current_user_ns(), qid);
>  	fdq->d_blk_hardlimit = be64_to_cpu(qlvb->qb_limit) << sdp->sd_fsb2bb_shift;
>  	fdq->d_blk_softlimit = be64_to_cpu(qlvb->qb_warn) << sdp->sd_fsb2bb_shift;
>  	fdq->d_bcount = be64_to_cpu(qlvb->qb_value) << sdp->sd_fsb2bb_shift;
> @@ -1532,19 +1519,16 @@ static int gfs2_set_dqblk(struct super_block *sb, struct kqid qid,
>  	int alloc_required;
>  	loff_t offset;
>  	int error;
> -	int type;
>  
>  	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
>  		return -ESRCH; /* Crazy XFS error code */
>  
>  	switch(qid.type) {
>  	case USRQUOTA:
> -		type = QUOTA_USER;
>  		if (fdq->d_flags != FS_USER_QUOTA)
>  			return -EINVAL;
>  		break;
>  	case GRPQUOTA:
> -		type = QUOTA_GROUP;
>  		if (fdq->d_flags != FS_GROUP_QUOTA)
>  			return -EINVAL;
>  		break;
> @@ -1554,10 +1538,10 @@ static int gfs2_set_dqblk(struct super_block *sb, struct kqid qid,
>  
>  	if (fdq->d_fieldmask & ~GFS2_FIELDMASK)
>  		return -EINVAL;
> -	if (fdq->d_id != from_kqid(&init_user_ns, qid))
> +	if (!qid_eq(make_kqid(current_user_ns(), qid.type, fdq->d_id), qid))
>  		return -EINVAL;
>  
> -	error = qd_get(sdp, type, from_kqid(&init_user_ns, qid), &qd);
> +	error = qd_get(sdp, qid, &qd);
>  	if (error)
>  		return error;
>  
> diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
> index f25d98b..4f5e6e4 100644
> --- a/fs/gfs2/quota.h
> +++ b/fs/gfs2/quota.h
> @@ -14,20 +14,21 @@ struct gfs2_inode;
>  struct gfs2_sbd;
>  struct shrink_control;
>  
> -#define NO_QUOTA_CHANGE ((u32)-1)
> +#define NO_UID_QUOTA_CHANGE INVALID_UID
> +#define NO_GID_QUOTA_CHANGE INVALID_GID
>  
> -extern int gfs2_quota_hold(struct gfs2_inode *ip, u32 uid, u32 gid);
> +extern int gfs2_quota_hold(struct gfs2_inode *ip, kuid_t uid, kgid_t gid);
>  extern void gfs2_quota_unhold(struct gfs2_inode *ip);
>  
> -extern int gfs2_quota_lock(struct gfs2_inode *ip, u32 uid, u32 gid);
> +extern int gfs2_quota_lock(struct gfs2_inode *ip, kuid_t uid, kgid_t gid);
>  extern void gfs2_quota_unlock(struct gfs2_inode *ip);
>  
> -extern int gfs2_quota_check(struct gfs2_inode *ip, u32 uid, u32 gid);
> +extern int gfs2_quota_check(struct gfs2_inode *ip, kuid_t uid, kgid_t gid);
>  extern void gfs2_quota_change(struct gfs2_inode *ip, s64 change,
> -			      u32 uid, u32 gid);
> +			      kuid_t uid, kgid_t gid);
>  
>  extern int gfs2_quota_sync(struct super_block *sb, int type);
> -extern int gfs2_quota_refresh(struct gfs2_sbd *sdp, int user, u32 id);
> +extern int gfs2_quota_refresh(struct gfs2_sbd *sdp, struct kqid qid);
>  
>  extern int gfs2_quota_init(struct gfs2_sbd *sdp);
>  extern void gfs2_quota_cleanup(struct gfs2_sbd *sdp);
> @@ -41,7 +42,7 @@ static inline int gfs2_quota_lock_check(struct gfs2_inode *ip)
>  	int ret;
>  	if (sdp->sd_args.ar_quota == GFS2_QUOTA_OFF)
>  		return 0;
> -	ret = gfs2_quota_lock(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
> +	ret = gfs2_quota_lock(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
>  	if (ret)
>  		return ret;
>  	if (sdp->sd_args.ar_quota != GFS2_QUOTA_ON)
> diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
> index bc73726..b4340b8 100644
> --- a/fs/gfs2/super.c
> +++ b/fs/gfs2/super.c
> @@ -721,8 +721,8 @@ void gfs2_dinode_out(const struct gfs2_inode *ip, void *buf)
>  	str->di_num.no_addr = cpu_to_be64(ip->i_no_addr);
>  	str->di_num.no_formal_ino = cpu_to_be64(ip->i_no_formal_ino);
>  	str->di_mode = cpu_to_be32(ip->i_inode.i_mode);
> -	str->di_uid = cpu_to_be32(ip->i_inode.i_uid);
> -	str->di_gid = cpu_to_be32(ip->i_inode.i_gid);
> +	str->di_uid = cpu_to_be32(i_uid_read(&ip->i_inode));
> +	str->di_gid = cpu_to_be32(i_gid_read(&ip->i_inode));
>  	str->di_nlink = cpu_to_be32(ip->i_inode.i_nlink);
>  	str->di_size = cpu_to_be64(i_size_read(&ip->i_inode));
>  	str->di_blocks = cpu_to_be64(gfs2_get_inode_blocks(&ip->i_inode));
> @@ -1428,7 +1428,7 @@ static int gfs2_dinode_dealloc(struct gfs2_inode *ip)
>  	if (error)
>  		return error;
>  
> -	error = gfs2_quota_hold(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
> +	error = gfs2_quota_hold(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
>  	if (error)
>  		return error;
>  
> diff --git a/fs/gfs2/sys.c b/fs/gfs2/sys.c
> index 8056b7b..0153040 100644
> --- a/fs/gfs2/sys.c
> +++ b/fs/gfs2/sys.c
> @@ -176,6 +176,7 @@ static ssize_t quota_refresh_user_store(struct gfs2_sbd *sdp, const char *buf,
>  					size_t len)
>  {
>  	int error;
> +	struct kqid qid;
>  	u32 id;
>  
>  	if (!capable(CAP_SYS_ADMIN))
> @@ -183,7 +184,11 @@ static ssize_t quota_refresh_user_store(struct gfs2_sbd *sdp, const char *buf,
>  
>  	id = simple_strtoul(buf, NULL, 0);
>  
> -	error = gfs2_quota_refresh(sdp, 1, id);
> +	qid = make_kqid(&init_user_ns, USRQUOTA, id);
> +	if (!qid_valid(qid))
> +		return -EINVAL;
> +
> +	error = gfs2_quota_refresh(sdp, qid);
>  	return error ? error : len;
>  }
>  
> @@ -191,6 +196,7 @@ static ssize_t quota_refresh_group_store(struct gfs2_sbd *sdp, const char *buf,
>  					 size_t len)
>  {
>  	int error;
> +	struct kqid qid;
>  	u32 id;
>  
>  	if (!capable(CAP_SYS_ADMIN))
> @@ -198,7 +204,11 @@ static ssize_t quota_refresh_group_store(struct gfs2_sbd *sdp, const char *buf,
>  
>  	id = simple_strtoul(buf, NULL, 0);
>  
> -	error = gfs2_quota_refresh(sdp, 0, id);
> +	qid = make_kqid(&init_user_ns, GRPQUOTA, id);
> +	if (!qid_valid(qid))
> +		return -EINVAL;
> +
> +	error = gfs2_quota_refresh(sdp, qid);
>  	return error ? error : len;
>  }
>  
> diff --git a/fs/gfs2/xattr.c b/fs/gfs2/xattr.c
> index db330e5..342f93e 100644
> --- a/fs/gfs2/xattr.c
> +++ b/fs/gfs2/xattr.c
> @@ -331,7 +331,7 @@ static int ea_remove_unstuffed(struct gfs2_inode *ip, struct buffer_head *bh,
>  	if (error)
>  		return error;
>  
> -	error = gfs2_quota_hold(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
> +	error = gfs2_quota_hold(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
>  	if (error)
>  		goto out_alloc;
>  
> @@ -1461,7 +1461,7 @@ int gfs2_ea_dealloc(struct gfs2_inode *ip)
>  	if (error)
>  		return error;
>  
> -	error = gfs2_quota_hold(ip, NO_QUOTA_CHANGE, NO_QUOTA_CHANGE);
> +	error = gfs2_quota_hold(ip, NO_UID_QUOTA_CHANGE, NO_GID_QUOTA_CHANGE);
>  	if (error)
>  		return error;
>  
> diff --git a/init/Kconfig b/init/Kconfig
> index 2573664..53b61cd 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -999,7 +999,6 @@ config UIDGID_CONVERTED
>  	default y
>  
>  	# Filesystems
> -	depends on GFS2_FS = n
>  	depends on NCP_FS = n
>  	depends on NFSD = n
>  	depends on NFS_FS = n
