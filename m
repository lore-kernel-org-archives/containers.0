From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [fs] bdd20132c6: BUG: sleeping function called from invalid
	context at fs/proc/proc_sysctl.c:1569
Date: Sat, 23 Jul 2016 06:44:55 -0500
Message-ID: <878twsr32g.fsf@x220.int.ebiederm.org>
References: <5792dde7.0fHitzEpyzYl2u53%xiaolong.ye@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5792dde7.0fHitzEpyzYl2u53%xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> (kernel test
	robot's message of "Sat, 23 Jul 2016 11:00:55 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:

> FYI, we noticed the following commit:
>
> https://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing
> commit bdd20132c624a976f88b108ff37c7481c6f33e70 ("fs: Set s_user_ns to &init_user_ns in sget when MS_KERNMOUNT")
>
> in testcase: boot
>
> on test machine: 2 threads qemu-system-x86_64 -enable-kvm with 360M memory
>
> caused below changes:

Thank you for the report.  For anyone who is watching the change that
actually has the problem is:

a02420f1402ca76a6f2833c14fa82044cb2a0ae4 ("userns: Add per user namespace sysctls.")

It looks like that change isn't ready.  Close but not quite.  Ah well.

Eric
