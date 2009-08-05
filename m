From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] cr_tests: Replace KERNELSRC envvar with a required
	commandline option
Date: Tue,  4 Aug 2009 21:42:28 -0700
Message-ID: <1249447347-26415-2-git-send-email-matthltc@us.ibm.com>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Replace KERNELSRC environment variable with an explicit commandline
option which sets the variable in the rewrite-cr-header.sh script.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
---
 rewrite-cr-header.sh |   33 +++++++++++++++++++++++++++++++--
 1 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/rewrite-cr-header.sh b/rewrite-cr-header.sh
index 63a2e88..bb334b8 100755
--- a/rewrite-cr-header.sh
+++ b/rewrite-cr-header.sh
@@ -6,11 +6,40 @@
 # Sanitize checkpoint/restart kernel headers for userspace.
 #
 
-KERNELSRC=../oren
+function usage()
+{
+	echo "Usage: $0 [-h|--help] -s|--kernel-src=DIR"
+}
+
+OPTIONS=`getopt -o s:o:h --long kernel-src:,output:,help -- "$@"`
+eval set -- "${OPTIONS}"
+while true ; do
+	case "$1" in
+	-s|--kernel-src)
+		KERNELSRC="$2"
+		shift 2 ;;
+	-h|--help)
+		usage
+		exit 0 ;;
+	--)
+		shift
+		break ;;
+	*)
+		echo "Unknown option: $1"
+		shift
+		echo "Unparsed options: $@"
+		usage 1>&2
+		exit 2 ;;
+	esac
+done
+
+if [ -z "${KERNELSRC}" -o '!' -d "${KERNELSRC}" ]; then
+	usage 1>&2
+	exit 2
+fi
 
 ################################################################################
 
-[ -z "${KERNELSRC}" ] && exit -1
 mv cr.h cr.h.bak || exit -1
 
 (
-- 
1.5.6.3
