From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: selinux prevents msgrcv on restore message queues?
Date: Tue, 02 Mar 2010 15:36:14 -0600
Message-ID: <1267565774.11828.15.camel@localhost.localdomain>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

With ckpt-v19-rc3 the test-mq.sh testcase in cr_tests fails when SELinux
is enabled on my test system (64-bit powerpc kernel).  The testcase
sleeps in do_msgrcv after restart and never wakes up.  When SELinux is
disabled, the messages are received and the testcase passes.

I've established that the messages are being restored during restart --
msgctl(IPC_STAT) shows one message in each queue before calling msgrcv.
Adding the IPC_NOWAIT flag to the msgrcv calls gets ENOMSG, however.

I managed to narrow this down to security_msg_queue_msgrcv ->
selinux_msg_queue_msgrcv.  avc_has_perm(SECCLASS_MSG, MSG__RECEIVE) gets
-EACCESS, so I guess something is going awry in selinux restore hooks?

Any ideas?


Thanks,
Nathan
