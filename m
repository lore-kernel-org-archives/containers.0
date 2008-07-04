From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: [PATCH -mm 0/5] swapcgroup (v3)
Date: Fri, 4 Jul 2008 15:15:36 +0900
Message-ID: <20080704151536.e5384231.nishimura@mxp.nes.nec.co.jp>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
Cc: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi.

This is new version of swapcgroup.

Major changes from previous version
- Rebased on 2.6.26-rc5-mm3.
  The new -mm has been released, but these patches
  can be applied on 2.6.26-rc8-mm1 too with only some offset warnings.
  I tested these patches on 2.6.26-rc5-mm3 with some fixes about memory,
  and it seems to work fine.
- (NEW) Implemented force_empty.
  Currently, it simply uncharges all the charges from the group.

Patches
- [1/5] add cgroup files
- [2/5] add a member to swap_info_struct
- [3/5] implement charge and uncharge
- [4/5] modify vm_swap_full() 
- [5/5] implement force_empty

ToDo(in my thought. Feel free to add some others here.)
- need some documentation
  Add to memory.txt? or create a new documentation file?

- add option to disable only this feature
  I'm wondering if this option is needed.
  memcg has already the boot option to disable it.
  Is there any case where memory should be accounted but swap should not?

- hierarchy support
- move charges along with task
  Both of them need more discussion.


Thanks,
Daisuke Nishimura.
