From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/6] [RFC] Create the .relink file_operation
Date: Wed, 29 Sep 2010 16:07:03 -0700
Message-ID: <20100929230703.GS23839__2901.40031506798$1285801667$gmane$org@count0.beaverton.ibm.com>
References: <1285278812-16972-1-git-send-email-matthltc@us.ibm.com>
	<6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc@us.ibm.com>
	<d91e3660266d3a2956c4d1aebc9cb618081b21ef.1285278339.git.matthltc@us.ibm.com>
	<4CA39F53.6040506@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4CA39F53.6040506-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Valerie Aurora <vaurora-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Sep 29, 2010 at 04:19:31PM -0400, Oren Laadan wrote:
> 
> 
> On 09/23/2010 05:53 PM, Matt Helsley wrote:
> >Not all filesystems will necessarily be able to support relinking an
> >orphan inode back into the filesystem. Some offlist feedback suggested
> >that instead of overloading .link that relinking should be a separate
> >file operation for this reason.
> >
> >Since .relink is a superset of .link make the VFS call .relink where
> >possible and .link otherwise.
> >
> >The next commit will change ext3/4 to enable this operation.
> >
> >Signed-off-by: Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >Cc: Theodore Ts'o<tytso-3s7WtUTddSA@public.gmane.org>
> >Cc: Andreas Dilger<adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
> >Cc: Jan Kara<jack-AlSwsSmVLrQ@public.gmane.org>
> >Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >Cc: linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >Cc: Al Viro<viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> >---
> >  fs/namei.c         |    5 ++++-
> >  include/linux/fs.h |    1 +
> >  2 files changed, 5 insertions(+), 1 deletions(-)
> >
> >diff --git a/fs/namei.c b/fs/namei.c
> >index a7dce91..eb279e3 100644
> >--- a/fs/namei.c
> >+++ b/fs/namei.c
> >@@ -2446,7 +2446,10 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
> >  		return error;
> >
> >  	mutex_lock(&inode->i_mutex);
> >-	error = dir->i_op->link(old_dentry, dir, new_dentry);
> >+	if (dir->i_op->relink)
> >+		error = dir->i_op->relink(old_dentry, dir, new_dentry);
> >+	else
> >+		error = dir->i_op->link(old_dentry, dir, new_dentry);
> 
> Can there be a scenario/filesystem in which .relink implementation
> is so much more complex (and expensive) than .link ?
> 
> If the answer is "yes", then this we probably don't want to do
> this, and let vfs_link() call .link, and instead add a new helper
> vfs_relink().

OK, that makes some sense too. I thought the separation would
just be at the file operations layer but we can move it higher too.

I'll adjust the patches to do that and repost them.

Cheers,
	-Matt
