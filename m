From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Kernel text size with pid namespace
Date: Wed, 19 Sep 2007 17:16:44 -0700
Message-ID: <20070920001644.GA14880@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt,

The pid-namespace patcheset (http://lkml.org/lkml/2007/8/10/118)
was added to the -mm tree in 2.6.23-rc3-mm1.

With CONFIG_CC_OPTIMIZE_FOR_SIZE=y this patchset increases the kernel
text size by about 5K (closer to 6K when the config token is set to N).

As a quick test, I uninlined several helper functions and with this
the text size increased by about 4K. But since most of these inline
functions are used in process creation/termination, we would need to
keep them inline, when optimizing for performance.

We also do not have a config token to select pid namespace (its always
enabled). 

Is there a cause for concern with the 5K to 6K increase in text size ?
If so, can/should we conditionally inline some functions ? Or move 
some pid namespace creation code under CONFIG_TINY or something ?
Are there other techniques besides uninling we could apply ?

For reference, I am including below, some numbers for 2.6.23-rc2-mm2
kernel for an x86_64 config file.  In the following filenames:

	"clean" 	no pid ns patches
	"opt-size"	CONFIG_CC_OPTIMIZE_FOR_SIZE=y
	"no-opt"	CONFIG_CC_OPTIMIZE_FOR_SIZE=n
	"uninline"	uninline several new inline functions.

$ size vmlinux*

   text    data     bss     dec     hex filename

6016101  906266  772424 7694791  7569c7 vmlinux-clean-no-opt-size
6021869  906330  772424 7700623  75808f vmlinux-pidns-no-opt-size
6020805  906330  772424 7699559  757c67 vmlinux-pidns-no-opt-uninline-task-pid

5299192  906330  772424 6977946  6a799a vmlinux-clean-opt-size
5304588  906394  772424 6983406  6a8eee vmlinux-pidns-opt-size
5303348  906394  772424 6982166  6a8a16 vmlinux-pidns-opt-size-uninline-task-pid

Thanks,

Suka
