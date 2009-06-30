From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Memory c/r performance
Date: Tue, 30 Jun 2009 11:25:41 -0700
Message-ID: <1246386341.31856.631.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

The biggest limiting factor for dumping large amounts of memory seems to
be i/o device speed, so big surprise there.

The other limit that I've noticed is that k{un}map_atomic() on i386 when
running under kvm is sloooooow.  I have to wonder if using regular old
kmap() is a better idea.  On 64-bit platforms, they'll basically compile
away.  But, on i386, it costs us 1 global tlb flush every time we wrap
the kmap space, which is every 2MB of memory, I think.

kmap_atomic(), on the other hand, costs an invlpg at unmap time.  That's
cheap on normal hardware, but costs a trip into the hypervisor (I guess
this is fixed in newer chips).

Anyway, here's what happens checkpointing an 800MB app using kmap and
kmap_atomic.  We save ~1 second of system time using kmap.  But, this is
all 32-bit which probably doesn't matter anyway.  

kmap (modified):
real	0m23.373s
user	0m2.020s
sys	0m20.161s
   788 checkpoint_dump_page                      12.1231
   423 __copy_from_user_ll_nozero                 4.9186
   415 kunmap_atomic                              4.3684
   268 __block_prepare_write                      0.3829
    87 ide_dma_end                                0.9255
    50 lookup_bh_lru                              0.4065
    44 on_each_cpu                                0.6984
    40 ext3_do_update_inode                       0.0571
    39 smp_invalidate_interrupt                   0.3023
    39 page_address                               0.2086
    38 __set_page_dirty                           0.2346
    31 __mark_inode_dirty                         0.0994
    30 do_get_write_access                        0.0279
    29 radix_tree_lookup_slot                     0.2522
    26 ext3_get_inode_block                       0.1757
    25 set_page_address                           0.0767
    25 buffered_rmqueue                           0.0471
    24 journal_stop                               0.0423
    24 journal_add_journal_head                   0.0923
    23 kmem_cache_alloc                           0.1704


kmap_atomic:
real	0m24.552s
user	0m1.992s
sys	0m21.401s
   902 kunmap_atomic                              9.4947
   750 checkpoint_dump_page                      10.0000
   423 __copy_from_user_ll_nozero                 4.9186
   247 __block_prepare_write                      0.3529
    70 ide_dma_end                                0.7447
    43 __set_page_dirty                           0.2654
    35 do_get_write_access                        0.0326
    35 buffered_rmqueue                           0.0659
    33 lookup_bh_lru                              0.2683
    31 ext3_do_update_inode                       0.0443
    28 radix_tree_lookup_slot                     0.2435
    28 journal_stop                               0.0494
    27 journal_add_journal_head                   0.1038
    27 __mark_inode_dirty                         0.0865
    24 __ratelimit                                0.1429
    23 journal_dirty_metadata                     0.0774
    21 ext3_get_inode_block                       0.1419
    20 test_set_page_writeback                    0.0844
    20 ext3_new_blocks                            0.0162
    20 __wake_up                                  0.3509

-- Dave
