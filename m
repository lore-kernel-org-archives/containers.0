From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] cr_tests: Fix hang when robust futex lists are not
	restored during restart
Date: Thu, 9 Jul 2009 17:21:44 -0700
Message-ID: <20090710002144.GA13085@us.ibm.com>
References: <20090709192207.GJ32310@count0.beaverton.ibm.com>
	<20090709205853.GA23637@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090709205853.GA23637-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
| > The robust futex test can hang if the kernel fails to properly set the robust
| > list pointer. This currently happens during restart. The test should not
| > hang and instead should report failure.
| > 
| > Use a timeout to ensure that hangs are caught and reported as failure.
| 
| Doesn't seem to work though :)  The test still hangs on restart.

I got a hang on restart, with following backtrace (ckpt-v17-rc1 plus couple
of bug fixes)

mktree        S f6a4bbe0     0 25126  25124 0x00000000
 f6589b00 00000086 00000001 f6a4bbe0 f6a4bd74 c3190160 f5e17e1c 011a6d85
 00000000 c302f680 ffffffea 007ee140 f5e17e1c 00000000 00000001 00000000
 c15fdbfc f5e17e00 f5e17e00 00000000 c1041af6 00000000 f5e17e00 00000000
Call Trace:
 [<c1041af6>] ? futex_wait_queue_me+0x94/0xa5
 [<c1041bfd>] ? futex_wait+0xf6/0x1e9
 [<c106300b>] ? generic_file_buffered_write+0x169/0x257
 [<c1042dd7>] ? do_futex+0x93/0xa01
 [<c101d867>] ? enqueue_entity+0xe/0x7e
 [<c1081787>] ? cache_alloc_refill+0x54/0x43e
 [<c106274a>] ? find_get_page+0x1d/0x7a
 [<c1064407>] ? filemap_fault+0xbb/0x320
 [<c107296c>] ? __do_fault+0x319/0x352
 [<c1037c5c>] ? autoremove_wake_function+0x0/0x2d
 [<c1073f6e>] ? handle_mm_fault+0x24e/0x508
 [<c1043846>] ? sys_futex+0x101/0x116
 [<c1351f46>] ? do_page_fault+0x1ff/0x27b
 [<c10027e8>] ? sysenter_do_call+0x12/0x26
mktree        S f642b750     0 25127  25124 0x00000000
 f6589b00 00000086 c15fcd3c f642b750 f642b8e4 c3170160 c1041e2f 011a6d7f
 ffffffff f6589b00 000005da 00000000 00000001 00000000 00000000 00000000
 f6500000 00000008 f66d5e7c f66d5f9c c108a797 00000000 f642b750 c1037c5c
Call Trace:
 [<c1041e2f>] ? futex_wake+0xb9/0xc3
 [<c108a797>] ? pipe_wait+0x4b/0x62
 [<c1037c5c>] ? autoremove_wake_function+0x0/0x2d
 [<c108afdf>] ? pipe_read+0x2c0/0x32d
 [<c1066aad>] ? get_page_from_freelist+0x284/0x2de
 [<c1084d7e>] ? do_sync_read+0xbf/0x100
 [<c1037c5c>] ? autoremove_wake_function+0x0/0x2d
 [<c10798ca>] ? page_add_new_anon_rmap+0x20/0x3b
 [<c1073ef8>] ? handle_mm_fault+0x1d8/0x508
 [<c1139499>] ? security_file_permission+0xc/0xd
 [<c1084cbf>] ? do_sync_read+0x0/0x100
 [<c10853f7>] ? vfs_read+0x81/0x102
 [<c1085787>] ? sys_read+0x3c/0x63
 [<c10027e8>] ? sysenter_do_call+0x12/0x26

| 
| Not sure it's worth worrying about this, versus just getting the robust
| futex restart fix into the kernel :)
| 
| thanks,
| -serge
| _______________________________________________
| Containers mailing list
| Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
| https://lists.linux-foundation.org/mailman/listinfo/containers
