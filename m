From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] extract-headers: work correctly with older 'awk'
Date: Wed, 28 Oct 2009 13:12:43 -0400
Message-ID: <1256749963-6009-1-git-send-email-orenl@librato.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Older versions of awk (mawk, specifically) do not understand
constructs like "[[:space:]]", "[[:digit:]] etc. Replace these with
"[ \t]", "[0-9]".

Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 scripts/extract-headers.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/scripts/extract-headers.sh b/scripts/extract-headers.sh
index 2de523b..b64e59c 100755
--- a/scripts/extract-headers.sh
+++ b/scripts/extract-headers.sh
@@ -49,7 +49,7 @@ if [ -z "${KERNELSRC}" -o '!' -d "${KERNELSRC}" ]; then
 fi
 
 # Match cpp includes
-INCLUDE_PRE_REGEX='#[[:space:]]*include[[:space:]]*\([<"]'
+INCLUDE_PRE_REGEX='#[ \t]*include[ \t]*\([<"]'
 INCLUDE_FILE_REGEX='[^">]*'
 INCLUDE_POST_REGEX='[">]\)'
 
@@ -84,7 +84,7 @@ function do_cpp ()
 	sed -e 's|'"${INCLUDE_REGEX}"'|/*#include \1*/|g' "${CPP_FILE}" | \
 	cpp -CC -P -U__KERNEL__ -undef -nostdinc -fdirectives-only -dDI "$@" | \
 	awk 'BEGIN { do_print = 0; }
-	     /#[[:space:]]*define '"${START_DEFINE}"'/  { do_print = 1; next; }
+	     /#[ \t]*define '"${START_DEFINE}"'/  { do_print = 1; next; }
 	     (do_print == 1)				{ print }' | \
 	cat -s | \
 	sed -e 's|/\*'"${INCLUDE_REGEX}"'\*/|#include \1|g' | \
@@ -144,7 +144,7 @@ echo '#endif /* _CHECKPOINT_CKPT_HDR_H_ */' >> "${OUTPUT_INCLUDES}/linux/checkpo
 # We use ARCH_COND to break up architecture-specific sections of the header.
 #
 ARCH_COND='#if'
-REGEX='[[:space:]]*#[[:space:]]*define[[:space:]]+__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+[[:digit:]]+'
+REGEX='[ \t]*#[ \t]*define[ \t]+__NR_(checkpoint|restart|clone_with_pids)[ \t]+[0-9]+'
 
 cat - <<-EOFOE
 /*
@@ -167,7 +167,7 @@ while read UNISTDH ; do
 	CPPARCH="$(karch_to_cpparch "${KARCH}" "${WORDBITS}")"
 	echo -e "${ARCH_COND} __${CPPARCH}__\\n"
 	grep -E "${REGEX}" "${UNISTDH}" | \
-	sed -e 's/^[[:space:]]*#[[:space:]]*define[[:space:]]\+__NR_\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\).*$/#\tifndef __NR_\1\n#\t\tdefine __NR_\1 \2\n#\tendif\n/'
+	sed -e 's/^[ \t]*#[ \t]*define[ \t]\+__NR_\([^ \t]\+\)[ \t]\+\([^ \t]\+\).*$/#\tifndef __NR_\1\n#\t\tdefine __NR_\1 \2\n#\tendif\n/'
 	ARCH_COND='#elif'
 done
 
-- 
1.6.0.4
