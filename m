From: Dave Jones <davej-rdkfGonbjUTCLXcRTR1eJlpr/1R2p/CL@public.gmane.org>
Subject: Re: [LKP] More information please. Re: [fs] 54cc07a761: BUG: kernel
	test crashed
Date: Tue, 26 Jul 2016 17:18:59 -0400
Message-ID: <20160726211859.GB9577__49425.8476108827$1469569828$gmane$org@codemonkey.org.uk>
References: <5793dfa5.mvXPj4LJOS0dlz3i%xiaolong.ye@intel.com>
	<877fc9a6mb.fsf@x220.int.ebiederm.org>
	<20160726143545.GA23656@wfg-t540p.sh.intel.com>
	<87vazsv4cn.fsf@x220.int.ebiederm.org>
	<20160726151344.GB8811@wfg-t540p.sh.intel.com>
	<87wpk8p49p.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87wpk8p49p.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jul 26, 2016 at 02:50:58PM -0500, Eric W. Biederman wrote:

 > > Yes that's the right directions to follow. We'll make the reports more
 > > understandable and the test/bisects more reliable.
 > 
 > Thanks.  Does trinity have a random seed it can export/import to rerun
 > the same tests?  I ask because there was a failure these tests caught
 > that if the right kernel options was enabled was 100% reliable and it
 > blamed a commit 10 patches down from the indicated commit.

It does log the random seed on startup, and can replay it with the -s option

There is some variance if you were to do two runs with the same seed back
to back, because on startup, it walks /proc & /sys, and they'd see different things
so for eg "read() from fd 100" might mean something entirely different.

But as the testbot runs a pretty minimal userspace, only runs trinity once,
and really early in boot, this point might not matter.

	Dave
