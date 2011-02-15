From: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Subject: [PATCH 0/1, v9] cgroup/freezer: add per freezer duty ratio control
Date: Tue, 15 Feb 2011 14:09:09 -0800
Message-ID: <1297807750-28844-1-git-send-email-jacob.jun.pan__40098.3833046213$1297876222$gmane$org@linux.intel.com>
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
To: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

Fixing subject in cover letter, should be v4 instead of v3

Changelog:
v9:	- merged duty ratio related data structs
	- removed toggling bit, replaced with freezer->state
	- consolidated toggling mode cancellation function	
	- use spin lock to protect duty ratio parameter writes
	- use second as period
	- allow 0% and 100% frozen time, aligned behavior with
	  freezer_write()
v8:	- minor clean up
v7:	- use delayed workqueue instead of per cgroup kernel thread
	  to manage toggling
	- make freezer.state higher priority than duty ratio setting
	- small correction in documentation

v6:	- remove check for duty ratio == 100 case
v5:	- improve error handling in duty ratio/ period writes
	- fix the logic to avoid kthread creation when ratio and
	  period are invalid.
	- 100% frozen is not permitted in duty ratio set up

v4:	- limit kthread creation only when valid duty ratio
	  parameters are given.
	- changed period back to milisecond
	- consolidated paramter write functions

v3:	- added documentation

v2:
	- use read_u64/write_u64 instead of string read/write
	- use period in second instead of ms
	- renamed duty_ratio to duty_ratio_pct, be more specific
	- removed locking around period and duty_ratio reads


Jacob Pan (1):
  cgroup/freezer: add per freezer duty ratio control

 Documentation/cgroups/freezer-subsystem.txt |   23 ++++++
 kernel/cgroup_freezer.c                     |  109 ++++++++++++++++++++++++++-
 2 files changed, 130 insertions(+), 2 deletions(-)
