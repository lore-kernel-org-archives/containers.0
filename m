From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr branch, ckpt-v18-dev, updated. v2.6.31-104-g17c7c62
Date: Wed, 14 Oct 2009 19:36:22 -0400
Message-ID: <200910142336.n9ENaM07024762@gorgona.ncl.cs.columbia.edu>
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
List-Id: containers.vger.kernel.org

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The branch, ckpt-v18-dev has been updated
       via  17c7c62ee3ac563a530b840328a31add6100dd87 (commit)
       via  d8b01d43edaad4dbbf023056ca54d506ba577174 (commit)
       via  ac4a14b9967298f7b9a91724d2af3c879355ffc2 (commit)
       via  cb695af7a922964a2f631ee7c92972e2a4215189 (commit)
       via  3af0ccdb8bdaa939c016b4163f1adcfbeddd133b (commit)
       via  bcec67a2c1c1d45d34ef13ad02c4cd136b49d440 (commit)
       via  b069c69890cfef7aba1cdea036229a859f592ebe (commit)
      from  62cb61406362bdae647789f41156b9a8ad856fbb (commit)

Those revisions listed above that are new to this repository have
not appeared on any other notification email; so we list those
revisions in full, below.

- Log -----------------------------------------------------------------
commit 17c7c62ee3ac563a530b840328a31add6100dd87
Author: \\\"Serge E. Hallyn\\\ <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Oct 14 18:46:40 2009 -0400

    debug: add a few ckpt_debugs
    
    These were pulled out of the lsm-related patches into which they
    had been embedded.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit d8b01d43edaad4dbbf023056ca54d506ba577174
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Oct 14 18:46:35 2009 -0400

    Add cpp definitions for enums
    
    This allows us to test for the enums in cpp expressions.
    
    (Here's a convenient vim expression to help process enum blocks. Move
    your cursor into the enum block and enter the following ex command:
    
    .,/^};/s/CKPT_\([^[:space:]=]*\)\(.*,.*\)[[:space:]]*$/CKPT_\1\2\r#define CKPT_\1 CKPT_\1/gc
    
    It looks for CKPT_* enums and prompty to ask if you wish to add #define
    lines for each one.)
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit ac4a14b9967298f7b9a91724d2af3c879355ffc2
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Oct 14 18:36:39 2009 -0400

    pre/post_restore_task: Do not pass checkpoint context when unused
    
    The checkpoint context is not used in these functions -- they only rely
    on current -- so it's safe to remove.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit cb695af7a922964a2f631ee7c92972e2a4215189
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Oct 14 18:36:35 2009 -0400

    Cleanup pre_restore_task comments
    
    We don't need to include the name of the function in the comment unless
    it's a kerneldoc comment -- it's redundant. Also the comment before
    post_restore_task() was copy-pasted without modification.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit 3af0ccdb8bdaa939c016b4163f1adcfbeddd133b
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Oct 14 18:36:31 2009 -0400

    Fix ckpt_write_err() check for empty string
    
    The test for empty error strings does not work because we always add 2
    to len before testing if it's 0. Fix by checking before adding 2.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit bcec67a2c1c1d45d34ef13ad02c4cd136b49d440
Author: \\\\\\\"Serge E. Hallyn\\\\\\\ <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Oct 14 18:25:40 2009 -0400

    don't call pre_restore_task twice
    
    Pre_restore_task is being called both before and inside
    restore_task, causing a memory leak at
    current->checkpoint_data.
    
    Only call it once, outside restore_task.
    
    This fixes a memory leak spotted by Dan Smith, and the
    actual bug was deduced by Matt Helsley.
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reported-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    
    Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
    Tested-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

commit b069c69890cfef7aba1cdea036229a859f592ebe
Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Wed Oct 14 18:21:53 2009 -0400

    Fix up headers so we can munge them for use by userspace.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-----------------------------------------------------------------------

Summary of changes:
 arch/s390/include/asm/checkpoint_hdr.h |    7 ++-
 arch/x86/include/asm/checkpoint_hdr.h  |    4 +-
 checkpoint/checkpoint.c                |    4 +-
 checkpoint/files.c                     |    3 +
 checkpoint/process.c                   |   31 ++++++----
 checkpoint/restart.c                   |    9 ++-
 include/linux/checkpoint.h             |    4 +-
 include/linux/checkpoint_hdr.h         |  101 +++++++++++++++++++++++++++++++-
 kernel/cred.c                          |    2 +
 9 files changed, 139 insertions(+), 26 deletions(-)


hooks/post-receive
--
linux-cr
