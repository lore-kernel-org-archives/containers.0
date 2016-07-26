From: Dave Jones <davej-rdkfGonbjUTCLXcRTR1eJlpr/1R2p/CL@public.gmane.org>
Subject: Re: [LKP] More information please. Re: [fs] 54cc07a761: BUG: kernel
	test crashed
Date: Tue, 26 Jul 2016 17:15:16 -0400
Message-ID: <20160726211516.GA9577__18910.8447674245$1469569823$gmane$org@codemonkey.org.uk>
References: <5793dfa5.mvXPj4LJOS0dlz3i%xiaolong.ye@intel.com>
	<877fc9a6mb.fsf@x220.int.ebiederm.org>
	<20160726143545.GA23656@wfg-t540p.sh.intel.com>
	<87vazsv4cn.fsf@x220.int.ebiederm.org>
	<20160726151344.GB8811@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160726151344.GB8811-q6ZYBFIlbFFi0tQiZxhdj1DQ4js95KgL@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jul 26, 2016 at 11:13:44PM +0800, Fengguang Wu wrote:
 
 > >> The "BUG: kernel test crashed" means the VM reboots by itself while
 > >> the trinity test is running. If the error message is "BUG: kernel boot
 > >> crashed" it'd mean VM abnormally reboots before any test is launched.
 > >
 > >Is it possible to include a url pointing to a page of documentation
 > >holding this information in your emails or alternatively a url pointing
 > >to some source code.  Just so other people don't have to ask you this
 > >question.
 > 
 > Yes that's the right directions to follow. We'll make the reports more
 > understandable and the test/bisects more reliable.
 > 
 > In particular, I suspect this false report might be related to QEMU
 > watchdog. The wild guess is, if trinity touches the watchdog device by
 > accident, it may result in the VM reset w/o any symptom.
 
See ignore_files() in pathnames.c
Adding an entry to the blacklist there is easy enough to prove/disprove this.

	Dave
