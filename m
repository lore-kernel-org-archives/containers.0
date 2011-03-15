From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v6 4/9] memcg: add kernel calls for memcg dirty page stats
Date: Mon, 14 Mar 2011 23:32:38 -0700
Message-ID: <AANLkTinnfM6_ZhzEq6SAG1H2jDfKdVS2=fe_USi8ArNA@mail.gmail.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-5-git-send-email-gthelen@google.com> <20110314151023.GF11699@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110314151023.GF11699@barrios-desktop>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>
List-Id: containers.vger.kernel.org

On Mon, Mar 14, 2011 at 8:10 AM, Minchan Kim <minchan.kim@gmail.com> wr=
ote:
> On Fri, Mar 11, 2011 at 10:43:26AM -0800, Greg Thelen wrote:
>> Add calls into memcg dirty page accounting. =A0Notify memcg when pag=
es
>> transition between clean, file dirty, writeback, and unstable nfs.
>> This allows the memory controller to maintain an accurate view of
>> the amount of its memory that is dirty.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> Signed-off-by: Andrea Righi <arighi@develer.com>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> ---
>> Changelog since v5:
>> - moved accounting site in test_clear_page_writeback() and
>> =A0 test_set_page_writeback().
>>
>> =A0fs/nfs/write.c =A0 =A0 =A0| =A0 =A04 ++++
>> =A0mm/filemap.c =A0 =A0 =A0 =A0| =A0 =A01 +
>> =A0mm/page-writeback.c | =A0 10 ++++++++--
>> =A0mm/truncate.c =A0 =A0 =A0 | =A0 =A01 +
>> =A04 files changed, 14 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index 42b92d7..7863777 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -451,6 +451,7 @@ nfs_mark_request_commit(struct nfs_page *req)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NFS_PAGE_TAG_COMMIT);
>> =A0 =A0 =A0 nfsi->ncommit++;
>> =A0 =A0 =A0 spin_unlock(&inode->i_lock);
>> + =A0 =A0 mem_cgroup_inc_page_stat(req->wb_page, MEMCG_NR_FILE_UNSTA=
BLE_NFS);
>> =A0 =A0 =A0 inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>> =A0 =A0 =A0 inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BD=
I_RECLAIMABLE);
>> =A0 =A0 =A0 __mark_inode_dirty(inode, I_DIRTY_DATASYNC);
>> @@ -462,6 +463,7 @@ nfs_clear_request_commit(struct nfs_page *req)
>> =A0 =A0 =A0 struct page *page =3D req->wb_page;
>>
>> =A0 =A0 =A0 if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_dec_page_stat(page, MEMCG_NR_FI=
LE_UNSTABLE_NFS);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_zone_page_state(page, NR_UNSTABLE_NF=
S);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_bdi_stat(page->mapping->backing_dev_=
info, BDI_RECLAIMABLE);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> @@ -1319,6 +1321,8 @@ nfs_commit_list(struct inode *inode, struct li=
st_head *head, int how)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 req =3D nfs_list_entry(head->next);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfs_list_remove_request(req);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfs_mark_request_commit(req);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_dec_page_stat(req->wb_page,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0MEMCG_NR_FILE_UNSTABLE_NFS);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_zone_page_state(req->wb_page, NR_UNS=
TABLE_NFS);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_bdi_stat(req->wb_page->mapping->back=
ing_dev_info,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BDI_RECL=
AIMABLE);
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index a6cfecf..7e751fe 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -143,6 +143,7 @@ void __delete_from_page_cache(struct page *page)
>> =A0 =A0 =A0 =A0* having removed the page entirely.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 if (PageDirty(page) && mapping_cap_account_dirty(mapping=
)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_dec_page_stat(page, MEMCG_NR_FI=
LE_DIRTY);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_zone_page_state(page, NR_FILE_DIRTY)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_bdi_stat(mapping->backing_dev_info, =
BDI_RECLAIMABLE);
>> =A0 =A0 =A0 }
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 632b464..d8005b0 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -1118,6 +1118,7 @@ int __set_page_dirty_no_writeback(struct page =
*page)
>> =A0void account_page_dirtied(struct page *page, struct address_space=
 *mapping)
>> =A0{
>> =A0 =A0 =A0 if (mapping_cap_account_dirty(mapping)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_inc_page_stat(page, MEMCG_NR_FI=
LE_DIRTY);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_page_state(page, NR_FILE_DIRT=
Y);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_page_state(page, NR_DIRTIED);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_bdi_stat(mapping->backing_dev_info=
, BDI_RECLAIMABLE);
>> @@ -1317,6 +1318,7 @@ int clear_page_dirty_for_io(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* for more comments.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (TestClearPageDirty(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_dec_page_stat(p=
age, MEMCG_NR_FILE_DIRTY);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_zone_page_state(page=
, NR_FILE_DIRTY);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_bdi_stat(mapping->ba=
cking_dev_info,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 BDI_RECLAIMABLE);
>> @@ -1352,8 +1354,10 @@ int test_clear_page_writeback(struct page *pa=
ge)
>> =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D TestClearPageWriteback(page);
>> =A0 =A0 =A0 }
>> - =A0 =A0 if (ret)
>> + =A0 =A0 if (ret) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_dec_page_stat(page, MEMCG_NR_FI=
LE_WRITEBACK);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_zone_page_state(page, NR_WRITEBACK);
>> + =A0 =A0 }
>> =A0 =A0 =A0 return ret;
>> =A0}
>>
>> @@ -1386,8 +1390,10 @@ int test_set_page_writeback(struct page *page=
)
>> =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D TestSetPageWriteback(page);
>> =A0 =A0 =A0 }
>> - =A0 =A0 if (!ret)
>> + =A0 =A0 if (!ret) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_inc_page_stat(page, MEMCG_NR_FI=
LE_WRITEBACK);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 account_page_writeback(page);
>> + =A0 =A0 }
>> =A0 =A0 =A0 return ret;
>>
>> =A0}
>
> At least in mainline, NR_WRITEBACK handling codes are following as.
>
> 1) increase
>
> =A0* account_page_writeback
>
> 2) decrease
>
> =A0* test_clear_page_writeback
> =A0* __nilfs_end_page_io
>
> I think account_page_writeback name is good to add your account funct=
ion into that.
> The problem is decreasement. Normall we can handle decreasement in te=
st_clear_page_writeback.
> But I am not sure it's okay in __nilfs_end_page_io.
> I think if __nilfs_end_page_io is right, __nilfs_end_page_io should c=
all
> mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_WRITEBACK).
>
> What do you think about it?
>
>
>
> --
> Kind regards,
> Minchan Kim
>

I would like to not have any special cases that avoid certain memory.
So I think your suggestion is good.
However, nilfs memcg dirty page accounting was skipped in a previous
memcg dirty limit effort due to complexity.  See 'clone_page'
reference in:
  http://lkml.indiana.edu/hypermail/linux/kernel/1003.0/02997.html

I admit that I don't follow all of the nilfs code path, but it looks
like some of the nilfs pages are allocated but not charged to memcg.
There is code in mem_cgroup_update_page_stat() to gracefully handle
pages not associated with a memcg.  So perhaps nilfs clone pages dirty
[un]charge could be attempted.  I have not succeeded in testing in
exercising these code paths in nilfs.
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
