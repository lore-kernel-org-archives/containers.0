From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [C/R] sleepers don't wake up on restart
Date: Wed, 1 Apr 2009 17:20:06 -0700
Message-ID: <20090402002005.GA22375@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Tried this with v14-rc2. This is probably not implemented yet...

I created a simple 1-level process tree (parent with 10 children). The 
parent just waits for the children to exit. The children do (error
checks removed). 

do_child():
        sprintf(cfile, "child-log-%d", cnum);

        i = 0;
        while (!test_done()) {
                cfp = fopen(cfile, "a");
                fprintf(cfp, "i = %d\n", i++);
                fflush(cfp);
                fclose(cfp);
                sleep(1);
        }

test_done():

	rc = access("test-done", F_OK)
	return rc == 0;

After freezing and restarting (using mktree), only one off 10 children makes
progress. Others are stuck in:

	ptree1        S f63ef170     0  8272      1
	 f5f17780 00000082 c2b1d5c8 f63ef170 f63ef2dc c2b20260 f5e0ff44 1c18de95
	 00000282 c0233594 c2b1d5c8 00000000 00000282 0000c350 00000001 0000c350
	 00000001 f5e0ff44 0000c350 c051b229 00000000 00000001 0000c350 bff32f44
	Call Trace:
	 [<c0233594>] hrtimer_start_range_ns+0x105/0x111
	 [<c051b229>] do_nanosleep+0x54/0x8c
	 [<c023362f>] hrtimer_nanosleep+0x8f/0xee
	 [<c0233210>] hrtimer_wakeup+0x0/0x18
	 [<c051b20f>] do_nanosleep+0x3a/0x8c
	 [<c02336cf>] sys_nanosleep+0x41/0x51
	 [<c0202ce5>] sysenter_do_call+0x12/0x25

One of them, (the 8th child) makes progress and continues to write to
its file

	ptree1        D f6bb7170     0  8280      1
	 f5de8b00 00000086 00000000 f6bb7170 f6bb72dc c2b17260 c0288ead 000165a5
	 c05322de c02dde8a ffffffff f6b34800 00000000 00000000 00000000 f6255d94
	 f5dd0700 c2b02314 f552d208 c02de045 00000000 f6e21478 00000000 f6b14600
	Call Trace:
	 [<c0288ead>] __find_get_block+0x121/0x12b
	 [<c02dde8a>] journal_stop+0x231/0x23d
	 [<c02de045>] do_get_write_access+0x1af/0x33b
	 [<c02310a9>] wake_bit_function+0x0/0x3c
	 [<c02de1e9>] journal_get_write_access+0x18/0x26
	 [<c02d3653>] __ext3_journal_get_write_access+0x13/0x32
	 [<c02c9285>] ext3_reserve_inode_write+0x2d/0x5d
	 [<c02c92cf>] ext3_mark_inode_dirty+0x1a/0x30
	 [<c02cb891>] ext3_dirty_inode+0x50/0x63
	 [<c0285d85>] __mark_inode_dirty+0x21/0x129
	 [<c027f7fa>] file_update_time+0x7e/0xa7
	 [<c0251c45>] __generic_file_aio_write_nolock+0x32a/0x4a1
	 [<c0281589>] mntput_no_expire+0x13/0xd7
	 [<c0251ffd>] generic_file_aio_write+0x4f/0xa6
	 [<c02c7bf9>] ext3_file_write+0x19/0x83
	 [<c0270a4d>] do_sync_write+0xbf/0x100
	 [<c023107c>] autoremove_wake_function+0x0/0x2d
	 [<c026672f>] page_add_new_anon_rmap+0x20/0x3b
	 [<c0260df9>] handle_mm_fault+0x1df/0x50c
	 [<c031d42d>] security_file_permission+0xc/0xd
	 [<c027098e>] do_sync_write+0x0/0x100
	 [<c02710dd>] vfs_write+0x83/0xf6
	 [<c02715a2>] sys_write+0x3c/0x63

When I create the 'test-done' file, this (8th child) exits but others are
still sleeping (confirms they never woke up from the sleep(1))

Sukadev
