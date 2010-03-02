From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Date: Tue, 2 Mar 2010 12:34:41 +0100
Message-ID: <20100302113441.GD1921__32784.6481967301$1267529719$gmane$org@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<cc557aab1003020211h391947f0p3eae04a298127d32@mail.gmail.com>
	<20100302110239.GB1921@linux>
	<cc557aab1003020309y37587110i685d0d968bfba9f4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cc557aab1003020309y37587110i685d0d968bfba9f4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 02, 2010 at 01:09:24PM +0200, Kirill A. Shutemov wrote:
> On Tue, Mar 2, 2010 at 1:02 PM, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> > On Tue, Mar 02, 2010 at 12:11:10PM +0200, Kirill A. Shutemov wrote:
> >> On Mon, Mar 1, 2010 at 11:23 PM, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wro=
te:
> >> > Apply the cgroup dirty pages accounting and limiting infrastructure =
to
> >> > the opportune kernel functions.
> >> >
> >> > Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> >> > ---
> >> > =A0fs/fuse/file.c =A0 =A0 =A0| =A0 =A05 +++
> >> > =A0fs/nfs/write.c =A0 =A0 =A0| =A0 =A04 ++
> >> > =A0fs/nilfs2/segment.c | =A0 10 +++++-
> >> > =A0mm/filemap.c =A0 =A0 =A0 =A0| =A0 =A01 +
> >> > =A0mm/page-writeback.c | =A0 84 ++++++++++++++++++++++++++++++++----=
--------------
> >> > =A0mm/rmap.c =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +-
> >> > =A0mm/truncate.c =A0 =A0 =A0 | =A0 =A02 +
> >> > =A07 files changed, 76 insertions(+), 34 deletions(-)
> >> >
> >> > diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> >> > index a9f5e13..dbbdd53 100644
> >> > --- a/fs/fuse/file.c
> >> > +++ b/fs/fuse/file.c
> >> > @@ -11,6 +11,7 @@
> >> > =A0#include <linux/pagemap.h>
> >> > =A0#include <linux/slab.h>
> >> > =A0#include <linux/kernel.h>
> >> > +#include <linux/memcontrol.h>
> >> > =A0#include <linux/sched.h>
> >> > =A0#include <linux/module.h>
> >> >
> >> > @@ -1129,6 +1130,8 @@ static void fuse_writepage_finish(struct fuse_=
conn *fc, struct fuse_req *req)
> >> >
> >> > =A0 =A0 =A0 =A0list_del(&req->writepages_entry);
> >> > =A0 =A0 =A0 =A0dec_bdi_stat(bdi, BDI_WRITEBACK);
> >> > + =A0 =A0 =A0 mem_cgroup_update_stat(req->pages[0],
> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_STAT_WRITEB=
ACK_TEMP, -1);
> >> > =A0 =A0 =A0 =A0dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEMP);
> >> > =A0 =A0 =A0 =A0bdi_writeout_inc(bdi);
> >> > =A0 =A0 =A0 =A0wake_up(&fi->page_waitq);
> >> > @@ -1240,6 +1243,8 @@ static int fuse_writepage_locked(struct page *=
page)
> >> > =A0 =A0 =A0 =A0req->inode =3D inode;
> >> >
> >> > =A0 =A0 =A0 =A0inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK=
);
> >> > + =A0 =A0 =A0 mem_cgroup_update_stat(tmp_page,
> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_STAT_WRITEB=
ACK_TEMP, 1);
> >> > =A0 =A0 =A0 =A0inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
> >> > =A0 =A0 =A0 =A0end_page_writeback(page);
> >> >
> >> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> >> > index b753242..7316f7a 100644
> >> > --- a/fs/nfs/write.c
> >> > +++ b/fs/nfs/write.c
> >> > @@ -439,6 +439,7 @@ nfs_mark_request_commit(struct nfs_page *req)
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0req->wb_index,
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NFS_PAGE_TAG_COMMIT);
> >> > =A0 =A0 =A0 =A0spin_unlock(&inode->i_lock);
> >> > + =A0 =A0 =A0 mem_cgroup_update_stat(req->wb_page, MEM_CGROUP_STAT_U=
NSTABLE_NFS, 1);
> >> > =A0 =A0 =A0 =A0inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> >> > =A0 =A0 =A0 =A0inc_bdi_stat(req->wb_page->mapping->backing_dev_info,=
 BDI_UNSTABLE);
> >> > =A0 =A0 =A0 =A0__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> >> > @@ -450,6 +451,7 @@ nfs_clear_request_commit(struct nfs_page *req)
> >> > =A0 =A0 =A0 =A0struct page *page =3D req->wb_page;
> >> >
> >> > =A0 =A0 =A0 =A0if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_stat(page, MEM_CGROU=
P_STAT_UNSTABLE_NFS, -1);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dec_zone_page_state(page, NR_UNSTABLE=
_NFS);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dec_bdi_stat(page->mapping->backing_d=
ev_info, BDI_UNSTABLE);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> >> > @@ -1273,6 +1275,8 @@ nfs_commit_list(struct inode *inode, struct li=
st_head *head, int how)
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0req =3D nfs_list_entry(head->next);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfs_list_remove_request(req);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfs_mark_request_commit(req);
> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_stat(req->wb_page,
> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CG=
ROUP_STAT_UNSTABLE_NFS, -1);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dec_zone_page_state(req->wb_page, NR_=
UNSTABLE_NFS);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dec_bdi_stat(req->wb_page->mapping->b=
acking_dev_info,
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BDI_U=
NSTABLE);
> >> > diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
> >> > index ada2f1b..aef6d13 100644
> >> > --- a/fs/nilfs2/segment.c
> >> > +++ b/fs/nilfs2/segment.c
> >> > @@ -1660,8 +1660,11 @@ nilfs_copy_replace_page_buffers(struct page *=
page, struct list_head *out)
> >> > =A0 =A0 =A0 =A0} while (bh =3D bh->b_this_page, bh2 =3D bh2->b_this_=
page, bh !=3D head);
> >> > =A0 =A0 =A0 =A0kunmap_atomic(kaddr, KM_USER0);
> >> >
> >> > - =A0 =A0 =A0 if (!TestSetPageWriteback(clone_page))
> >> > + =A0 =A0 =A0 if (!TestSetPageWriteback(clone_page)) {
> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_stat(clone_page,
> >>
> >> s/clone_page/page/
> >
> > mmh... shouldn't we use the same page used by TestSetPageWriteback() and
> > inc_zone_page_state()?
> =

> Sorry, I've commented wrong hunk. It's for the next one.

Yes. Good catch! Will fix in the next version.

Thanks,
-Andrea
