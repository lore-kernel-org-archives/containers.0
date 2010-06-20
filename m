From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: new commits to ckpt-v22-dev
Date: Sun, 20 Jun 2010 13:08:14 -0400
Message-ID: <4C1E4AFE.9010500@cs.columbia.edu>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi

While waiting on the review, I pushed some recent work to a new
ckpt-v22-dev, including:

8fd5cc0459... c/r: ARM implementation of checkpoint/restart
61c3e0df4b... ARM: Add the eclone system call
15be6841fe... ARM: Rudimentary syscall interfaces
48d0ea4fb8... c/r: Un-blacklist VM_NORESERVE and VM_LOCKED
c3e8484f28... c/r: detect use of multiple devpts mounts in container
bc40da1798... Initialize the sem->sem_pending list after restoring
2cb36bd2be... c/r: pin down modules registered to obj-ops
a6ec7e051e... eclone: fix typos and minor errors in eclone documentation

There are also a couple of commits for user-cr:

f67877308e... ARM: Added user space support for c/r on ARM
19b55e0290... Minor reorg of restart.c
84336dc1e2... Remove flags parameter to cr_checkpoint()
758fe976d9... Change API prefix to cr_
d1f7a0bc1f... Add -p option to ckptinfo to dump pids tree
abe68111e4... improve end-of-file handling and reporting

Suka: does eclone() for ARM require an update ?  Also, note the
user-cr patches that I pulled from your series.

Thanks,

Oren.
